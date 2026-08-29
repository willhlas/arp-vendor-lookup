import 'package:test/test.dart';
import 'package:vendor_api_client/vendor_api_client.dart';

void main() {
  group(VendorApiException, () {
    group(InvalidMacFailure, () {
      group('toString', () {
        test('returns correct string representation', () {
          const exception = InvalidMacFailure('error');
          expect(exception.toString(), equals('error'));
        });
      });
    });

    group(UpstreamLookupFailure, () {
      group('toString', () {
        test('returns correct string representation', () {
          const exception = UpstreamLookupFailure('error');
          expect(exception.toString(), equals('error'));
        });
      });
    });

    group(NetworkFailure, () {
      group('toString', () {
        test('returns correct string representation', () {
          const exception = NetworkFailure('error');
          expect(exception.toString(), equals('error'));
        });
      });
    });

    group(UpstreamUnavailableFailure, () {
      group('toString', () {
        test('returns correct string representation', () {
          const exception = UpstreamUnavailableFailure('error');
          expect(exception.toString(), equals('error'));
        });
      });
    });

    group(RateLimitedFailure, () {
      group('toString', () {
        test('returns correct string representation', () {
          const exception = RateLimitedFailure('error');
          expect(exception.toString(), equals('error'));
        });
      });
    });

    group(UnexpectedResponseFailure, () {
      group('toString', () {
        test('returns correct string representation', () {
          const exception = UnexpectedResponseFailure(404, 'error');
          expect(exception.toString(), equals('error'));
        });
      });
    });
  });
}
