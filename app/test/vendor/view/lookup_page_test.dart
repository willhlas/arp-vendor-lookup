import 'package:arp_vendor_lookup/l10n/l10n.dart';
import 'package:arp_vendor_lookup/vendor/vendor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group(LookupPage, () {
    testWidgets('renders the header title, subtitle, and LookupView', (
      tester,
    ) async {
      await tester.pumpApp(const LookupPage());

      final context = tester.element(find.byType(LookupPage));
      final l10n = context.l10n;

      expect(find.text(l10n.appTitle), findsOneWidget);
      expect(find.text(l10n.appSubtitle), findsOneWidget);
      expect(find.byType(LookupView), findsOneWidget);
    });
  });
}
