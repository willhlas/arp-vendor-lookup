import 'package:test/test.dart';
import 'package:vendor_api_client/vendor_api_client.dart';

void main() {
  group(Lookup, () {
    final foundJson = {
      'id': 1,
      'mac': 'AA:BB:CC:DD:EE:FF',
      'ip': '192.168.1.24',
      'vendor_name': 'Example Vendor',
      'created_at': '2026-08-28T18:20:00.000Z',
      'updated_at': '2026-08-28T18:20:00.000Z',
    };

    final notFoundJson = {
      'id': 2,
      'mac': 'AA:BB:CC:DD:EE:FF',
      'ip': '192.168.1.24',
      'vendor_name': null,
      'created_at': '2026-08-28T18:20:00.000Z',
      'updated_at': '2026-08-28T18:20:00.000Z',
    };

    test('fromJson decodes a full object with a vendor name', () {
      final lookup = Lookup.fromJson(foundJson);

      expect(lookup.id, 1);
      expect(lookup.mac, 'AA:BB:CC:DD:EE:FF');
      expect(lookup.ip, '192.168.1.24');
      expect(lookup.vendorName, 'Example Vendor');
      expect(lookup.createdAt, DateTime.parse('2026-08-28T18:20:00.000Z'));
      expect(lookup.updatedAt, DateTime.parse('2026-08-28T18:20:00.000Z'));
    });

    test('fromJson decodes a null vendor_name', () {
      final lookup = Lookup.fromJson(notFoundJson);

      expect(lookup.vendorName, isNull);
    });

    test('found is true when vendorName is present', () {
      expect(Lookup.fromJson(foundJson).found, isTrue);
    });

    test('found is false when vendorName is null', () {
      expect(Lookup.fromJson(notFoundJson).found, isFalse);
    });

    test('toJson round-trips to snake_case keys', () {
      final json = Lookup.fromJson(foundJson).toJson();

      expect(json['ip'], '192.168.1.24');
      expect(json['vendor_name'], 'Example Vendor');
      expect(json['created_at'], isA<String>());
      expect(json['updated_at'], isA<String>());
    });

    test('supports value equality', () {
      expect(Lookup.fromJson(foundJson), Lookup.fromJson(foundJson));
      expect(
        Lookup.fromJson(foundJson),
        isNot(Lookup.fromJson(notFoundJson)),
      );
    });
  });
}
