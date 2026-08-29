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
    late WindowsArpResolver resolver;

    setUp(() {
      runner = _MockProcessRunner();
      resolver = WindowsArpResolver(runProcess: runner.call);
    });

    test('returns the matching entry from real arp output', () async {
      when(() => runner('arp', ['-a'])).thenAnswer(
        (_) async => _result(0, _fixture('arp_a_windows.txt')),
      );

      final entry = await resolver.resolve('192.168.1.1');

      expect(
        entry,
        const ArpEntry(ip: '192.168.1.1', mac: '5c:35:fc:e1:ee:94'),
      );
      verify(() => runner('arp', ['-a'])).called(1);
    });

    test('returns null when the ip is absent', () async {
      when(() => runner('arp', ['-a'])).thenAnswer(
        (_) async => _result(0, _fixture('arp_a_windows.txt')),
      );

      final entry = await resolver.resolve('10.0.0.99');

      expect(entry, isNull);
    });

    test('returns null when the ip is invalid', () async {
      when(() => runner('arp', ['-a'])).thenAnswer(
        (_) async => _result(0, _fixture('arp_a_windows.txt')),
      );

      final entry = await resolver.resolve('192.168.1.150');

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
        (_) async => _result(0, _fixture('arp_a_windows_malformed.txt')),
      );

      expect(resolver.resolve('192.168.1.1'), throwsA(isA<ArpParseFailure>()));
    });
  });

  group('parseArpOutput', () {
    late String output;
    late WindowsArpResolver resolver;

    setUp(() {
      output = _fixture('arp_a_windows.txt');
      resolver = const WindowsArpResolver(runProcess: Process.run);
    });

    test('returns the entry for another resolved ip', () {
      final entry = resolver.parseArpOutput(output, '192.168.1.121');

      expect(
        entry,
        const ArpEntry(ip: '192.168.1.121', mac: '0c:1c:57:77:5f:35'),
      );
    });

    test('returns null for empty output', () {
      final empty = _fixture('arp_a_windows_empty.txt');

      final entry = resolver.parseArpOutput(empty, '192.168.1.1');

      expect(entry, isNull);
    });
  });
}
