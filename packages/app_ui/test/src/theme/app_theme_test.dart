import 'package:app_ui/app_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(AppTheme, () {
    test('can be instantiated', () {
      expect(const AppTheme(), isNotNull);
    });
  });
}
