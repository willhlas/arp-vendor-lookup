// dart format off
// coverage:ignore-file
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en')
  ];

  /// The app's name, shown in the header and window title.
  ///
  /// In en, this message translates to:
  /// **'ARP Vendor Lookup'**
  String get appTitle;

  /// Tagline shown under the app title in the header.
  ///
  /// In en, this message translates to:
  /// **'IP → MAC → Vendor, resolved locally'**
  String get appSubtitle;

  /// Static status label next to the header's connection indicator dot.
  ///
  /// In en, this message translates to:
  /// **'API connected'**
  String get apiConnectedLabel;

  /// Heading of the IP lookup form card.
  ///
  /// In en, this message translates to:
  /// **'Look up an address'**
  String get lookupFormHeading;

  /// Label for the IP address field, reused as the row label for IP in result cards.
  ///
  /// In en, this message translates to:
  /// **'IP address'**
  String get ipAddressLabel;

  /// Placeholder text shown in the empty IP address input.
  ///
  /// In en, this message translates to:
  /// **'192.168.1.24'**
  String get ipAddressPlaceholder;

  /// Label of the button that submits a lookup.
  ///
  /// In en, this message translates to:
  /// **'Look up'**
  String get lookupButtonLabel;

  /// Helper text explaining what the lookup form does.
  ///
  /// In en, this message translates to:
  /// **'Reads the local ARP table for the MAC, then resolves the vendor via the lookup API.'**
  String get lookupHelperText;

  /// Title shown before any lookup has been performed.
  ///
  /// In en, this message translates to:
  /// **'No lookup yet'**
  String get emptyStateTitle;

  /// Body text shown before any lookup has been performed.
  ///
  /// In en, this message translates to:
  /// **'Enter an IP address above to resolve its vendor.'**
  String get emptyStateBody;

  /// Text shown while a lookup is in progress.
  ///
  /// In en, this message translates to:
  /// **'Querying ARP table and resolving vendor…'**
  String get loadingStateText;

  /// Heading of the result card.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get resultHeading;

  /// Badge label when a lookup fully resolved to a known vendor.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get resolvedBadgeLabel;

  /// Badge label when a MAC was found but no vendor matched it.
  ///
  /// In en, this message translates to:
  /// **'Vendor unknown'**
  String get unknownVendorBadgeLabel;

  /// Badge label when the IP had no entry in the local ARP table.
  ///
  /// In en, this message translates to:
  /// **'No ARP entry'**
  String get noArpEntryBadgeLabel;

  /// Row label for the MAC address value in a result card.
  ///
  /// In en, this message translates to:
  /// **'MAC address'**
  String get macAddressRowLabel;

  /// Row label for the vendor value in a result card.
  ///
  /// In en, this message translates to:
  /// **'Vendor'**
  String get vendorRowLabel;

  /// Shown in the vendor row when a MAC was found but has no known vendor.
  ///
  /// In en, this message translates to:
  /// **'No vendor match found'**
  String get noVendorMatchText;

  /// Explanation shown when the IP has no local ARP table entry at all.
  ///
  /// In en, this message translates to:
  /// **'No ARP entry found for this address — a vendor lookup was not attempted.'**
  String get noArpEntryExplanation;

  /// Generic title for a failed lookup, regardless of the underlying cause.
  ///
  /// In en, this message translates to:
  /// **'Lookup failed'**
  String get lookupFailedTitle;

  /// Body shown when the OS command used to read the ARP table could not be run.
  ///
  /// In en, this message translates to:
  /// **'Could not read the local ARP table. Check that the arp command is available and try again.'**
  String get lookupErrorArpCommandFailedBody;

  /// Body shown when the ARP command ran but its output could not be parsed.
  ///
  /// In en, this message translates to:
  /// **'The local ARP table\'s output could not be understood.'**
  String get lookupErrorArpUnparseableBody;

  /// Body shown when the app's own call to the vendor lookup API never got a response.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the vendor lookup API. Check your connection and try again.'**
  String get lookupErrorNetworkUnreachableBody;

  /// Body shown when the vendor lookup API responded but its own upstream was unreachable (503).
  ///
  /// In en, this message translates to:
  /// **'The vendor lookup API could not reach its upstream data source. Try again shortly.'**
  String get lookupErrorUpstreamUnavailableBody;

  /// Body shown when the vendor lookup API's upstream responded, but badly (502).
  ///
  /// In en, this message translates to:
  /// **'The vendor lookup API returned an unexpected response. Try again shortly.'**
  String get lookupErrorUpstreamBadResponseBody;

  /// Body shown when the vendor lookup API's upstream rate-limited it (429).
  ///
  /// In en, this message translates to:
  /// **'The vendor lookup API is being rate-limited. Wait a moment before trying again.'**
  String get lookupErrorRateLimitedBody;

  /// Body shown when the vendor lookup API rejected the MAC address as malformed (422).
  ///
  /// In en, this message translates to:
  /// **'The resolved MAC address was rejected as malformed by the vendor lookup API.'**
  String get lookupErrorInvalidMacBody;

  /// Fallback body shown for an unrecognized or unclassified lookup failure.
  ///
  /// In en, this message translates to:
  /// **'Something unexpected went wrong. Try again.'**
  String get lookupErrorUnexpectedBody;

  /// Title shown when the entered text is not a valid IPv4 address.
  ///
  /// In en, this message translates to:
  /// **'Invalid IP address'**
  String get invalidIpTitle;

  /// Body shown when the entered text is not a valid IPv4 address.
  ///
  /// In en, this message translates to:
  /// **'\"{value}\" is not a valid IPv4 address. Check the format and try again.'**
  String invalidIpBody(String value);

  /// Label for the button that detects and fills in the device's own primary IP address.
  ///
  /// In en, this message translates to:
  /// **'Use my IP'**
  String get useMyIpLabel;

  /// Title shown when auto-detecting the device's own IP address fails.
  ///
  /// In en, this message translates to:
  /// **'Could not detect your IP'**
  String get localIpDetectionErrorTitle;

  /// Body shown when auto-detecting the device's own IP address fails or finds nothing.
  ///
  /// In en, this message translates to:
  /// **'No active network interface with an IP address was found on this device.'**
  String get localIpDetectionErrorBody;

  /// Heading of the recent lookups panel.
  ///
  /// In en, this message translates to:
  /// **'Recent lookups'**
  String get recentLookupsHeading;

  /// Count label shown next to the recent lookups heading.
  ///
  /// In en, this message translates to:
  /// **'{count} total'**
  String recentLookupsCount(int count);

  /// Column header for the IP address in the recent lookups table.
  ///
  /// In en, this message translates to:
  /// **'IP'**
  String get ipColumnHeader;

  /// Column header for the MAC address in the recent lookups table.
  ///
  /// In en, this message translates to:
  /// **'MAC'**
  String get macColumnHeader;

  /// Column header for the vendor in the recent lookups table.
  ///
  /// In en, this message translates to:
  /// **'Vendor'**
  String get vendorColumnHeader;

  /// Column header for the timestamp in the recent lookups table.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeColumnHeader;

  /// Shown when there are no recent lookups yet.
  ///
  /// In en, this message translates to:
  /// **'Lookups will appear here once you search.'**
  String get recentLookupsEmpty;

  /// Shown while recent lookups are being fetched.
  ///
  /// In en, this message translates to:
  /// **'Loading recent lookups…'**
  String get recentLookupsLoading;

  /// Shown when fetching recent lookups failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load recent lookups.'**
  String get recentLookupsError;

  /// Shown in a recent lookups row when the MAC has no known vendor.
  ///
  /// In en, this message translates to:
  /// **'Unknown vendor'**
  String get unknownVendorRowText;

  /// Relative time label for events less than a minute ago.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get timeJustNow;

  /// Relative time label for events less than an hour ago.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String timeMinutesAgo(int minutes);

  /// Relative time label for events less than a day ago.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String timeHoursAgo(int hours);

  /// Relative time label for events a day or more ago.
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String timeDaysAgo(int days);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
