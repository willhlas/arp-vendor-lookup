import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(vendorSwatchColor, () {
    test('returns the same color for the same seed', () {
      final first = vendorSwatchColor('Acme Corp');
      final second = vendorSwatchColor('Acme Corp');

      expect(first, equals(second));
    });

    test('stays within the fixed palette across repeated calls', () {
      final palette = {
        const Color(0xFF95A0AB),
        const Color(0xFF0074CA),
        const Color(0xFFB94642),
        const Color(0xFF319751),
        const Color(0xFF008892),
        const Color(0xFF396FC8),
      };

      for (final seed in ['Acme Corp', 'Globex', '', 'Vendor 123', 'a']) {
        expect(palette, contains(vendorSwatchColor(seed)));
      }
    });

    test('different seeds can map to different colors', () {
      final colors = {
        vendorSwatchColor('Acme Corp'),
        vendorSwatchColor('Globex'),
        vendorSwatchColor('Initech'),
      };

      expect(colors.length, greaterThan(1));
    });
  });
}
