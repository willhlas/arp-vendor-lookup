import 'package:arp_vendor_lookup/l10n/l10n.dart';
import 'package:arp_vendor_lookup/vendor/vendor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group(LookupFormCard, () {
    late TextEditingController controller;
    var submitCount = 0;

    setUp(() {
      controller = TextEditingController();
      submitCount = 0;
    });

    testWidgets('renders the heading, label, and helper text', (
      tester,
    ) async {
      await tester.pumpApp(
        LookupFormCard(
          controller: controller,
          onSubmit: () {},
          onUseMyIp: () {},
        ),
      );

      final context = tester.element(find.byType(LookupFormCard));
      final l10n = context.l10n;

      expect(find.text(l10n.lookupFormHeading), findsOneWidget);
      expect(find.text(l10n.lookupHelperText), findsOneWidget);
      expect(find.text(l10n.lookupButtonLabel), findsOneWidget);
      expect(find.text(l10n.useMyIpLabel), findsOneWidget);
    });

    testWidgets('invokes onSubmit when the button is tapped', (tester) async {
      await tester.pumpApp(
        LookupFormCard(
          controller: controller,
          onSubmit: () => submitCount++,
          onUseMyIp: () {},
        ),
      );

      final context = tester.element(find.byType(LookupFormCard));
      final l10n = context.l10n;

      await tester.tap(find.text(l10n.lookupButtonLabel));

      expect(submitCount, 1);
    });

    testWidgets('invokes onSubmit when the field is submitted', (
      tester,
    ) async {
      await tester.pumpApp(
        LookupFormCard(
          controller: controller,
          onSubmit: () => submitCount++,
          onUseMyIp: () {},
        ),
      );

      await tester.enterText(find.byType(TextField), '192.168.1.1');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      expect(submitCount, 1);
    });

    testWidgets('invokes onUseMyIp when the button is tapped', (tester) async {
      var useMyIpCount = 0;
      await tester.pumpApp(
        LookupFormCard(
          controller: controller,
          onSubmit: () {},
          onUseMyIp: () => useMyIpCount++,
        ),
      );

      final context = tester.element(find.byType(LookupFormCard));
      final l10n = context.l10n;

      await tester.tap(find.text(l10n.useMyIpLabel));

      expect(useMyIpCount, 1);
    });
  });
}
