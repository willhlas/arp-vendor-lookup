sealed class LocalNetworkInfoException implements Exception {
  const LocalNetworkInfoException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// The platform call to list local network interfaces itself failed.
final class LocalNetworkInfoFailure extends LocalNetworkInfoException {
  const LocalNetworkInfoFailure(super.message);
}
