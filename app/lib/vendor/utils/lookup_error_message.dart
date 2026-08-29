import 'package:arp_vendor_lookup/l10n/l10n.dart';
import 'package:arp_vendor_lookup/vendor/bloc/vendor_bloc.dart';

/// Resolves a [VendorLookupErrorKind] to a specific, user-facing body
/// string. Lives outside the bloc because it needs [AppLocalizations],
/// which requires a BuildContext the bloc doesn't have.
String lookupErrorBody(AppLocalizations l10n, VendorLookupErrorKind? kind) {
  return switch (kind) {
    VendorLookupErrorKind.arpCommandFailed =>
      l10n.lookupErrorArpCommandFailedBody,
    VendorLookupErrorKind.arpOutputUnparseable =>
      l10n.lookupErrorArpUnparseableBody,
    VendorLookupErrorKind.networkUnreachable =>
      l10n.lookupErrorNetworkUnreachableBody,
    VendorLookupErrorKind.upstreamUnavailable =>
      l10n.lookupErrorUpstreamUnavailableBody,
    VendorLookupErrorKind.upstreamBadResponse =>
      l10n.lookupErrorUpstreamBadResponseBody,
    VendorLookupErrorKind.rateLimited => l10n.lookupErrorRateLimitedBody,
    VendorLookupErrorKind.invalidMac => l10n.lookupErrorInvalidMacBody,
    VendorLookupErrorKind.unexpectedResponse ||
    VendorLookupErrorKind.unknown ||
    null => l10n.lookupErrorUnexpectedBody,
  };
}
