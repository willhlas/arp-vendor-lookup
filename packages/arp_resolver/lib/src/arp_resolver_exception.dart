sealed class ArpResolverException implements Exception {
  const ArpResolverException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// The `arp` command could not be run at all (including not being found
/// on PATH), or it ran and exited with a non-zero status. Distinct from
/// [ArpParseFailure]: there was no usable output to even attempt parsing.
final class ArpCommandFailure extends ArpResolverException {
  const ArpCommandFailure(super.message);
}

/// The `arp` command ran and produced output, but that output didn't
/// match the expected format closely enough to parse at all. Never
/// thrown for an empty table or a missing entry for the requested IP —
/// those are normal `null` returns from `ArpResolver.resolve`.
final class ArpParseFailure extends ArpResolverException {
  const ArpParseFailure(super.message);
}
