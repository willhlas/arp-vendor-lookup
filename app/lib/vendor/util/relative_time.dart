import 'package:arp_vendor_lookup/l10n/l10n.dart';

/// Formats [dateTime] as a short relative-time label ("2m ago", "3h ago"),
/// relative to [now] (defaults to the current time).
String formatRelativeTime(
  DateTime dateTime, {
  required AppLocalizations l10n,
  DateTime? now,
}) {
  final difference = (now ?? DateTime.now()).difference(dateTime);

  if (difference.inMinutes < 1) return l10n.timeJustNow;
  if (difference.inHours < 1) return l10n.timeMinutesAgo(difference.inMinutes);
  if (difference.inDays < 1) return l10n.timeHoursAgo(difference.inHours);
  return l10n.timeDaysAgo(difference.inDays);
}
