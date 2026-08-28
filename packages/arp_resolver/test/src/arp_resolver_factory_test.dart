import 'package:arp_resolver/arp_resolver.dart';
import 'package:test/test.dart';

void main() {
  group('createArpResolver', () {
    test('returns a MacosArpResolver on macOS', () {
      final resolver = createArpResolver();

      expect(resolver, isA<MacosArpResolver>());
    }, testOn: 'mac-os');

    test('returns a LinuxArpResolver on Linux', () {
      final resolver = createArpResolver();

      expect(resolver, isA<LinuxArpResolver>());
    }, testOn: 'linux');

    test('returns a WindowsArpResolver on Windows', () {
      final resolver = createArpResolver();

      expect(resolver, isA<WindowsArpResolver>());
    }, testOn: 'windows');
  });
}
