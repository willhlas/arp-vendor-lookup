import 'dart:io';

import 'package:arp_resolver/arp_resolver.dart';
import 'package:platform/platform.dart';

ArpResolver createArpResolver({Platform platform = const LocalPlatform()}) {
  if (platform.isMacOS) {
    return const MacosArpResolver(runProcess: Process.run);
  }
  if (platform.isLinux) {
    return const LinuxArpResolver(runProcess: Process.run);
  }
  if (platform.isWindows) {
    return const WindowsArpResolver(runProcess: Process.run);
  }
  throw UnsupportedError(
    'ArpResolver is only implemented for macOS, Linux, and Windows',
  );
}
