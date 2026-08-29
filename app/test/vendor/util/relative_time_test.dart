import 'package:arp_vendor_lookup/l10n/l10n.dart';
import 'package:arp_vendor_lookup/vendor/vendor.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatRelativeTime', () {
    late AppLocalizations l10n;
    final now = DateTime(2026);

    setUp(() async {
      l10n = await AppLocalizations.delegate.load(const Locale('en'));
    });

    test('returns "just now" for less than a minute ago', () {
      final dateTime = now.subtract(const Duration(seconds: 30));
      expect(
        formatRelativeTime(dateTime, l10n: l10n, now: now),
        equals(l10n.timeJustNow),
      );
    });

    test('returns minutes ago for less than an hour ago', () {
      final dateTime = now.subtract(const Duration(minutes: 14));
      expect(
        formatRelativeTime(dateTime, l10n: l10n, now: now),
        equals(l10n.timeMinutesAgo(14)),
      );
    });

    test('returns hours ago for less than a day ago', () {
      final dateTime = now.subtract(const Duration(hours: 3));
      expect(
        formatRelativeTime(dateTime, l10n: l10n, now: now),
        equals(l10n.timeHoursAgo(3)),
      );
    });

    test('returns days ago for a day or more ago', () {
      final dateTime = now.subtract(const Duration(days: 2));
      expect(
        formatRelativeTime(dateTime, l10n: l10n, now: now),
        equals(l10n.timeDaysAgo(2)),
      );
    });
  });
}
