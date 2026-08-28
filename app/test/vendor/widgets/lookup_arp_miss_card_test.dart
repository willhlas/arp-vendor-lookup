import 'package:arp_vendor_lookup/l10n/l10n.dart';
import 'package:arp_vendor_lookup/vendor/vendor.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vendor_lookup_repository/vendor_lookup_repository.dart';

import '../../helpers/pump_app.dart';

class _MockVendorBloc extends MockBloc<VendorEvent, VendorState>
    implements VendorBloc {}

void main() {
  group(LookupArpMissCard, () {
    testWidgets('renders the ip and the no-ARP-entry badge and explanation', (
      tester,
    ) async {
      final vendorBloc = _MockVendorBloc();
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

      await tester.pumpApp(const LookupArpMissCard(), vendorBloc: vendorBloc);

      final context = tester.element(find.byType(LookupArpMissCard));
      final l10n = context.l10n;

      expect(find.text('10.0.0.51'), findsOneWidget);
      expect(
        find.text(l10n.noArpEntryBadgeLabel.toUpperCase()),
        findsOneWidget,
      );
      expect(find.text(l10n.noArpEntryExplanation), findsOneWidget);
    });
  });
}
