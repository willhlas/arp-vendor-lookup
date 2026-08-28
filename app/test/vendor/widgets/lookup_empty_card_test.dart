import 'package:arp_vendor_lookup/l10n/l10n.dart';
import 'package:arp_vendor_lookup/vendor/vendor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group(LookupEmptyCard, () {
    testWidgets('renders the empty-state copy', (tester) async {
      await tester.pumpApp(const LookupEmptyCard());

      final context = tester.element(find.byType(LookupEmptyCard));
      final l10n = context.l10n;

      expect(find.text(l10n.emptyStateTitle), findsOneWidget);
      expect(find.text(l10n.emptyStateBody), findsOneWidget);
    });
  });
}
