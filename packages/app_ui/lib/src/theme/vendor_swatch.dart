import 'package:flutter/painting.dart';

const List<Color> _vendorSwatchPalette = [
  Color(0xFF95A0AB),
  Color(0xFF0074CA),
  Color(0xFFB94642),
  Color(0xFF319751),
  Color(0xFF008892),
  Color(0xFF396FC8),
];

/// Deterministically maps a vendor name to one of a small fixed palette of
/// colors, so the same vendor always gets the same swatch color.
///
/// A fancy thing Claude did.
Color vendorSwatchColor(String seed) {
  final index =
      seed.codeUnits.fold<int>(0, (sum, unit) => sum + unit) %
      _vendorSwatchPalette.length;
  return _vendorSwatchPalette[index];
}
