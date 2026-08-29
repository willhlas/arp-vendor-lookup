# arp_resolver

Pure Dart package (no `flutter` dependency) that reads and parses the local
machine's ARP table to resolve an IP address to a MAC address, plus a
small helper for detecting the local machine's own IPv4 address. Used by
`vendor_lookup_repository`, which sits above it in the data-layer stack.
See the repo-root `CLAUDE.md` for the full project context and
conventions.

## Setup

- `dart pub get`
- `dart test`

## What it does

### `ArpResolver`

```dart
abstract class ArpResolver {
  Future<ArpEntry?> resolve(String ip);
  ArpEntry? parseArpOutput(String output, String ip);
}
```

`resolve` shells out to the platform's ARP command and returns the
`ArpEntry` (`ip`, `mac`) for the given IP, or `null` if the local ARP
table has no entry for it — an ARP miss is a normal result, not a
failure. It throws `ArpCommandFailure` if the OS command itself can't be
run or exits non-zero, and `ArpParseFailure` if the command runs but its
output doesn't match the expected format at all (never for an empty
table or a missing entry — those are `null`).

`createArpResolver()` (in `arp_resolver_factory.dart`) picks the right
implementation for the current platform:

- `MacosArpResolver`
- `LinuxArpResolver`
- `WindowsArpResolver`

Each implementation shells out via an injected `ArpProcessRunner`
(matching `Process.run`'s signature) so tests can stub process output
without spawning a real `arp`/`ip neigh` process. This is the swappable
per-platform-implementation-behind-one-interface pattern `CLAUDE.md`
calls for — parsing logic never branches on `Platform.isX` outside this
package.

### `LocalNetworkInfo`

```dart
abstract class LocalNetworkInfo {
  Future<String?> primaryIPv4Address();
}
```

A second, related I/O concern alongside ARP parsing: `SystemLocalNetworkInfo`
lists the local machine's network interfaces (via an injected
`NetworkAddressLister`, mirroring `NetworkInterface.list`) and returns its
primary non-loopback IPv4 address, or `null` if none is active. Backs the
app's "use my IP" feature. Throws `LocalNetworkInfoFailure` if the
underlying platform call itself fails.

### Models

`ArpEntry` (`ip`, `mac`) is `Equatable` only — it's parsed from raw text
output, not a JSON boundary, so there's nothing to serialize.

### Exceptions

`ArpResolverException` and `LocalNetworkInfoException` are each a sealed
class with typed subclasses (`ArpCommandFailure`/`ArpParseFailure`, and
`LocalNetworkInfoFailure` respectively) — callers catch the specific
failure mode rather than a generic error.
