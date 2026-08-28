import 'dart:io';

import 'package:arp_resolver/arp_resolver.dart';
import 'package:arp_resolver/src/parsers/linux_arp_output_parser.dart';
import 'package:test/test.dart';

String _fixture(String name) => File('test/fixtures/$name').readAsStringSync();

void main() {
  group('parseLinuxArpOutput', () {
    late String output;

    setUp(() {
      output = _fixture('ip_neigh_linux.txt');
    });

    test('returns the entry for a resolved ip', () {
      final entry = parseLinuxArpOutput(output, '192.168.1.1');

      expect(
        entry,
        const ArpEntry(ip: '192.168.1.1', mac: '5c:35:fc:e1:ee:94'),
      );
    });

    test('lowercases an already-normalized mac', () {
      final entry = parseLinuxArpOutput(output, '192.168.1.121');

      expect(
        entry,
        const ArpEntry(ip: '192.168.1.121', mac: '0c:1c:57:77:5f:35'),
      );
    });

    test('returns null when the ip is not present in the table', () {
      final entry = parseLinuxArpOutput(output, '10.0.0.99');

      expect(entry, isNull);
    });

    test('returns null when the entry has no lladdr (FAILED)', () {
      final entry = parseLinuxArpOutput(output, '192.168.1.150');

      expect(entry, isNull);
    });

    test('returns null when the entry has no lladdr (INCOMPLETE)', () {
      final entry = parseLinuxArpOutput(output, '169.254.169.254');

      expect(entry, isNull);
    });

    test('returns null for empty output', () {
      final empty = _fixture('ip_neigh_linux_empty.txt');

      final entry = parseLinuxArpOutput(empty, '192.168.1.1');

      expect(entry, isNull);
    });

    test(
      'throws ArpParseFailure for output matching no expected line format',
      () {
        final malformed = _fixture('ip_neigh_linux_malformed.txt');

        expect(
          () => parseLinuxArpOutput(malformed, '192.168.1.1'),
          throwsA(isA<ArpParseFailure>()),
        );
      },
    );
  });
}
