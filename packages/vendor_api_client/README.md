# vendor_api_client

Pure Dart package (no `flutter` dependency) that is the HTTP client for
this project's Rails API (`../../api`). Sits at the bottom of the
data-layer stack — `vendor_lookup_repository` is built on top of it. See
the repo-root `CLAUDE.md` for the full project context and conventions.

## Setup

- `dart pub get`
- `dart test`
- If you change `Lookup`, regenerate its `json_serializable` code:
  `dart run build_runner build --delete-conflicting-outputs`

## What it does

### `VendorApiClient`

```dart
Future<Lookup> lookupByMac(String mac, String ip)
Future<List<Lookup>> recentLookups()
```

`lookupByMac` calls `GET /lookups?mac=...&ip=...` and maps the API's
status-code matrix onto typed exceptions (see below); `200`/`404` both
decode to a `Lookup` (the API itself distinguishes "found" from
"well-formed but no vendor" via `Lookup.found`, not via a thrown
exception — a not-found MAC is a normal result). `recentLookups` calls
`GET /lookups` (no `mac`) for the app's history view.

### `Lookup`

`Equatable` + `json_serializable` (`@JsonSerializable(fieldRename:
FieldRename.snake)`, generated `lookup.g.dart`) — the one model in this
package that crosses the Rails API's JSON boundary. Fields: `id`, `mac`,
`ip`, `vendorName` (nullable), `createdAt`, `updatedAt`, plus a `found`
getter (`vendorName != null`).

### `VendorApiException`

A sealed class with one subclass per way the API call can fail, matching
the Rails API's status codes one-to-one:

| Exception | HTTP status | Meaning |
| --- | --- | --- |
| `InvalidMacFailure` | 422 | The `mac` (or `ip`) was rejected as malformed |
| `RateLimitedFailure` | 429 | The API's own upstream rate-limited it |
| `UpstreamLookupFailure` | 502 | The API's upstream responded, but badly |
| `UpstreamUnavailableFailure` | 503 | The API's upstream couldn't be reached |
| `NetworkFailure` | — | This client couldn't reach the API at all (DNS, connection, timeout) |
| `UnexpectedResponseFailure` | any other | An unrecognized status code, or an unparseable body |

`NetworkFailure` vs. `UpstreamUnavailableFailure` is a deliberate
distinction worth knowing: the former means *our* call to the Rails API
never got a response; the latter means the Rails API responded, but
*its* call to the vendor lookup service failed at the network level.
