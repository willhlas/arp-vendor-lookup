import 'package:arp_vendor_lookup/vendor/vendor.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vendor_api_client/vendor_api_client.dart';
import 'package:vendor_lookup_repository/vendor_lookup_repository.dart';

import '../../helpers/pump_app.dart';

class _MockVendorBloc extends MockBloc<VendorEvent, VendorState>
    implements VendorBloc {}

void main() {
  group(LookupResultSection, () {
    late VendorBloc vendorBloc;

    setUp(() {
      vendorBloc = _MockVendorBloc();
    });

    testWidgets('renders LookupEmptyCard when initial', (tester) async {
      when(() => vendorBloc.state).thenReturn(const VendorState());

      await tester.pumpApp(const LookupResultSection(), vendorBloc: vendorBloc);

      expect(find.byType(LookupEmptyCard), findsOneWidget);
    });

    testWidgets('renders LookupLoadingCard when loading', (tester) async {
      when(() => vendorBloc.state).thenReturn(
        const VendorState(lookupStatus: VendorLookupStatus.loading),
      );

      await tester.pumpApp(const LookupResultSection(), vendorBloc: vendorBloc);

      expect(find.byType(LookupLoadingCard), findsOneWidget);
    });

    testWidgets('renders LookupErrorCard when error', (tester) async {
      when(() => vendorBloc.state).thenReturn(
        const VendorState(
          lookupStatus: VendorLookupStatus.error,
          lookupErrorMessage: 'boom',
        ),
      );

      await tester.pumpApp(const LookupResultSection(), vendorBloc: vendorBloc);

      expect(find.byType(LookupErrorCard), findsOneWidget);
      expect(find.text('boom'), findsOneWidget);
    });

    testWidgets('renders LookupArpMissCard on an ARP miss', (tester) async {
      when(() => vendorBloc.state).thenReturn(
        const VendorState(
          lookupStatus: VendorLookupStatus.success,
          result: VendorLookupResult(
            ip: '10.0.0.51',
            mac: null,
            vendorLookup: null,
          ),
        ),
      );

      await tester.pumpApp(const LookupResultSection(), vendorBloc: vendorBloc);

      expect(find.byType(LookupArpMissCard), findsOneWidget);
    });

    testWidgets('renders LookupUnknownVendorCard when the vendor is unknown', (
      tester,
    ) async {
      when(() => vendorBloc.state).thenReturn(
        VendorState(
          lookupStatus: VendorLookupStatus.success,
          result: VendorLookupResult(
            ip: '10.0.0.5',
            mac: '11:22:33:44:55:66',
            vendorLookup: Lookup(
              id: 1,
              mac: '11:22:33:44:55:66',
              vendorName: null,
              createdAt: DateTime(2026),
              updatedAt: DateTime(2026),
            ),
          ),
        ),
      );

      await tester.pumpApp(const LookupResultSection(), vendorBloc: vendorBloc);

      expect(find.byType(LookupUnknownVendorCard), findsOneWidget);
    });

    testWidgets('renders LookupResolvedCard when the vendor is found', (
      tester,
    ) async {
      when(() => vendorBloc.state).thenReturn(
        VendorState(
          lookupStatus: VendorLookupStatus.success,
          result: VendorLookupResult(
            ip: '192.168.1.24',
            mac: 'aa:bb:cc:dd:ee:ff',
            vendorLookup: Lookup(
              id: 2,
              mac: 'aa:bb:cc:dd:ee:ff',
              vendorName: 'Acme Corp',
              createdAt: DateTime(2026),
              updatedAt: DateTime(2026),
            ),
          ),
        ),
      );

      await tester.pumpApp(const LookupResultSection(), vendorBloc: vendorBloc);

      expect(find.byType(LookupResolvedCard), findsOneWidget);
      expect(find.text('Acme Corp'), findsOneWidget);
    });
  });
}
