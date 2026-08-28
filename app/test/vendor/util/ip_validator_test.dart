import 'package:arp_vendor_lookup/vendor/vendor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(isValidIPv4, () {
    for (final ip in [
      '192.168.1.24',
      '0.0.0.0',
      '255.255.255.255',
      '10.0.0.5',
    ]) {
      test('returns true for valid IPv4 "$ip"', () {
        expect(isValidIPv4(ip), isTrue);
      });
    }

    for (final ip in [
      '999.1.1.1',
      '192.168.1',
      '192.168.1.1.1',
      '192.168.1.256',
      '192.168.-1.1',
      '192.168.01.1',
      '192.168.1.',
      '',
      '192.168.1.a',
      ' 192.168.1.1',
      '192.168.1.1 ',
    ]) {
      test('returns false for invalid IPv4 "$ip"', () {
        expect(isValidIPv4(ip), isFalse);
      });
    }
  });
}
