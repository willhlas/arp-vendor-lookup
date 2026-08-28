import 'package:arp_resolver/arp_resolver.dart';
import 'package:arp_vendor_lookup/vendor/vendor.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vendor_api_client/vendor_api_client.dart';
import 'package:vendor_lookup_repository/vendor_lookup_repository.dart';

class _MockVendorLookupRepository extends Mock
    implements VendorLookupRepository {}

class _MockLocalNetworkInfo extends Mock implements LocalNetworkInfo {}

void main() {
  group(VendorBloc, () {
    final foundResult = VendorLookupResult(
      ip: '192.168.1.1',
      mac: 'aa:bb:cc:dd:ee:ff',
      vendorLookup: Lookup(
        id: 1,
        mac: 'aa:bb:cc:dd:ee:ff',
        vendorName: 'Acme Corp',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
    );

    const arpMissResult = VendorLookupResult(
      ip: '192.168.1.2',
      mac: null,
      vendorLookup: null,
    );

    final notFoundResult = VendorLookupResult(
      ip: '192.168.1.3',
      mac: '11:22:33:44:55:66',
      vendorLookup: Lookup(
        id: 2,
        mac: '11:22:33:44:55:66',
        vendorName: null,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
    );

    late VendorLookupRepository vendorLookupRepository;
    late LocalNetworkInfo localNetworkInfo;
    late VendorBloc vendorBloc;

    setUp(() {
      vendorLookupRepository = _MockVendorLookupRepository();
      localNetworkInfo = _MockLocalNetworkInfo();
      vendorBloc = VendorBloc(
        vendorLookupRepository: vendorLookupRepository,
        localNetworkInfo: localNetworkInfo,
      );

      when(
        () => vendorLookupRepository.recentLookups(),
      ).thenAnswer((_) async => []);
    });

    test('can be instantiated', () {
      expect(
        VendorBloc(
          vendorLookupRepository: vendorLookupRepository,
          localNetworkInfo: localNetworkInfo,
        ),
        isNotNull,
      );
    });

    group('on VendorLookupRequested', () {
      blocTest<VendorBloc, VendorState>(
        'emits [loading, success] with a found vendor and refreshes recent '
        'lookups',
        setUp: () {
          when(
            () => vendorLookupRepository.lookupByIp('192.168.1.1'),
          ).thenAnswer((_) async => foundResult);
        },
        build: () => vendorBloc,
        act: (bloc) => bloc.add(const VendorLookupRequested('192.168.1.1')),
        expect: () => [
          const VendorState(
            lookupStatus: VendorLookupStatus.loading,
          ),
          VendorState(
            lookupStatus: VendorLookupStatus.success,
            result: foundResult,
          ),
          VendorState(
            lookupStatus: VendorLookupStatus.success,
            result: foundResult,
            recentStatus: RecentLookupsStatus.loading,
          ),
          VendorState(
            lookupStatus: VendorLookupStatus.success,
            result: foundResult,
            recentStatus: RecentLookupsStatus.success,
          ),
        ],
        verify: (_) {
          verify(() => vendorLookupRepository.recentLookups()).called(1);
        },
      );

      blocTest<VendorBloc, VendorState>(
        'emits a success state with isArpMiss true on an ARP miss',
        setUp: () {
          when(
            () => vendorLookupRepository.lookupByIp('192.168.1.2'),
          ).thenAnswer((_) async => arpMissResult);
        },
        build: () => vendorBloc,
        act: (bloc) => bloc.add(const VendorLookupRequested('192.168.1.2')),
        expect: () => [
          const VendorState(
            lookupStatus: VendorLookupStatus.loading,
          ),
          const VendorState(
            lookupStatus: VendorLookupStatus.success,
            result: arpMissResult,
          ),
          const VendorState(
            lookupStatus: VendorLookupStatus.success,
            result: arpMissResult,
            recentStatus: RecentLookupsStatus.loading,
          ),
          const VendorState(
            lookupStatus: VendorLookupStatus.success,
            result: arpMissResult,
            recentStatus: RecentLookupsStatus.success,
          ),
        ],
        verify: (bloc) {
          expect(bloc.state.isArpMiss, isTrue);
          expect(bloc.state.isVendorFound, isFalse);
        },
      );

      blocTest<VendorBloc, VendorState>(
        'emits a success state with isVendorFound false when the MAC has no '
        'known vendor',
        setUp: () {
          when(
            () => vendorLookupRepository.lookupByIp('192.168.1.3'),
          ).thenAnswer((_) async => notFoundResult);
        },
        build: () => vendorBloc,
        act: (bloc) => bloc.add(const VendorLookupRequested('192.168.1.3')),
        verify: (bloc) {
          expect(bloc.state.isArpMiss, isFalse);
          expect(bloc.state.isVendorFound, isFalse);
        },
      );

      for (final (failure, cause, expectedKind) in [
        (
          const ArpLookupFailure(
            'arp command failed',
            ArpCommandFailure('boom'),
          ),
          'ArpCommandFailure',
          VendorLookupErrorKind.arpCommandFailed,
        ),
        (
          const ArpLookupFailure(
            'arp output unparseable',
            ArpParseFailure('boom'),
          ),
          'ArpParseFailure',
          VendorLookupErrorKind.arpOutputUnparseable,
        ),
        (
          const VendorApiLookupFailure(
            'vendor api unreachable',
            NetworkFailure('boom'),
          ),
          'NetworkFailure',
          VendorLookupErrorKind.networkUnreachable,
        ),
        (
          const VendorApiLookupFailure(
            'upstream unavailable',
            UpstreamUnavailableFailure('boom'),
          ),
          'UpstreamUnavailableFailure',
          VendorLookupErrorKind.upstreamUnavailable,
        ),
        (
          const VendorApiLookupFailure(
            'upstream bad response',
            UpstreamLookupFailure('boom'),
          ),
          'UpstreamLookupFailure',
          VendorLookupErrorKind.upstreamBadResponse,
        ),
        (
          const VendorApiLookupFailure(
            'rate limited',
            RateLimitedFailure('boom'),
          ),
          'RateLimitedFailure',
          VendorLookupErrorKind.rateLimited,
        ),
        (
          const VendorApiLookupFailure(
            'invalid mac',
            InvalidMacFailure('boom'),
          ),
          'InvalidMacFailure',
          VendorLookupErrorKind.invalidMac,
        ),
        (
          const VendorApiLookupFailure(
            'unexpected response',
            UnexpectedResponseFailure(500, 'boom'),
          ),
          'UnexpectedResponseFailure',
          VendorLookupErrorKind.unexpectedResponse,
        ),
      ]) {
        blocTest<VendorBloc, VendorState>(
          'emits [loading, error] with kind $expectedKind when the '
          'repository throws a failure caused by $cause',
          setUp: () {
            when(
              () => vendorLookupRepository.lookupByIp('192.168.1.1'),
            ).thenThrow(failure);
          },
          build: () => vendorBloc,
          act: (bloc) => bloc.add(const VendorLookupRequested('192.168.1.1')),
          expect: () => [
            const VendorState(
              lookupStatus: VendorLookupStatus.loading,
            ),
            VendorState(
              lookupStatus: VendorLookupStatus.error,
              lookupErrorMessage: failure.message,
              lookupErrorKind: expectedKind,
            ),
          ],
        );
      }

      blocTest<VendorBloc, VendorState>(
        'emits a recentStatus error when recentLookups() throws',
        setUp: () {
          when(() => vendorLookupRepository.recentLookups()).thenThrow(
            const VendorApiLookupFailure('could not fetch recent lookups', 'x'),
          );
        },
        build: () => vendorBloc,
        act: (bloc) => bloc.add(const VendorRecentLookupsRequested()),
        expect: () => [
          const VendorState(recentStatus: RecentLookupsStatus.loading),
          const VendorState(
            recentStatus: RecentLookupsStatus.error,
            recentErrorMessage: 'could not fetch recent lookups',
          ),
        ],
      );
    });

    group('on VendorLocalIpDetectionRequested', () {
      blocTest<VendorBloc, VendorState>(
        'emits [loading, success] with the detected ip',
        setUp: () {
          when(
            localNetworkInfo.primaryIPv4Address,
          ).thenAnswer((_) async => '192.168.1.50');
        },
        build: () => vendorBloc,
        act: (bloc) => bloc.add(const VendorLocalIpDetectionRequested()),
        expect: () => [
          const VendorState(
            localIpDetectionStatus: LocalIpDetectionStatus.loading,
          ),
          const VendorState(
            localIpDetectionStatus: LocalIpDetectionStatus.success,
            detectedLocalIp: '192.168.1.50',
          ),
        ],
      );

      blocTest<VendorBloc, VendorState>(
        'emits [loading, error] when no active interface has an address',
        setUp: () {
          when(
            localNetworkInfo.primaryIPv4Address,
          ).thenAnswer((_) async => null);
        },
        build: () => vendorBloc,
        act: (bloc) => bloc.add(const VendorLocalIpDetectionRequested()),
        expect: () => [
          const VendorState(
            localIpDetectionStatus: LocalIpDetectionStatus.loading,
          ),
          const VendorState(
            localIpDetectionStatus: LocalIpDetectionStatus.error,
            localIpDetectionErrorMessage: 'no active network interface found',
          ),
        ],
      );

      blocTest<VendorBloc, VendorState>(
        'emits [loading, error] when listing interfaces throws',
        setUp: () {
          when(localNetworkInfo.primaryIPv4Address).thenThrow(
            const LocalNetworkInfoFailure('could not list interfaces'),
          );
        },
        build: () => vendorBloc,
        act: (bloc) => bloc.add(const VendorLocalIpDetectionRequested()),
        expect: () => [
          const VendorState(
            localIpDetectionStatus: LocalIpDetectionStatus.loading,
          ),
          const VendorState(
            localIpDetectionStatus: LocalIpDetectionStatus.error,
            localIpDetectionErrorMessage: 'could not list interfaces',
          ),
        ],
      );
    });
  });
}
