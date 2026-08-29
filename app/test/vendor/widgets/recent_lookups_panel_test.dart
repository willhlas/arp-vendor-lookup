import 'package:arp_vendor_lookup/l10n/l10n.dart';
import 'package:arp_vendor_lookup/vendor/vendor.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vendor_api_client/vendor_api_client.dart';

import '../../helpers/pump_app.dart';

class _MockVendorBloc extends MockBloc<VendorEvent, VendorState>
    implements VendorBloc {}

void main() {
  group(RecentLookupsPanel, () {
    late VendorBloc vendorBloc;

    setUp(() {
      vendorBloc = _MockVendorBloc();
    });

    testWidgets('shows a loading indicator while loading', (tester) async {
      when(() => vendorBloc.state).thenReturn(
        const VendorState(recentStatus: RecentLookupsStatus.loading),
      );

      await tester.pumpApp(
        const RecentLookupsPanel(),
        vendorBloc: vendorBloc,
      );

      final context = tester.element(find.byType(RecentLookupsPanel));
      final l10n = context.l10n;

      expect(find.text(l10n.recentLookupsLoading), findsOneWidget);
    });

    testWidgets('shows an error message when loading recent lookups fails', (
      tester,
    ) async {
      when(() => vendorBloc.state).thenReturn(
        const VendorState(recentStatus: RecentLookupsStatus.error),
      );

      await tester.pumpApp(
        const RecentLookupsPanel(),
        vendorBloc: vendorBloc,
      );

      final context = tester.element(find.byType(RecentLookupsPanel));
      final l10n = context.l10n;

      expect(find.text(l10n.recentLookupsError), findsOneWidget);
    });

    testWidgets('shows the empty state when there are no recent lookups', (
      tester,
    ) async {
      when(() => vendorBloc.state).thenReturn(
        const VendorState(recentStatus: RecentLookupsStatus.success),
      );

      await tester.pumpApp(
        const RecentLookupsPanel(),
        vendorBloc: vendorBloc,
      );

      final context = tester.element(find.byType(RecentLookupsPanel));
      final l10n = context.l10n;

      expect(find.text(l10n.recentLookupsEmpty), findsOneWidget);
    });

    testWidgets('shows the count, column headers, and rows when populated', (
      tester,
    ) async {
      final lookups = [
        Lookup(
          id: 1,
          mac: 'aa:bb:cc:dd:ee:ff',
          ip: '192.168.1.24',
          vendorName: 'Acme Corp',
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        ),
        Lookup(
          id: 2,
          mac: '11:22:33:44:55:66',
          ip: '10.0.0.5',
          vendorName: null,
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        ),
      ];
      when(() => vendorBloc.state).thenReturn(
        VendorState(
          recentStatus: RecentLookupsStatus.success,
          recentLookups: lookups,
        ),
      );

      await tester.pumpApp(
        const RecentLookupsPanel(),
        vendorBloc: vendorBloc,
      );

      final context = tester.element(find.byType(RecentLookupsPanel));
      final l10n = context.l10n;

      expect(find.text(l10n.recentLookupsCount(2)), findsOneWidget);
      expect(find.text('192.168.1.24'), findsOneWidget);
      expect(find.text('aa:bb:cc:dd:ee:ff'), findsOneWidget);
      expect(find.text('Acme Corp'), findsOneWidget);
      expect(find.text('10.0.0.5'), findsOneWidget);
      expect(find.text('11:22:33:44:55:66'), findsOneWidget);
    });
  });
}
