import 'package:test/test.dart';
import 'package:vendor_api_client/vendor_api_client.dart';
import 'package:vendor_lookup_repository/vendor_lookup_repository.dart';

void main() {
  group(VendorLookupResult, () {
    final foundLookup = Lookup(
      id: 1,
      mac: 'AA:BB:CC:DD:EE:FF',
      vendorName: 'Example Vendor',
      createdAt: DateTime.utc(2026, 8, 28),
      updatedAt: DateTime.utc(2026, 8, 28),
    );

    final notFoundLookup = Lookup(
      id: 2,
      mac: 'AA:BB:CC:DD:EE:FF',
      vendorName: null,
      createdAt: DateTime.utc(2026, 8, 28),
      updatedAt: DateTime.utc(2026, 8, 28),
    );

    test('supports value equality when all fields match', () {
      final a = VendorLookupResult(
        ip: '192.168.1.10',
        mac: 'AA:BB:CC:DD:EE:FF',
        vendorLookup: foundLookup,
      );
      final b = VendorLookupResult(
        ip: '192.168.1.10',
        mac: 'AA:BB:CC:DD:EE:FF',
        vendorLookup: foundLookup,
      );

      expect(a, equals(b));
    });

    test('is not equal when ip differs', () {
      final a = VendorLookupResult(
        ip: '192.168.1.10',
        mac: 'AA:BB:CC:DD:EE:FF',
        vendorLookup: foundLookup,
      );
      final b = VendorLookupResult(
        ip: '192.168.1.11',
        mac: 'AA:BB:CC:DD:EE:FF',
        vendorLookup: foundLookup,
      );

      expect(a, isNot(equals(b)));
    });

    test('is not equal when mac differs', () {
      final a = VendorLookupResult(
        ip: '192.168.1.10',
        mac: 'AA:BB:CC:DD:EE:FF',
        vendorLookup: foundLookup,
      );
      const b = VendorLookupResult(
        ip: '192.168.1.10',
        mac: null,
        vendorLookup: null,
      );

      expect(a, isNot(equals(b)));
    });

    test('is not equal when vendorLookup differs', () {
      final a = VendorLookupResult(
        ip: '192.168.1.10',
        mac: 'AA:BB:CC:DD:EE:FF',
        vendorLookup: foundLookup,
      );
      final b = VendorLookupResult(
        ip: '192.168.1.10',
        mac: 'AA:BB:CC:DD:EE:FF',
        vendorLookup: notFoundLookup,
      );

      expect(a, isNot(equals(b)));
    });

    test('arpMiss is true when mac is null', () {
      const result = VendorLookupResult(
        ip: '192.168.1.10',
        mac: null,
        vendorLookup: null,
      );

      expect(result.arpMiss, isTrue);
    });

    test('arpMiss is false when mac is present', () {
      final result = VendorLookupResult(
        ip: '192.168.1.10',
        mac: 'AA:BB:CC:DD:EE:FF',
        vendorLookup: foundLookup,
      );

      expect(result.arpMiss, isFalse);
    });

    test('found is true when vendorLookup.found is true', () {
      final result = VendorLookupResult(
        ip: '192.168.1.10',
        mac: 'AA:BB:CC:DD:EE:FF',
        vendorLookup: foundLookup,
      );

      expect(result.found, isTrue);
    });

    test('found is false when vendorLookup is null (ARP miss)', () {
      const result = VendorLookupResult(
        ip: '192.168.1.10',
        mac: null,
        vendorLookup: null,
      );

      expect(result.found, isFalse);
    });

    test('found is false when vendorLookup.found is false', () {
      final result = VendorLookupResult(
        ip: '192.168.1.10',
        mac: 'AA:BB:CC:DD:EE:FF',
        vendorLookup: notFoundLookup,
      );

      expect(result.found, isFalse);
    });
  });
}
