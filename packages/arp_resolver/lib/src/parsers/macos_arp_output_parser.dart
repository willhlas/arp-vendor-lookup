import 'package:arp_resolver/arp_resolver.dart';

final _lineRegex = RegExp(r'^\S+\s+\(([\d.]+)\)\s+at\s+(\S+)\s+on\s+\S+');

/// Parses macOS `arp -a` output and returns the [ArpEntry] for [ip], or
/// `null` if [output] is empty, has no line for [ip], or the only entry
/// for [ip] is `(incomplete)`.
///
/// Throws [ArpParseFailure] if [output] is non-empty but contains no
/// line matching the expected `arp -a` format at all.
ArpEntry? parseMacosArpOutput(String output, String ip) {
  if (output.trim().isEmpty) return null;

  var matchedAnyLine = false;

  for (final line in output.split('\n')) {
    final match = _lineRegex.firstMatch(line.trim());
    if (match == null) continue;

    matchedAnyLine = true;
    final entryIp = match.group(1)!;
    if (entryIp != ip) continue;

    final macToken = match.group(2)!;
    if (macToken == '(incomplete)') return null;

    return ArpEntry(ip: ip, mac: _normalizeMac(macToken));
  }

  if (!matchedAnyLine) {
    throw const ArpParseFailure(
      'arp output did not match the expected format',
    );
  }

  return null;
}

String _normalizeMac(String mac) {
  return mac
      .split(':')
      .map((octet) => octet.padLeft(2, '0'))
      .join(':')
      .toLowerCase();
}
