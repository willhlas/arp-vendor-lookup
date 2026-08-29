# vendor_lookup_repository

Pure Dart package (no `flutter` dependency) that is the caching/repository
layer combining `arp_resolver` and `vendor_api_client` into the single
operation the app actually needs: resolve an IP all the way to a vendor
name. See the repo-root `CLAUDE.md` for the full project context and
conventions.

## Setup

- `dart pub get`
- `dart test`

## What it does

### `VendorLookupRepository`

```dart
Future<VendorLookupResult> lookupByIp(String ip)
Future<List<Lookup>> recentLookups()
```

`lookupByIp` chains the two lower-level packages: resolve `ip` via
`ArpResolver.resolve`, and if that finds a MAC, call
`VendorApiClient.lookupByMac` for the vendor name. Each stage's typed
exception is caught and rewrapped as a `VendorLookupRepositoryException`
subclass so callers only ever need to catch one exception hierarchy
regardless of which stage failed. `recentLookups` proxies directly to
`VendorApiClient.recentLookups` for the app's history view.

### `VendorLookupResult`

`Equatable`-only (in-memory result, not a JSON boundary): `ip`, the
resolved `mac` (`null` on an ARP miss), and the resulting `vendorLookup`
(`Lookup?`, `null` only when `mac` is `null`). Exposes `arpMiss` and
`found` getters so callers/UI code don't need to reason about which
combination of nulls means what.

### `VendorLookupRepositoryException`

A sealed class with a subclass per stage of the chain that can fail —
each wraps the original lower-level exception as `cause`:

- `ArpLookupFailure` — the `arp_resolver` call itself failed (not an ARP
  miss, which is a normal `VendorLookupResult.arpMiss == true` result).
- `VendorApiLookupFailure` — the `vendor_api_client` call failed (network,
  rate-limited, or an unexpected API response).
