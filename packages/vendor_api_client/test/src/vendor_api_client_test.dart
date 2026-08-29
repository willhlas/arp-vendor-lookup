import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:vendor_api_client/vendor_api_client.dart';

class _MockHttpClient extends Mock implements http.Client {}

class _FakeUri extends Fake implements Uri {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeUri());
  });

  late http.Client httpClient;
  late VendorApiClient client;

  setUp(() {
    httpClient = _MockHttpClient();
    client = VendorApiClient(
      httpClient: httpClient,
      baseUrl: 'http://localhost:3000',
    );
  });

  void stubGet(String body, int statusCode) {
    when(
      () => httpClient.get(any()),
    ).thenAnswer((_) async => http.Response(body, statusCode));
  }

  final lookupJson = jsonEncode({
    'id': 1,
    'mac': 'AA:BB:CC:DD:EE:FF',
    'ip': '192.168.1.24',
    'vendor_name': 'Example Vendor',
    'created_at': '2026-08-28T18:20:00.000Z',
    'updated_at': '2026-08-28T18:20:00.000Z',
  });

  final notFoundJson = jsonEncode({
    'id': 2,
    'mac': 'AA:BB:CC:DD:EE:FF',
    'ip': '192.168.1.24',
    'vendor_name': null,
    'created_at': '2026-08-28T18:20:00.000Z',
    'updated_at': '2026-08-28T18:20:00.000Z',
  });

  group('lookupByMac', () {
    test('200 with a vendor returns a found Lookup', () async {
      stubGet(lookupJson, 200);

      final lookup = await client.lookupByMac(
        'AA:BB:CC:DD:EE:FF',
        '192.168.1.24',
      );

      expect(lookup.found, isTrue);
      expect(lookup.vendorName, 'Example Vendor');

      final captured =
          verify(() => httpClient.get(captureAny())).captured.single as Uri;
      expect(captured.queryParameters['mac'], 'AA:BB:CC:DD:EE:FF');
      expect(captured.queryParameters['ip'], '192.168.1.24');
    });

    test('404 with a null vendor_name returns a not-found Lookup', () async {
      stubGet(notFoundJson, 404);

      final lookup = await client.lookupByMac(
        'AA:BB:CC:DD:EE:FF',
        '192.168.1.24',
      );

      expect(lookup.found, isFalse);
    });

    test('422 throws InvalidMacFailure with the error message', () async {
      stubGet(jsonEncode({'error': 'mac must be a full 6-octet address'}), 422);

      expect(
        () => client.lookupByMac('not-a-mac', '192.168.1.24'),
        throwsA(
          isA<InvalidMacFailure>().having(
            (e) => e.message,
            'message',
            'mac must be a full 6-octet address',
          ),
        ),
      );
    });

    test('502 throws UpstreamLookupFailure with the error message', () async {
      stubGet(jsonEncode({'error': 'vendor lookup API returned 500'}), 502);

      expect(
        () => client.lookupByMac('AA:BB:CC:DD:EE:FF', '192.168.1.24'),
        throwsA(
          isA<UpstreamLookupFailure>().having(
            (e) => e.message,
            'message',
            'vendor lookup API returned 500',
          ),
        ),
      );
    });

    test(
      '502 with a different message still throws UpstreamLookupFailure',
      () async {
        stubGet(
          jsonEncode({
            'error': 'unexpected vendor lookup API response: boom',
          }),
          502,
        );

        expect(
          () => client.lookupByMac('AA:BB:CC:DD:EE:FF', '192.168.1.24'),
          throwsA(isA<UpstreamLookupFailure>()),
        );
      },
    );

    test('429 throws RateLimitedFailure with the error message', () async {
      stubGet(
        jsonEncode({'error': 'vendor lookup API rate-limited us (429)'}),
        429,
      );

      expect(
        () => client.lookupByMac('AA:BB:CC:DD:EE:FF', '192.168.1.24'),
        throwsA(
          isA<RateLimitedFailure>().having(
            (e) => e.message,
            'message',
            'vendor lookup API rate-limited us (429)',
          ),
        ),
      );
    });

    test(
      '503 throws UpstreamUnavailableFailure with the error message',
      () async {
        stubGet(
          jsonEncode({'error': 'vendor lookup API unreachable: timeout'}),
          503,
        );

        expect(
          () => client.lookupByMac('AA:BB:CC:DD:EE:FF', '192.168.1.24'),
          throwsA(
            isA<UpstreamUnavailableFailure>().having(
              (e) => e.message,
              'message',
              'vendor lookup API unreachable: timeout',
            ),
          ),
        );
      },
    );

    test('a network error throws NetworkFailure', () async {
      when(
        () => httpClient.get(any()),
      ).thenThrow(Exception('connection refused'));

      expect(
        () => client.lookupByMac('AA:BB:CC:DD:EE:FF', '192.168.1.24'),
        throwsA(isA<NetworkFailure>()),
      );
    });

    test('an unparseable 200 body throws UnexpectedResponseFailure', () async {
      stubGet('not json', 200);

      expect(
        () => client.lookupByMac('AA:BB:CC:DD:EE:FF', '192.168.1.24'),
        throwsA(isA<UnexpectedResponseFailure>()),
      );
    });

    test(
      'a 200 body missing a required key throws UnexpectedResponseFailure',
      () async {
        stubGet(jsonEncode({'id': 1}), 200);

        expect(
          () => client.lookupByMac('AA:BB:CC:DD:EE:FF', '192.168.1.24'),
          throwsA(isA<UnexpectedResponseFailure>()),
        );
      },
    );

    test(
      'an unexpected status code throws UnexpectedResponseFailure',
      () async {
        stubGet('', 500);

        expect(
          () => client.lookupByMac('AA:BB:CC:DD:EE:FF', '192.168.1.24'),
          throwsA(
            isA<UnexpectedResponseFailure>().having(
              (e) => e.statusCode,
              'statusCode',
              500,
            ),
          ),
        );
      },
    );

    test(
      'a 422 with a non-JSON body throws UnexpectedResponseFailure',
      () async {
        stubGet('not json', 422);

        expect(
          () => client.lookupByMac('AA:BB:CC:DD:EE:FF', '192.168.1.24'),
          throwsA(isA<UnexpectedResponseFailure>()),
        );
      },
    );
  });

  group('recentLookups', () {
    test('200 with an array returns a List<Lookup> in order', () async {
      stubGet('[$lookupJson, $notFoundJson]', 200);

      final lookups = await client.recentLookups();

      expect(lookups, hasLength(2));
      expect(lookups[0].id, 1);
      expect(lookups[1].id, 2);
    });

    test('200 with an empty array returns an empty list', () async {
      stubGet('[]', 200);

      expect(await client.recentLookups(), isEmpty);
    });

    test('a network error throws NetworkFailure', () async {
      when(
        () => httpClient.get(any()),
      ).thenThrow(Exception('connection refused'));

      expect(() => client.recentLookups(), throwsA(isA<NetworkFailure>()));
    });

    test('a non-array body throws UnexpectedResponseFailure', () async {
      stubGet(lookupJson, 200);

      expect(
        () => client.recentLookups(),
        throwsA(isA<UnexpectedResponseFailure>()),
      );
    });

    test('a non-200 status throws UnexpectedResponseFailure', () async {
      stubGet('', 500);

      expect(
        () => client.recentLookups(),
        throwsA(isA<UnexpectedResponseFailure>()),
      );
    });
  });
}
