import 'package:arp_vendor_lookup/app/app.dart';
import 'package:arp_vendor_lookup/vendor/vendor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vendor_lookup_repository/vendor_lookup_repository.dart';

import '../../helpers/helpers.dart';

class _MockVendorLookupRepository extends Mock
    implements VendorLookupRepository {}

void main() {
  group(App, () {
    late VendorLookupRepository vendorLookupRepository;

    setUp(() {
      vendorLookupRepository = _MockVendorLookupRepository();

      when(
        vendorLookupRepository.recentLookups,
      ).thenAnswer((_) async => []);
    });

    testWidgets('renders $AppView', (tester) async {
      await tester.pumpWidget(
        App(vendorLookupRepository: vendorLookupRepository),
      );

      expect(find.byType(AppView), findsOneWidget);
    });
  });

  group(AppView, () {
    testWidgets('renders LookupPage', (tester) async {
      await tester.pumpApp(const AppView());

      expect(find.byType(LookupPage), findsOneWidget);
    });
  });
}
