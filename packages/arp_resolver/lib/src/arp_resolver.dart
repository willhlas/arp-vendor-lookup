import 'dart:io';

import 'package:arp_resolver/arp_resolver.dart';

/// Runs an external process and returns its result, matching the shape of
/// [Process.run]. Injected so tests can stub process invocation without
/// spawning a real `arp` process.
typedef ArpProcessRunner =
    Future<ProcessResult> Function(
      String executable,
      List<String> arguments,
    );

abstract class ArpResolver {
  /// Returns the [ArpEntry] for [ip], or `null` if the local ARP table has
  /// no entry for [ip] (including an `(incomplete)` entry with no resolved
  /// MAC yet) — this is a normal, expected result, not a failure.
  ///
  /// [ip] is trusted as-is and not validated: a malformed [ip] simply
  /// won't match any ARP table entry and resolves to `null`.
  ///
  /// Throws [ArpCommandFailure] if the OS command used to read the ARP
  /// table could not be run, or exited with a failing status. Throws
  /// [ArpParseFailure] if the command ran but its output could not be
  /// parsed at all.
  Future<ArpEntry?> resolve(String ip);

  /// Parses the output of the ARP command for the given IP address.
  ArpEntry? parseArpOutput(String output, String ip);
}
