import 'dart:io';

import 'package:arp_resolver/arp_resolver.dart';
import 'package:arp_resolver/src/parsers/windows_arp_output_parser.dart';
import 'package:test/test.dart';

String _fixture(String name) => File('test/fixtures/$name').readAsStringSync();

void main() {
  group('parseWindowsArpOutput', () {
    late String output;

    setUp(() {
      output = _fixture('arp_a_windows.txt');
    });

    test('returns the entry for a resolved ip, normalizing hyphens', () {
      final entry = parseWindowsArpOutput(output, '192.168.1.1');

      expect(
        entry,
        const ArpEntry(ip: '192.168.1.1', mac: '5c:35:fc:e1:ee:94'),
      );
    });

    test('returns the entry for another resolved ip', () {
      final entry = parseWindowsArpOutput(output, '192.168.1.121');

      expect(
        entry,
        const ArpEntry(ip: '192.168.1.121', mac: '0c:1c:57:77:5f:35'),
      );
    });

    test('returns null when the ip is not present in the table', () {
      final entry = parseWindowsArpOutput(output, '10.0.0.99');

      expect(entry, isNull);
    });

    test('returns null when the only entry for the ip is invalid', () {
      final entry = parseWindowsArpOutput(output, '192.168.1.150');

      expect(entry, isNull);
    });

    test('returns null for empty output', () {
      final empty = _fixture('arp_a_windows_empty.txt');

      final entry = parseWindowsArpOutput(empty, '192.168.1.1');

      expect(entry, isNull);
    });

    test(
      'throws ArpParseFailure for output matching no expected line format',
      () {
        final malformed = _fixture('arp_a_windows_malformed.txt');

        expect(
          () => parseWindowsArpOutput(malformed, '192.168.1.1'),
          throwsA(isA<ArpParseFailure>()),
        );
      },
    );
  });
}
