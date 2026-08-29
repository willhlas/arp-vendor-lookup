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

    testWidgets('disables the lookup button while a lookup is loading', (
      tester,
    ) async {
      when(() => vendorBloc.state).thenReturn(
        const VendorState(lookupStatus: VendorLookupStatus.loading),
      );

      await tester.pumpApp(const LookupSection(), vendorBloc: vendorBloc);

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );

      expect(button.onPressed, isNull);
    });

    testWidgets(
      'dispatches VendorLocalIpDetectionRequested and clears an existing '
      'invalid-IP error when "Use my IP" is tapped',
      (tester) async {
        await tester.pumpApp(const LookupSection(), vendorBloc: vendorBloc);

        final context = tester.element(find.byType(LookupSection));
        final l10n = context.l10n;

        await tester.enterText(find.byType(TextField), '999.1.1.1');
        await tester.tap(find.text(l10n.lookupButtonLabel));
        await tester.pump();

        expect(find.text(l10n.invalidIpTitle), findsOneWidget);

        await tester.tap(find.text(l10n.useMyIpLabel));
        await tester.pump();

        verify(
          () => vendorBloc.add(const VendorLocalIpDetectionRequested()),
        ).called(1);
        expect(find.text(l10n.invalidIpTitle), findsNothing);
      },
    );

    testWidgets(
      'fills in the detected IP once local IP detection succeeds',
      (tester) async {
        whenListen(
          vendorBloc,
          Stream.fromIterable([
            const VendorState(
              localIpDetectionStatus: LocalIpDetectionStatus.loading,
            ),
            const VendorState(
              localIpDetectionStatus: LocalIpDetectionStatus.success,
              detectedLocalIp: '192.168.1.42',
            ),
          ]),
          initialState: const VendorState(),
        );

        await tester.pumpApp(const LookupSection(), vendorBloc: vendorBloc);
        await tester.pump();

        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.controller?.text, '192.168.1.42');
      },
    );

    testWidgets(
      'leaves the IP field untouched when local IP detection succeeds '
      'without a detected IP',
      (tester) async {
        whenListen(
          vendorBloc,
          Stream.fromIterable([
            const VendorState(
              localIpDetectionStatus: LocalIpDetectionStatus.loading,
            ),
            const VendorState(
              localIpDetectionStatus: LocalIpDetectionStatus.success,
            ),
          ]),
          initialState: const VendorState(),
        );

        await tester.pumpApp(const LookupSection(), vendorBloc: vendorBloc);
        await tester.pump();

        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.controller?.text, isEmpty);
      },
    );

    testWidgets(
      'shows a local-IP-detection error card when local IP detection fails',
      (tester) async {
        whenListen(
          vendorBloc,
          Stream.fromIterable([
            const VendorState(
              localIpDetectionStatus: LocalIpDetectionStatus.loading,
            ),
            const VendorState(
              localIpDetectionStatus: LocalIpDetectionStatus.error,
            ),
          ]),
          initialState: const VendorState(),
        );

        await tester.pumpApp(const LookupSection(), vendorBloc: vendorBloc);
        await tester.pump();

        final context = tester.element(find.byType(LookupSection));
        final l10n = context.l10n;

        expect(find.text(l10n.localIpDetectionErrorTitle), findsOneWidget);
        expect(find.text(l10n.localIpDetectionErrorBody), findsOneWidget);
      },
    );
  });
}
