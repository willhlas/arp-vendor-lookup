sealed class VendorApiException implements Exception {
  const VendorApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// The mac was rejected by the API as malformed (HTTP 422).
final class InvalidMacFailure extends VendorApiException {
  const InvalidMacFailure(super.message);
}

/// The API responded, but its own call to the upstream mac-vendor-lookup
/// service failed (HTTP 502). [message] is free-form and varies by cause.
final class UpstreamLookupFailure extends VendorApiException {
  const UpstreamLookupFailure(super.message);
}

/// The API could not be reached at all (DNS failure, connection refused,
/// timeout, etc). Distinct from [UpstreamLookupFailure]: that means the API
/// responded and its own upstream failed; this means it never responded.
final class NetworkFailure extends VendorApiException {
  const NetworkFailure(super.message);
}

/// The API responded, but it could not reach its own upstream at all —
/// a network-level failure on the API's side (HTTP 503). Distinct from
/// [UpstreamLookupFailure] (the API's upstream responded, just badly) and
/// [NetworkFailure] (our own call to the API never got a response at all).
final class UpstreamUnavailableFailure extends VendorApiException {
  const UpstreamUnavailableFailure(super.message);
}

/// The API itself was rate-limited by its upstream and is passing that
/// back to us (HTTP 429).
final class RateLimitedFailure extends VendorApiException {
  const RateLimitedFailure(super.message);
}

/// The API returned a response this client doesn't know how to interpret:
/// an unexpected status code, or a body that isn't valid/expected JSON.
final class UnexpectedResponseFailure extends VendorApiException {
  const UnexpectedResponseFailure(this.statusCode, super.message);

  final int statusCode;
}
