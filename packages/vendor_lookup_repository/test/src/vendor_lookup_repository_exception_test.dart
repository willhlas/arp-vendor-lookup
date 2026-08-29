import 'package:test/test.dart';
import 'package:vendor_lookup_repository/vendor_lookup_repository.dart';

void main() {
  group(VendorLookupRepositoryException, () {
    group(ArpLookupFailure, () {
      group('toString', () {
        test('returns correct string representation', () {
          const exception = ArpLookupFailure('error', 404);
          expect(exception.toString(), equals('error'));
        });
      });
    });

    group(VendorApiLookupFailure, () {
      group('toString', () {
        test('returns correct string representation', () {
          const exception = VendorApiLookupFailure('error', 404);
          expect(exception.toString(), equals('error'));
        });
      });
    });
  });
}
