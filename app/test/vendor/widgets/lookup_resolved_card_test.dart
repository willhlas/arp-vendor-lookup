import 'package:app_ui/app_ui.dart';
import 'package:arp_vendor_lookup/l10n/l10n.dart';
import 'package:arp_vendor_lookup/vendor/vendor.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vendor_api_client/vendor_api_client.dart';
import 'package:vendor_lookup_repository/vendor_lookup_repository.dart';

import '../../helpers/pump_app.dart';

class _MockVendorBloc extends MockBloc<VendorEvent, VendorState>
    implements VendorBloc {}

void main() {
  group(LookupResolvedCard, () {
    testWidgets('renders the ip, mac, vendor, and resolved badge', (
      tester,
    ) async {
      final vendorBloc = _MockVendorBloc();
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

      await tester.pumpApp(const LookupResolvedCard(), vendorBloc: vendorBloc);

      final context = tester.element(find.byType(LookupResolvedCard));
      final l10n = context.l10n;

      expect(find.text('192.168.1.24'), findsOneWidget);
      expect(find.text('aa:bb:cc:dd:ee:ff'), findsOneWidget);
      expect(find.text('Acme Corp'), findsOneWidget);
      expect(
        find.text(l10n.resolvedBadgeLabel.toUpperCase()),
        findsOneWidget,
      );

      final swatch = tester.widget<Container>(
        find.descendant(
          of: find.byType(AppLabelValueRow).last,
          matching: find.byType(Container),
        ),
      );
      final decoration = swatch.decoration! as BoxDecoration;
      expect(decoration.color, vendorSwatchColor('Acme Corp'));
    });
  });
}
