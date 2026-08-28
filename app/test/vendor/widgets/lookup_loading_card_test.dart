import 'package:arp_vendor_lookup/l10n/l10n.dart';
import 'package:arp_vendor_lookup/vendor/vendor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group(LookupLoadingCard, () {
    testWidgets('renders a spinner and the loading copy', (tester) async {
      await tester.pumpApp(const LookupLoadingCard());

      final context = tester.element(find.byType(LookupLoadingCard));
      final l10n = context.l10n;

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text(l10n.loadingStateText), findsOneWidget);
    });
  });
}
