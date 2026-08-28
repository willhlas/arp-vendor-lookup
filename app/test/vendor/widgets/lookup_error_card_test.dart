import 'package:arp_vendor_lookup/vendor/vendor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group(LookupErrorCard, () {
    testWidgets('renders the given title and body', (tester) async {
      await tester.pumpApp(
        const LookupErrorCard(title: 'Something went wrong', body: 'Details'),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Details'), findsOneWidget);
    });
  });
}
