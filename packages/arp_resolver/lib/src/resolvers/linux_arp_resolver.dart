import 'dart:io';

import 'package:arp_resolver/arp_resolver.dart';

final _lineRegex = RegExp(r'^(\S+)\s+dev\s+\S+(?:\s+lladdr\s+(\S+))?\s+\S+$');

class LinuxArpResolver implements ArpResolver {
  const LinuxArpResolver({required this._runProcess});

  final ArpProcessRunner _runProcess;

  @override
  Future<ArpEntry?> resolve(String ip) async {
    final ProcessResult result;
    try {
      result = await _runProcess('ip', ['neigh', 'show']);
    } catch (e) {
      throw ArpCommandFailure('could not run the ip neigh command: $e');
    }

    if (result.exitCode != 0) {
      throw ArpCommandFailure(
        'ip neigh exited with code ${result.exitCode}: ${result.stderr}',
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
}
