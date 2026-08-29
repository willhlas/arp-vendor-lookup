# API

A small Rails JSON API that resolves a MAC address to a vendor name, backing
the Flutter desktop app in `../app`. See the repo-root `CLAUDE.md` for the
full project context and conventions.

## Setup

- Ruby `3.4.10` (see `.ruby-version`)
- `bundle install`
- `bin/rails db:prepare` — creates the sqlite3 dev/test databases and loads
  the schema
- `bin/rails server` — runs on `http://localhost:3000`
- `bin/rails test` — runs the full suite (no real network calls; outbound
  HTTP is stubbed with WebMock)

## API reference

### `GET /lookups?mac=<mac>&ip=<ip>`

Resolves a MAC address to a vendor name. Both `mac` and `ip` are required.
The MAC is normalized (separators stripped, re-joined as uppercase
colon-pairs) before lookup, so `aa-bb-cc-dd-ee-ff`, `AA:BB:CC:DD:EE:FF`, and
`aabbccddeeff` all hit the same cached record.

Lookups are cached in the `lookups` table, keyed on `mac` alone: the first
request for a MAC calls
[macvendorlookup.com](https://www.macvendorlookup.com/) and persists the
result; every later request for that MAC is served from the database with
no outbound call, including MACs with no known vendor. `ip` is not part of
the cache key — it's stored on the record as the most recently seen IP for
that MAC, and is overwritten on every request (cache hit or miss).

| Status | When | Body |
| --- | --- | --- |
| `200` | Vendor found (fresh or cached) | The `Lookup` record: `{"id", "created_at", "mac", "updated_at", "vendor_name", "ip"}` |
| `404` | Well-formed MAC, no vendor on record (fresh 204 from upstream, or a previously-cached miss) | The `Lookup` record, with `"vendor_name": null` |
| `422` | `mac` isn't a full 6-octet address, or `ip` isn't a valid IPv4 address | `{"error": "mac must be a full 6-octet address, e.g. AA:BB:CC:DD:EE:FF"}` or `{"error": "ip must be a valid IPv4 address, e.g. 192.168.1.24"}` |
| `429` | The upstream vendor API rate-limited us | `{"error": "vendor lookup API rate-limited us (429)"}` |
| `502` | The upstream vendor API returned something unexpected (bad status, unparseable body) | `{"error": "..."}` describing the upstream failure |
| `503` | The upstream vendor API is unreachable or times out | `{"error": "vendor lookup API unreachable: ..."}` |

```
$ curl "http://localhost:3000/lookups?mac=AC:DE:48:00:11:22&ip=192.168.1.24"
{"id":1,"created_at":"...","mac":"AC:DE:48:00:11:22","updated_at":"...","vendor_name":"Private","ip":"192.168.1.24"}
```

### `GET /lookups`

Returns the 20 most recently created lookups (found or not), newest first —
`vendor_name` may be `null` for entries that resolved to no vendor. Always
`200`; no query, no upstream call.

```
$ curl "http://localhost:3000/lookups"
[{"id":2,"created_at":"...","mac":"00:00:00:00:00:01","updated_at":"...","vendor_name":"XEROX CORPORATION","ip":"192.168.1.5"}, {"id":1,...}]
```

## How it works

Both endpoints above are the *same route* — `GET /lookups` — branching on
whether the `mac` query param is present. Rails' request flow for either
case is:

```
config/routes.rb
  → app/controllers/lookups_controller.rb (LookupsController#index)
      → app/services/vendor_lookup_service.rb   (only when ?mac= is present)
          → app/models/lookup.rb                (cache read/write)
          → macvendorlookup.com                 (only on a cache miss)
```

- **`config/routes.rb`** — `resources :lookups, only: [:index]` maps
  `GET /lookups` to `LookupsController#index`. Only `:index` exists because
  there's no create/update/delete for a lookup from outside the app — it's
  populated entirely as a side effect of resolving MACs.

- **`app/controllers/lookups_controller.rb`** — thin by design. `index`
  branches once on `params[:mac].nil?` (this is a response-shape decision,
  not business logic, so it's allowed to live here per the project's
  thin-controller convention). Each branch does exactly one thing: call
  the service or query the model, then render. The four `rescue` clauses
  are what turn `VendorLookupService`'s typed exceptions into the right
  HTTP status (`InvalidMacError`/`InvalidIpError` → 422,
  `UpstreamRateLimitedError` → 429, `UpstreamUnavailableError` → 503,
  `UpstreamBadResponseError` → 502) — the controller never inspects error
  internals itself.

- **`app/services/vendor_lookup_service.rb`** — owns the entire
  "resolve a MAC" behavior: normalize → validate `mac` and `ip` format →
  check the cache → on a miss, call macvendorlookup.com → persist whatever
  comes back (found *or* not-found) as a `Lookup`; on a hit, just refresh
  the stored `ip`. It raises `InvalidMacError`/`InvalidIpError` for a
  malformed `mac`/`ip`, and a specific `UpstreamError` subclass
  (`UpstreamRateLimitedError`, `UpstreamBadResponseError`,
  `UpstreamUnavailableError`) for each distinct way the vendor API can
  fail — these are the failure modes the controller needs to distinguish,
  per CLAUDE.md's "no silent failures" principle. A successful "no vendor
  found" is *not* an exception — it's a normal `Lookup` row with
  `vendor_name: nil`, which is what lets it be cached and shown in the
  recent-lookups history like any other result.

- **`app/models/lookup.rb`** — the `lookups` table is the cache. `mac` has
  a DB-level unique index (so the cache itself enforces one row per MAC,
  not just app-level logic — `ip` has no such constraint, since it's just
  the last-seen IP for that MAC, not part of identity), `MAC_FORMAT` is
  the validation the service checks a normalized MAC against, and
  `found?` is a getter for "did this resolve to a vendor" so callers
  don't need to know that "not found" means `vendor_name.nil?` under the
  hood.

- **`test/integration/lookups_test.rb`** and
  **`test/services/vendor_lookup_service_test.rb`** — the integration test
  drives the full status-code matrix through the real HTTP layer
  (`ActionDispatch::IntegrationTest`); the service test exercises
  normalization and each `VendorLookupService` failure path directly, which
  is where a real bug was caught during development (see below).

### Judgment calls worth knowing about

- **429 vs. 502 vs. 503 are kept distinct** — the upstream vendor API can
  fail in three meaningfully different ways: it can rate-limit us (`429`,
  worth backing off and retrying later), return a malformed/unexpected
  response (`502` — the gateway got a bad response from the upstream it's
  proxying), or be unreachable/timing out (`503` — the upstream itself
  looks down). Collapsing these into one generic "upstream failed" status
  would hide information a client could otherwise act on.
- **No cache expiry** — a cached `Lookup` (found or not) is never
  re-fetched. CLAUDE.md's spec doesn't call for a TTL, so this follows
  YAGNI; revisit if vendor data needs to be refreshed later.
- **Full MAC required** — a partial OUI prefix (which macvendorlookup.com's
  own API technically accepts) is rejected with `422`, since the Flutter
  app always reads a complete MAC from the ARP table.
- **`Net::HTTPNoContent` is a subclass of `Net::HTTPSuccess`** in Ruby's
  stdlib (a 204 *is* a 2xx), which isn't obvious from the class names.
  `VendorLookupService#fetch_vendor_name`'s `case/when` checks
  `Net::HTTPNoContent` before `Net::HTTPSuccess` for exactly this reason —
  reordering those two lines reintroduces a bug where a legitimate
  not-found response crashes trying to parse a `nil` body as JSON. This
  was caught by the test suite, not manual testing, which is why
  CLAUDE.md flags external-boundary parsing as the highest testing
  priority in this app.
