import 'package:arp_vendor_lookup/l10n/l10n.dart';
import 'package:arp_vendor_lookup/vendor/vendor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vendor_api_client/vendor_api_client.dart';

import '../../helpers/pump_app.dart';

void main() {
  group(RecentLookupRow, () {
    testWidgets('renders IP, MAC, and vendor name when found', (
      tester,
    ) async {
      final lookup = Lookup(
        id: 1,
        mac: 'aa:bb:cc:dd:ee:ff',
        ip: '192.168.1.24',
        vendorName: 'Acme Corp',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );

      await tester.pumpApp(RecentLookupRow(lookup: lookup));

      expect(find.text('192.168.1.24'), findsOneWidget);
      expect(find.text('aa:bb:cc:dd:ee:ff'), findsOneWidget);
      expect(find.text('Acme Corp'), findsOneWidget);
    });

    testWidgets('renders the unknown-vendor label when not found', (
      tester,
    ) async {
      final lookup = Lookup(
        id: 2,
        mac: '11:22:33:44:55:66',
        ip: '10.0.0.5',
        vendorName: null,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );

      await tester.pumpApp(RecentLookupRow(lookup: lookup));

      final context = tester.element(find.byType(RecentLookupRow));
      final l10n = context.l10n;

      expect(find.text(l10n.unknownVendorRowText), findsOneWidget);
    });
  });
}
