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
  group(LinuxArpResolver, () {
    group('resolve', () {
      late _MockProcessRunner runner;
      late LinuxArpResolver resolver;

      setUp(() {
        runner = _MockProcessRunner();
        resolver = LinuxArpResolver(runProcess: runner.call);
      });

      test('returns the matching entry from real ip neigh output', () async {
        when(() => runner('ip', ['neigh', 'show'])).thenAnswer(
          (_) async => _result(0, _fixture('ip_neigh_linux.txt')),
        );

        final entry = await resolver.resolve('192.168.1.1');

        expect(
          entry,
          equals(ArpEntry(ip: '192.168.1.1', mac: '5c:35:fc:e1:ee:94')),
        );
        verify(() => runner('ip', ['neigh', 'show'])).called(1);
      });

      test('returns null when the ip is absent', () async {
        when(() => runner('ip', ['neigh', 'show'])).thenAnswer(
          (_) async => _result(0, _fixture('ip_neigh_linux.txt')),
        );

        final entry = await resolver.resolve('10.0.0.99');

        expect(entry, isNull);
      });

      test('returns null when the ip is incomplete', () async {
        when(() => runner('ip', ['neigh', 'show'])).thenAnswer(
          (_) async => _result(0, _fixture('ip_neigh_linux.txt')),
        );

        final entry = await resolver.resolve('169.254.169.254');

        expect(entry, isNull);
      });

      test(
        'throws ArpCommandFailure when the process fails to spawn',
        () async {
          when(
            () => runner('ip', ['neigh', 'show']),
          ).thenThrow(const ProcessException('ip', ['neigh', 'show']));

          expect(
            resolver.resolve('192.168.1.1'),
            throwsA(isA<ArpCommandFailure>()),
          );
        },
      );

      test('throws ArpCommandFailure on a non-zero exit code', () async {
        when(() => runner('ip', ['neigh', 'show'])).thenAnswer(
          (_) async => _result(1, '', stderr: 'no such command'),
        );

        expect(
          resolver.resolve('192.168.1.1'),
          throwsA(isA<ArpCommandFailure>()),
        );
      });

      test('throws ArpParseFailure on unparseable stdout', () async {
        when(() => runner('ip', ['neigh', 'show'])).thenAnswer(
          (_) async => _result(0, _fixture('ip_neigh_linux_malformed.txt')),
        );

        expect(
          resolver.resolve('192.168.1.1'),
          throwsA(isA<ArpParseFailure>()),
        );
      });

      test(
        'does not throw when only some lines are unparseable, and still '
        'resolves a matching line',
        () async {
          when(() => runner('ip', ['neigh', 'show'])).thenAnswer(
            (_) async => _result(0, _fixture('ip_neigh_linux_mixed.txt')),
          );

          final entry = await resolver.resolve('192.168.1.121');

          expect(
            entry,
            equals(ArpEntry(ip: '192.168.1.121', mac: '0c:1c:57:77:5f:35')),
          );
        },
      );
    });

    group('parseArpOutput', () {
      late String output;
      late LinuxArpResolver resolver;

      setUp(() {
        output = _fixture('ip_neigh_linux.txt');
        resolver = const LinuxArpResolver(runProcess: Process.run);
      });

      test('lowercases an already-normalized mac', () {
        final entry = resolver.parseArpOutput(output, '192.168.1.121');

        expect(
          entry,
          equals(ArpEntry(ip: '192.168.1.121', mac: '0c:1c:57:77:5f:35')),
        );
      });

      test('lowercases an upper-case lladdr', () {
        final entry = resolver.parseArpOutput(output, '192.168.1.200');

        expect(
          entry,
          equals(ArpEntry(ip: '192.168.1.200', mac: 'aa:bb:cc:dd:ee:ff')),
        );
      });

      test('returns null when the entry has no lladdr (FAILED)', () {
        final entry = resolver.parseArpOutput(output, '192.168.1.150');

        expect(entry, isNull);
      });

      test('returns null for empty output', () {
        final empty = _fixture('ip_neigh_linux_empty.txt');

        final entry = resolver.parseArpOutput(empty, '192.168.1.1');

        expect(entry, isNull);
      });
    });
  });
}
