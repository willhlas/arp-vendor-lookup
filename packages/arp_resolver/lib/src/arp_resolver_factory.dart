// coverage:ignore-file

import 'dart:io';

import 'package:arp_resolver/arp_resolver.dart';

ArpResolver createArpResolver() {
  if (Platform.isMacOS) {
    return const MacosArpResolver(runProcess: Process.run);
  }
  if (Platform.isLinux) {
    return const LinuxArpResolver(runProcess: Process.run);
  }
  if (Platform.isWindows) {
    return const WindowsArpResolver(runProcess: Process.run);
  }
  throw UnsupportedError(
    'ArpResolver is only implemented for macOS, Linux, and Windows',
  );
}
