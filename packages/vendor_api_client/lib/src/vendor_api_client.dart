import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:vendor_api_client/vendor_api_client.dart';

class VendorApiClient {
  const VendorApiClient({
    required this._httpClient,
    required this._baseUrl,
  });

  final http.Client _httpClient;
  final String _baseUrl;

  Future<Lookup> lookupByMac(String mac) async {
    final uri = Uri.parse('$_baseUrl/lookups').replace(
      queryParameters: {'mac': mac},
    );
    final response = await _send(uri);

    switch (response.statusCode) {
      case 200:
      case 404:
        return _decodeLookup(response);
      case 422:
        throw InvalidMacFailure(_decodeErrorMessage(response));
      case 502:
        throw UpstreamLookupFailure(_decodeErrorMessage(response));
      default:
        throw UnexpectedResponseFailure(
          response.statusCode,
          'unexpected status code from vendor API',
        );
    }
  }

  Future<List<Lookup>> recentLookups() async {
    final uri = Uri.parse('$_baseUrl/lookups');
    final response = await _send(uri);

    if (response.statusCode != 200) {
      throw UnexpectedResponseFailure(
        response.statusCode,
        'unexpected status code from vendor API',
      );
    }

    try {
      final decoded = jsonDecode(response.body) as List<dynamic>;
      return decoded.cast<Map<String, dynamic>>().map(Lookup.fromJson).toList();
    } catch (e) {
      throw UnexpectedResponseFailure(
        response.statusCode,
        'could not parse recent lookups response: $e',
      );
    }
  }

  Future<http.Response> _send(Uri uri) async {
    try {
      return await _httpClient.get(uri);
    } catch (e) {
      throw NetworkFailure('could not reach vendor API: $e');
    }
  }

  Lookup _decodeLookup(http.Response response) {
    try {
      return Lookup.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } catch (e) {
      throw UnexpectedResponseFailure(
        response.statusCode,
        'could not parse lookup response: $e',
      );
    }
  }

  String _decodeErrorMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return body['error'] as String;
    } catch (e) {
      throw UnexpectedResponseFailure(
        response.statusCode,
        'could not parse error response: $e',
      );
    }
  }
}
