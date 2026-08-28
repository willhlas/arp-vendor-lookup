import 'package:arp_vendor_lookup/l10n/l10n.dart';
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
  group(LookupUnknownVendorCard, () {
    testWidgets(
      'renders the ip, mac, no-vendor-match text, and unknown badge',
      (tester) async {
        final vendorBloc = _MockVendorBloc();
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

        await tester.pumpApp(
          const LookupUnknownVendorCard(),
          vendorBloc: vendorBloc,
        );

        final context = tester.element(find.byType(LookupUnknownVendorCard));
        final l10n = context.l10n;

        expect(find.text('10.0.0.5'), findsOneWidget);
        expect(find.text('11:22:33:44:55:66'), findsOneWidget);
        expect(find.text(l10n.noVendorMatchText), findsOneWidget);
        expect(
          find.text(l10n.unknownVendorBadgeLabel.toUpperCase()),
          findsOneWidget,
        );
      },
    );
  });
}
