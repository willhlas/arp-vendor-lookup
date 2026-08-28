import 'dart:io';

import 'package:arp_resolver/arp_resolver.dart';
import 'package:test/test.dart';

NetworkAddressLister _fakeLister(
  Future<List<InternetAddress>> Function() build,
) {
  return ({
    InternetAddressType type = InternetAddressType.any,
    bool includeLoopback = false,
    bool includeLinkLocal = false,
  }) => build();
}

void main() {
  group('SystemLocalNetworkInfo', () {
    test('returns the first address returned by the lister', () async {
      final info = SystemLocalNetworkInfo(
        listAddresses: _fakeLister(
          () async => [
            InternetAddress('192.168.1.42', type: InternetAddressType.IPv4),
          ],
        ),
      );

      final address = await info.primaryIPv4Address();

      expect(address, '192.168.1.42');
    });

    test('returns null when there are no active addresses', () async {
      final info = SystemLocalNetworkInfo(
        listAddresses: _fakeLister(() async => []),
      );

      final address = await info.primaryIPv4Address();

      expect(address, isNull);
    });

    test(
      'throws LocalNetworkInfoFailure when listing addresses fails',
      () async {
        final info = SystemLocalNetworkInfo(
          listAddresses: _fakeLister(() async => throw Exception('boom')),
        );

        expect(
          info.primaryIPv4Address(),
          throwsA(isA<LocalNetworkInfoFailure>()),
        );
      },
    );
  });
}
