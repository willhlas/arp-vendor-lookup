import 'package:arp_vendor_lookup/l10n/l10n.dart';
import 'package:arp_vendor_lookup/vendor/vendor.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/pump_app.dart';

class _MockVendorBloc extends MockBloc<VendorEvent, VendorState>
    implements VendorBloc {}

void main() {
  group(LookupSection, () {
    late VendorBloc vendorBloc;

    setUpAll(() {
      registerFallbackValue(const VendorRecentLookupsRequested());
    });

    setUp(() {
      vendorBloc = _MockVendorBloc();

      when(() => vendorBloc.state).thenReturn(const VendorState());
    });

    testWidgets(
      'shows an invalid-IP error card and never dispatches for a '
      'malformed IP',
      (tester) async {
        await tester.pumpApp(const LookupSection(), vendorBloc: vendorBloc);

        await tester.enterText(find.byType(TextField), '999.1.1.1');

        final context = tester.element(find.byType(LookupSection));
        final l10n = context.l10n;

        await tester.tap(find.text(l10n.lookupButtonLabel));
        await tester.pump();

        expect(find.text(l10n.invalidIpTitle), findsOneWidget);
        verifyNever(() => vendorBloc.add(any()));
      },
    );

    testWidgets('dispatches VendorLookupRequested for a valid IP', (
      tester,
    ) async {
      await tester.pumpApp(const LookupSection(), vendorBloc: vendorBloc);

      await tester.enterText(find.byType(TextField), '192.168.1.1');

      final context = tester.element(find.byType(LookupSection));
      final l10n = context.l10n;

      await tester.tap(find.text(l10n.lookupButtonLabel));
      await tester.pump();

      verify(
        () => vendorBloc.add(const VendorLookupRequested('192.168.1.1')),
      ).called(1);
      expect(find.text(l10n.invalidIpTitle), findsNothing);
    });
  });
}
