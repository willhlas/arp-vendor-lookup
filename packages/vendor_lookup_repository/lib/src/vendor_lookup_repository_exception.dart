sealed class VendorLookupRepositoryException implements Exception {
  const VendorLookupRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Resolving an IP via the local ARP table failed — the `arp` command
/// couldn't run, or its output couldn't be parsed. Distinct from an ARP
/// miss (`VendorLookupResult.arpMiss`), which is a normal, non-exceptional
/// result. Wraps the original `ArpResolverException` as [cause].
final class ArpLookupFailure extends VendorLookupRepositoryException {
  const ArpLookupFailure(super.message, this.cause);

  final Object cause;
}

/// The vendor API call failed — unreachable, rejected the request, or
/// returned something unexpected. Wraps the original `VendorApiException`
/// as [cause].
final class VendorApiLookupFailure extends VendorLookupRepositoryException {
  const VendorApiLookupFailure(super.message, this.cause);

  final Object cause;
}
