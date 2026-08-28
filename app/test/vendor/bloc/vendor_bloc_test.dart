import 'package:arp_vendor_lookup/vendor/vendor.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vendor_api_client/vendor_api_client.dart';
import 'package:vendor_lookup_repository/vendor_lookup_repository.dart';

class _MockVendorLookupRepository extends Mock
    implements VendorLookupRepository {}

void main() {
  group(VendorBloc, () {
    late VendorLookupRepository vendorLookupRepository;

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

    setUp(() {
      vendorLookupRepository = _MockVendorLookupRepository();
      when(
        () => vendorLookupRepository.recentLookups(),
      ).thenAnswer((_) async => []);
    });

    VendorBloc buildBloc() =>
        VendorBloc(vendorLookupRepository: vendorLookupRepository);

    test('emits VendorState() as the seed state', () {
      expect(buildBloc().state, const VendorState());
    });

    blocTest<VendorBloc, VendorState>(
      'dispatches VendorRecentLookupsRequested on construction and loads '
      'recent lookups',
      setUp: () {
        when(
          () => vendorLookupRepository.recentLookups(),
        ).thenAnswer((_) async => [foundResult.vendorLookup!]);
      },
      build: buildBloc,
      expect: () => [
        const VendorState(recentStatus: RecentLookupsStatus.loading),
        VendorState(
          recentStatus: RecentLookupsStatus.success,
          recentLookups: [foundResult.vendorLookup!],
        ),
      ],
      verify: (_) {
        verify(() => vendorLookupRepository.recentLookups()).called(1);
      },
    );

    // The bloc's constructor self-dispatches VendorRecentLookupsRequested,
    // which races with any event added immediately by `act`. Awaiting a
    // beat before adding the lookup event lets that initial load settle
    // first, so its 2 states (skip: 2) land deterministically before the
    // lookup-triggered ones this test actually cares about.
    Future<void> settleInitialLoad() => Future<void>.delayed(Duration.zero);

    blocTest<VendorBloc, VendorState>(
      'emits [loading, success] with a found vendor and refreshes recent '
      'lookups',
      setUp: () {
        when(
          () => vendorLookupRepository.lookupByIp('192.168.1.1'),
        ).thenAnswer((_) async => foundResult);
      },
      build: buildBloc,
      act: (bloc) async {
        await settleInitialLoad();
        bloc.add(const VendorLookupRequested('192.168.1.1'));
      },
      skip: 2,
      expect: () => [
        const VendorState(
          lookupStatus: VendorLookupStatus.loading,
          recentStatus: RecentLookupsStatus.success,
        ),
        VendorState(
          lookupStatus: VendorLookupStatus.success,
          result: foundResult,
          recentStatus: RecentLookupsStatus.success,
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
        verify(() => vendorLookupRepository.recentLookups()).called(2);
      },
    );

    blocTest<VendorBloc, VendorState>(
      'emits a success state with isArpMiss true on an ARP miss',
      setUp: () {
        when(
          () => vendorLookupRepository.lookupByIp('192.168.1.2'),
        ).thenAnswer((_) async => arpMissResult);
      },
      build: buildBloc,
      act: (bloc) async {
        await settleInitialLoad();
        bloc.add(const VendorLookupRequested('192.168.1.2'));
      },
      skip: 2,
      expect: () => [
        const VendorState(
          lookupStatus: VendorLookupStatus.loading,
          recentStatus: RecentLookupsStatus.success,
        ),
        const VendorState(
          lookupStatus: VendorLookupStatus.success,
          result: arpMissResult,
          recentStatus: RecentLookupsStatus.success,
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
      build: buildBloc,
      act: (bloc) async {
        await settleInitialLoad();
        bloc.add(const VendorLookupRequested('192.168.1.3'));
      },
      verify: (bloc) {
        expect(bloc.state.isArpMiss, isFalse);
        expect(bloc.state.isVendorFound, isFalse);
      },
    );

    blocTest<VendorBloc, VendorState>(
      'emits [loading, error] when the repository throws ArpLookupFailure',
      setUp: () {
        when(
          () => vendorLookupRepository.lookupByIp('192.168.1.1'),
        ).thenThrow(const ArpLookupFailure('arp command failed', 'boom'));
      },
      build: buildBloc,
      act: (bloc) async {
        await settleInitialLoad();
        bloc.add(const VendorLookupRequested('192.168.1.1'));
      },
      skip: 2,
      expect: () => [
        const VendorState(
          lookupStatus: VendorLookupStatus.loading,
          recentStatus: RecentLookupsStatus.success,
        ),
        const VendorState(
          lookupStatus: VendorLookupStatus.error,
          lookupErrorMessage: 'arp command failed',
          recentStatus: RecentLookupsStatus.success,
        ),
      ],
    );

    blocTest<VendorBloc, VendorState>(
      'emits [loading, error] when the repository throws '
      'VendorApiLookupFailure',
      setUp: () {
        when(
          () => vendorLookupRepository.lookupByIp('192.168.1.1'),
        ).thenThrow(
          const VendorApiLookupFailure('vendor api unreachable', 'boom'),
        );
      },
      build: buildBloc,
      act: (bloc) async {
        await settleInitialLoad();
        bloc.add(const VendorLookupRequested('192.168.1.1'));
      },
      skip: 2,
      expect: () => [
        const VendorState(
          lookupStatus: VendorLookupStatus.loading,
          recentStatus: RecentLookupsStatus.success,
        ),
        const VendorState(
          lookupStatus: VendorLookupStatus.error,
          lookupErrorMessage: 'vendor api unreachable',
          recentStatus: RecentLookupsStatus.success,
        ),
      ],
    );

    blocTest<VendorBloc, VendorState>(
      'emits a recentStatus error when recentLookups() throws',
      setUp: () {
        when(() => vendorLookupRepository.recentLookups()).thenThrow(
          const VendorApiLookupFailure('could not fetch recent lookups', 'x'),
        );
      },
      build: buildBloc,
      skip: 1,
      expect: () => [
        const VendorState(
          recentStatus: RecentLookupsStatus.error,
          recentErrorMessage: 'could not fetch recent lookups',
        ),
      ],
    );
  });
}
