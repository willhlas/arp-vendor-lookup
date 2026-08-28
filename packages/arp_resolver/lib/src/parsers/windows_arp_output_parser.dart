import 'package:arp_resolver/arp_resolver.dart';

final _dataLineRegex = RegExp(
  r'^(\d{1,3}(?:\.\d{1,3}){3})\s+([0-9a-fA-F]{2}(?:-[0-9a-fA-F]{2}){5})\s+(\S+)$',
);
final _interfaceLineRegex = RegExp('^Interface:');
final _headerLineRegex = RegExp('^Internet Address', caseSensitive: false);

/// Parses Windows `arp -a` output and returns the [ArpEntry] for [ip], or
/// `null` if [output] is empty, has no row for [ip], or the only row for
/// [ip] is unresolved (physical address `00-00-00-00-00-00` or type
/// `invalid`).
///
/// Throws [ArpParseFailure] if [output] is non-empty but contains no
/// interface header or data row matching the expected `arp -a` format at
/// all.
ArpEntry? parseWindowsArpOutput(String output, String ip) {
  if (output.trim().isEmpty) return null;

  var recognizedAnyLine = false;

  for (final rawLine in output.split('\n')) {
    final line = rawLine.trim();
    if (line.isEmpty) continue;

    if (_interfaceLineRegex.hasMatch(line) || _headerLineRegex.hasMatch(line)) {
      recognizedAnyLine = true;
      continue;
    }

    final match = _dataLineRegex.firstMatch(line);
    if (match == null) continue;

    recognizedAnyLine = true;
    final entryIp = match.group(1)!;
    if (entryIp != ip) continue;

    final macToken = match.group(2)!;
    final type = match.group(3)!;
    if (macToken == '00-00-00-00-00-00' || type.toLowerCase() == 'invalid') {
      return null;
    }

    return ArpEntry(ip: ip, mac: macToken.replaceAll('-', ':').toLowerCase());
  }

  if (!recognizedAnyLine) {
    throw const ArpParseFailure(
      'arp output did not match the expected format',
    );
  }

  return null;
}
