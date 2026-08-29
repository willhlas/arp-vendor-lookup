import 'dart:io';

import 'package:arp_resolver/arp_resolver.dart';

class MacosArpResolver implements ArpResolver {
  const MacosArpResolver({required this._runProcess});

  final ArpProcessRunner _runProcess;

  static final _lineRegex = RegExp(
    r'^\S+\s+\(([\d.]+)\)\s+at\s+(\S+)\s+on\s+\S+',
  );

  static String _normalizeMac(String mac) => mac
      .split(':')
      .map((octet) => octet.padLeft(2, '0'))
      .join(':')
      .toLowerCase();

  @override
  Future<ArpEntry?> resolve(String ip) async {
    final ProcessResult result;
    try {
      result = await _runProcess('arp', ['-a']);
    } catch (e) {
      throw ArpCommandFailure('could not run the arp command: $e');
    }

    if (result.exitCode != 0) {
      throw ArpCommandFailure(
        'arp exited with code ${result.exitCode}: ${result.stderr}',
      );
    }

    return parseArpOutput(result.stdout as String, ip);
  }

  @override
  ArpEntry? parseArpOutput(String output, String ip) {
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
}
