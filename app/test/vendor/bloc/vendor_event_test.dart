// ignore_for_file: prefer_const_constructors

import 'package:arp_vendor_lookup/vendor/vendor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(VendorEvent, () {
    group(VendorLookupRequested, () {
      test('supports value comparisons', () {
        const ip = '192.168.1.1';
        expect(
          VendorLookupRequested(ip),
          equals(VendorLookupRequested(ip)),
        );
      });
    });

    group(VendorRecentLookupsRequested, () {
      test('supports value comparisons', () {
        expect(
          VendorRecentLookupsRequested(),
          equals(VendorRecentLookupsRequested()),
        );
      });
    });

    group(VendorLocalIpDetectionRequested, () {
      test('supports value comparisons', () {
        expect(
          VendorLocalIpDetectionRequested(),
          equals(VendorLocalIpDetectionRequested()),
        );
      });
    });
  });
}
