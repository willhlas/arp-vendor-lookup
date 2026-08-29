// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:arp_resolver/arp_resolver.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockProcessRunner extends Mock {
  Future<ProcessResult> call(String executable, List<String> arguments);
}

ProcessResult _result(int exitCode, String stdout, {String stderr = ''}) =>
    ProcessResult(0, exitCode, stdout, stderr);

String _fixture(String name) {
  return File('test/fixtures/$name').readAsStringSync();
}

void main() {
  group('resolve', () {
    late _MockProcessRunner runner;
    late MacosArpResolver resolver;

    setUp(() {
      runner = _MockProcessRunner();
      resolver = MacosArpResolver(runProcess: runner.call);
    });

    test('returns the matching entry from real arp output', () async {
      when(() => runner('arp', ['-a'])).thenAnswer(
        (_) async => _result(0, _fixture('arp_a_macos.txt')),
      );

      final entry = await resolver.resolve('192.168.1.1');

      expect(
        entry,
        equals(ArpEntry(ip: '192.168.1.1', mac: '5c:35:fc:e1:ee:94')),
      );
      verify(() => runner('arp', ['-a'])).called(1);
    });

    test('returns null when the ip is absent', () async {
      when(() => runner('arp', ['-a'])).thenAnswer(
        (_) async => _result(0, _fixture('arp_a_macos.txt')),
      );

      final entry = await resolver.resolve('10.0.0.99');

      expect(entry, isNull);
    });

    test('returns null when the ip is incomplete', () async {
      when(() => runner('arp', ['-a'])).thenAnswer(
        (_) async => _result(0, _fixture('arp_a_macos.txt')),
      );

      final entry = await resolver.resolve('169.254.169.254');

      expect(entry, isNull);
    });

    test('throws ArpCommandFailure when the process fails to spawn', () async {
      when(
        () => runner('arp', ['-a']),
      ).thenThrow(const ProcessException('arp', ['-a']));

      expect(
        resolver.resolve('192.168.1.1'),
        throwsA(isA<ArpCommandFailure>()),
      );
    });

    test('throws ArpCommandFailure on a non-zero exit code', () async {
      when(() => runner('arp', ['-a'])).thenAnswer(
        (_) async => _result(1, '', stderr: 'no such command'),
      );

      expect(
        resolver.resolve('192.168.1.1'),
        throwsA(isA<ArpCommandFailure>()),
      );
    });

    test('throws ArpParseFailure on unparseable stdout', () async {
      when(() => runner('arp', ['-a'])).thenAnswer(
        (_) async => _result(0, _fixture('arp_a_macos_malformed.txt')),
      );

      expect(resolver.resolve('192.168.1.1'), throwsA(isA<ArpParseFailure>()));
    });
  });

  group('parseArpOutput', () {
    late String output;
    late MacosArpResolver resolver;

    setUp(() {
      output = _fixture('arp_a_macos.txt');
      resolver = const MacosArpResolver(runProcess: Process.run);
    });

    test('normalizes single-hex-digit octets for the matched ip', () {
      final entry = resolver.parseArpOutput(output, '192.168.1.121');

      expect(
        entry,
        equals(ArpEntry(ip: '192.168.1.121', mac: '0c:1c:57:77:5f:35')),
      );
    });

    test('parses a line whose leading token is a resolved hostname', () {
      final entry = resolver.parseArpOutput(output, '224.0.0.251');

      expect(
        entry,
        equals(ArpEntry(ip: '224.0.0.251', mac: '01:00:5e:00:00:fb')),
      );
    });

    test('returns null for empty output', () {
      final empty = _fixture('arp_a_macos_empty.txt');

      final entry = resolver.parseArpOutput(empty, '192.168.1.1');

      expect(entry, isNull);
    });
  });
}
