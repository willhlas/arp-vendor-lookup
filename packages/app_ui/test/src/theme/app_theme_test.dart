import 'package:app_ui/app_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(AppTheme, () {
    test('exposes ThemeData built from the app colors and text theme', () {
      final theme = const AppTheme().themeData;

      expect(theme.scaffoldBackgroundColor, AppColors.background);
      expect(theme.colorScheme.primary, AppColors.accent);
      expect(theme.colorScheme.error, AppColors.error);
      expect(theme.textTheme.bodyMedium?.color, AppColors.textPrimary);
    });
  });
}
