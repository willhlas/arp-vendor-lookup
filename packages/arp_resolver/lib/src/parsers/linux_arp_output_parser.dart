import 'package:arp_resolver/arp_resolver.dart';

final _lineRegex = RegExp(r'^(\S+)\s+dev\s+\S+(?:\s+lladdr\s+(\S+))?\s+\S+$');

/// Parses Linux `ip neigh show` (iproute2) output and returns the
/// [ArpEntry] for [ip], or `null` if [output] is empty, has no line for
/// [ip], or the only entry for [ip] has no resolved link-layer address yet
/// (e.g. a `FAILED`/`INCOMPLETE` state with no `lladdr` at all).
///
/// Throws [ArpParseFailure] if [output] is non-empty but contains no line
/// matching the expected `ip neigh show` format at all.
ArpEntry? parseLinuxArpOutput(String output, String ip) {
  if (output.trim().isEmpty) return null;

  var matchedAnyLine = false;

  for (final line in output.split('\n')) {
    final match = _lineRegex.firstMatch(line.trim());
    if (match == null) continue;

    matchedAnyLine = true;
    final entryIp = match.group(1)!;
    if (entryIp != ip) continue;

    final mac = match.group(2);
    if (mac == null) return null;

    return ArpEntry(ip: ip, mac: mac.toLowerCase());
  }

  if (!matchedAnyLine) {
    throw const ArpParseFailure(
      'ip neigh output did not match the expected format',
    );
  }

  return null;
}
