/// Returns whether [value] is a valid IPv4 address in dotted-decimal form
/// (exactly four segments, each an integer from 0 to 255, no extra
/// whitespace or leading/trailing dots).
bool isValidIPv4(String value) {
  final segments = value.split('.');
  if (segments.length != 4) return false;

  for (final segment in segments) {
    if (segment.isEmpty) return false;
    final number = int.tryParse(segment);
    if (number == null || number < 0 || number > 255) return false;
    if (segment != number.toString()) return false;
  }

  return true;
}
