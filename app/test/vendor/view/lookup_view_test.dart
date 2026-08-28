import 'package:arp_vendor_lookup/vendor/vendor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group(LookupView, () {
    testWidgets('renders LookupSection and RecentLookupsPanel', (
      tester,
    ) async {
      await tester.pumpApp(const LookupView());

      expect(find.byType(LookupSection), findsOneWidget);
      expect(find.byType(RecentLookupsPanel), findsOneWidget);
    });
  });
}
