import 'package:arp_resolver/arp_resolver.dart';
import 'package:platform/platform.dart';
import 'package:test/test.dart';

void main() {
  group('createArpResolver', () {
    test(
      'returns a MacosArpResolver on macOS',
      () {
        final platform = FakePlatform(operatingSystem: Platform.macOS);
        final resolver = createArpResolver(platform: platform);

        expect(resolver, isA<MacosArpResolver>());
      },
    );

    test(
      'returns a LinuxArpResolver on Linux',
      () {
        final platform = FakePlatform(operatingSystem: Platform.linux);
        final resolver = createArpResolver(platform: platform);

        expect(resolver, isA<LinuxArpResolver>());
      },
    );

    test(
      'returns a WindowsArpResolver on Windows',
      () {
        final platform = FakePlatform(operatingSystem: Platform.windows);
        final resolver = createArpResolver(platform: platform);

        expect(resolver, isA<WindowsArpResolver>());
      },
    );

    test('throws $UnsupportedError on unsupported platforms', () {
      final platform = FakePlatform(operatingSystem: 'unsupported');
      expect(
        () => createArpResolver(platform: platform),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });
}
