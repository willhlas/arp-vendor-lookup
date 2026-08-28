// dart format off
// coverage:ignore-file

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ARP Vendor Lookup';

  @override
  String get appSubtitle => 'IP → MAC → Vendor, resolved locally';

  @override
  String get apiConnectedLabel => 'API connected';

  @override
  String get lookupFormHeading => 'Look up an address';

  @override
  String get ipAddressLabel => 'IP address';

  @override
  String get ipAddressPlaceholder => '192.168.1.24';

  @override
  String get lookupButtonLabel => 'Look up';

  @override
  String get lookupHelperText => 'Reads the local ARP table for the MAC, then resolves the vendor via the lookup API.';

  @override
  String get emptyStateTitle => 'No lookup yet';

  @override
  String get emptyStateBody => 'Enter an IP address above to resolve its vendor.';

  @override
  String get loadingStateText => 'Querying ARP table and resolving vendor…';

  @override
  String get resultHeading => 'Result';

  @override
  String get resolvedBadgeLabel => 'Resolved';

  @override
  String get unknownVendorBadgeLabel => 'Vendor unknown';

  @override
  String get noArpEntryBadgeLabel => 'No ARP entry';

  @override
  String get macAddressRowLabel => 'MAC address';

  @override
  String get vendorRowLabel => 'Vendor';

  @override
  String get noVendorMatchText => 'No vendor match found';

  @override
  String get noArpEntryExplanation => 'No ARP entry found for this address — a vendor lookup was not attempted.';

  @override
  String get lookupFailedTitle => 'Lookup failed';

  @override
  String get invalidIpTitle => 'Invalid IP address';

  @override
  String invalidIpBody(String value) {
    return '\"$value\" is not a valid IPv4 address. Check the format and try again.';
  }

  @override
  String get recentLookupsHeading => 'Recent lookups';

  @override
  String recentLookupsCount(int count) {
    return '$count total';
  }

  @override
  String get macColumnHeader => 'MAC';

  @override
  String get vendorColumnHeader => 'Vendor';

  @override
  String get timeColumnHeader => 'Time';

  @override
  String get recentLookupsEmpty => 'Lookups will appear here once you search.';

  @override
  String get recentLookupsLoading => 'Loading recent lookups…';

  @override
  String get recentLookupsError => 'Couldn\'t load recent lookups.';

  @override
  String get unknownVendorRowText => 'Unknown vendor';

  @override
  String get timeJustNow => 'Just now';

  @override
  String timeMinutesAgo(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String timeHoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String timeDaysAgo(int days) {
    return '${days}d ago';
  }
}
