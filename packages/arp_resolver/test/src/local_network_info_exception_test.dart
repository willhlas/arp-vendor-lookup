import 'package:arp_resolver/arp_resolver.dart';
import 'package:test/test.dart';

void main() {
  group(LocalNetworkInfoException, () {
    group(LocalNetworkInfoFailure, () {
      group('toString', () {
        test('returns correct string representation', () {
          const exception = LocalNetworkInfoFailure('error');
          expect(exception.toString(), equals('error'));
        });
      });
    });
  });
}
