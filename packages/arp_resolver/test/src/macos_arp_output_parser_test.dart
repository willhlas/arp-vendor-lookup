import 'dart:io';

import 'package:arp_resolver/arp_resolver.dart';
import 'package:arp_resolver/src/parsers/macos_arp_output_parser.dart';
import 'package:test/test.dart';

String _fixture(String name) => File('test/fixtures/$name').readAsStringSync();

void main() {
  group('parseMacosArpOutput', () {
    late String output;

    setUp(() {
      output = _fixture('arp_a_macos.txt');
    });

    test('returns the entry for an ip with an already two-digit mac', () {
      final entry = parseMacosArpOutput(output, '192.168.1.1');

      expect(
        entry,
        const ArpEntry(ip: '192.168.1.1', mac: '5c:35:fc:e1:ee:94'),
      );
    });

    test('normalizes single-hex-digit octets for the matched ip', () {
      final entry = parseMacosArpOutput(output, '192.168.1.121');

      expect(
        entry,
        const ArpEntry(ip: '192.168.1.121', mac: '0c:1c:57:77:5f:35'),
      );
    });

    test('parses a line whose leading token is a resolved hostname', () {
      final entry = parseMacosArpOutput(output, '224.0.0.251');

      expect(
        entry,
        const ArpEntry(ip: '224.0.0.251', mac: '01:00:5e:00:00:fb'),
      );
    });

    test('returns null when the ip is not present in the table', () {
      final entry = parseMacosArpOutput(output, '10.0.0.99');

      expect(entry, isNull);
    });

    test('returns null when the only entry for the ip is incomplete', () {
      final entry = parseMacosArpOutput(output, '169.254.169.254');

      expect(entry, isNull);
    });

    test('returns null for empty output', () {
      final empty = _fixture('arp_a_macos_empty.txt');

      final entry = parseMacosArpOutput(empty, '192.168.1.1');

      expect(entry, isNull);
    });

    test(
      'throws ArpParseFailure for output matching no expected line format',
      () {
        final malformed = _fixture('arp_a_macos_malformed.txt');

        expect(
          () => parseMacosArpOutput(malformed, '192.168.1.1'),
          throwsA(isA<ArpParseFailure>()),
        );
      },
    );
  });
}
