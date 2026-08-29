import 'package:arp_resolver/arp_resolver.dart';
import 'package:test/test.dart';

void main() {
  group(ArpResolverException, () {
    group(ArpCommandFailure, () {
      group('toString', () {
        test('returns correct string representation', () {
          const exception = ArpCommandFailure('error');
          expect(exception.toString(), equals('error'));
        });
      });
    });

    group(ArpParseFailure, () {
      group('toString', () {
        test('returns correct string representation', () {
          const exception = ArpParseFailure('error');
          expect(exception.toString(), equals('error'));
        });
      });
    });
  });
}
