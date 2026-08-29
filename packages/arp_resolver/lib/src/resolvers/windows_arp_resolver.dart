import 'dart:io';

import 'package:arp_resolver/arp_resolver.dart';

class WindowsArpResolver implements ArpResolver {
  const WindowsArpResolver({required this._runProcess});

  final ArpProcessRunner _runProcess;

  static final _dataLineRegex = RegExp(
    r'^(\d{1,3}(?:\.\d{1,3}){3})\s+([0-9a-fA-F]{2}(?:-[0-9a-fA-F]{2}){5})\s+(\S+)$',
  );
  static final _interfaceLineRegex = RegExp('^Interface:');
  static final _headerLineRegex = RegExp(
    '^Internet Address',
    caseSensitive: false,
  );

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

    var recognizedAnyLine = false;

    for (final rawLine in output.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      if (_interfaceLineRegex.hasMatch(line) ||
          _headerLineRegex.hasMatch(line)) {
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
}
