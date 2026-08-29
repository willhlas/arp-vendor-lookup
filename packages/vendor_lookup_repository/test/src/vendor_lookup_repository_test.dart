import 'package:arp_resolver/arp_resolver.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:vendor_api_client/vendor_api_client.dart';
import 'package:vendor_lookup_repository/vendor_lookup_repository.dart';

class _MockArpResolver extends Mock implements ArpResolver {}

class _MockVendorApiClient extends Mock implements VendorApiClient {}

void main() {
  late ArpResolver arpResolver;
  late VendorApiClient vendorApiClient;
  late VendorLookupRepository repository;

  setUp(() {
    arpResolver = _MockArpResolver();
    vendorApiClient = _MockVendorApiClient();
    repository = VendorLookupRepository(
      arpResolver: arpResolver,
      vendorApiClient: vendorApiClient,
    );
  });

  const ip = '192.168.1.10';
  const mac = 'AA:BB:CC:DD:EE:FF';
  const entry = ArpEntry(ip: ip, mac: mac);

  final foundLookup = Lookup(
    id: 1,
    mac: mac,
    ip: ip,
    vendorName: 'Example Vendor',
    createdAt: DateTime.utc(2026, 8, 28),
    updatedAt: DateTime.utc(2026, 8, 28),
  );

  final notFoundLookup = Lookup(
    id: 2,
    mac: mac,
    ip: ip,
    vendorName: null,
    createdAt: DateTime.utc(2026, 8, 28),
    updatedAt: DateTime.utc(2026, 8, 28),
  );

  group('lookupByIp', () {
    test(
      'an ARP miss returns a result with no mac and skips the vendor API',
      () async {
        when(() => arpResolver.resolve(ip)).thenAnswer((_) async => null);

        final result = await repository.lookupByIp(ip);

        expect(result.mac, isNull);
        expect(result.vendorLookup, isNull);
        expect(result.arpMiss, isTrue);
        verifyNever(() => vendorApiClient.lookupByMac(any(), any()));
      },
    );

    test('an ArpCommandFailure is wrapped in an ArpLookupFailure', () async {
      when(
        () => arpResolver.resolve(ip),
      ).thenThrow(const ArpCommandFailure('could not run arp'));

      await expectLater(
        () => repository.lookupByIp(ip),
        throwsA(
          isA<ArpLookupFailure>().having(
            (e) => e.cause,
            'cause',
            isA<ArpCommandFailure>(),
          ),
        ),
      );
      verifyNever(() => vendorApiClient.lookupByMac(any(), any()));
    });

    test('an ArpParseFailure is wrapped in an ArpLookupFailure', () async {
      when(
        () => arpResolver.resolve(ip),
      ).thenThrow(const ArpParseFailure('unparseable output'));

      await expectLater(
        () => repository.lookupByIp(ip),
        throwsA(
          isA<ArpLookupFailure>().having(
            (e) => e.cause,
            'cause',
            isA<ArpParseFailure>(),
          ),
        ),
      );
    });

    test('a found vendor is reflected in the result', () async {
      when(() => arpResolver.resolve(ip)).thenAnswer((_) async => entry);
      when(
        () => vendorApiClient.lookupByMac(mac, ip),
      ).thenAnswer((_) async => foundLookup);

      final result = await repository.lookupByIp(ip);

      expect(result.mac, mac);
      expect(result.vendorLookup, foundLookup);
      expect(result.arpMiss, isFalse);
      expect(result.found, isTrue);
    });

    test(
      'an unknown vendor is reflected as found == false, not a failure',
      () async {
        when(() => arpResolver.resolve(ip)).thenAnswer((_) async => entry);
        when(
          () => vendorApiClient.lookupByMac(mac, ip),
        ).thenAnswer((_) async => notFoundLookup);

        final result = await repository.lookupByIp(ip);

        expect(result.arpMiss, isFalse);
        expect(result.found, isFalse);
      },
    );

    for (final failure in [
      const InvalidMacFailure('bad mac'),
      const UpstreamLookupFailure('upstream broke'),
      const UpstreamUnavailableFailure('upstream unreachable'),
      const RateLimitedFailure('rate limited'),
      const NetworkFailure('unreachable'),
      const UnexpectedResponseFailure(500, 'unexpected'),
    ]) {
      test(
        '${failure.runtimeType} from the vendor API is wrapped in a '
        'VendorApiLookupFailure',
        () async {
          when(() => arpResolver.resolve(ip)).thenAnswer((_) async => entry);
          when(() => vendorApiClient.lookupByMac(mac, ip)).thenThrow(failure);

          await expectLater(
            () => repository.lookupByIp(ip),
            throwsA(
              isA<VendorApiLookupFailure>().having(
                (e) => e.cause,
                'cause',
                same(failure),
              ),
            ),
          );
        },
      );
    }
  });

  group('recentLookups', () {
    test('returns the list the vendor API returns', () async {
      when(
        () => vendorApiClient.recentLookups(),
      ).thenAnswer((_) async => [foundLookup, notFoundLookup]);

      final lookups = await repository.recentLookups();

      expect(lookups, [foundLookup, notFoundLookup]);
    });

    test('a NetworkFailure is wrapped in a VendorApiLookupFailure', () async {
      when(
        () => vendorApiClient.recentLookups(),
      ).thenThrow(const NetworkFailure('unreachable'));

      await expectLater(
        () => repository.recentLookups(),
        throwsA(isA<VendorApiLookupFailure>()),
      );
    });

    test(
      'an UnexpectedResponseFailure is wrapped in a VendorApiLookupFailure',
      () async {
        when(
          () => vendorApiClient.recentLookups(),
        ).thenThrow(const UnexpectedResponseFailure(500, 'unexpected'));

        await expectLater(
          () => repository.recentLookups(),
          throwsA(isA<VendorApiLookupFailure>()),
        );
      },
    );
  });
}
