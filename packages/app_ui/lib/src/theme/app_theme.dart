import 'package:app_ui/src/theme/colors/app_colors.dart';
import 'package:app_ui/src/theme/typography/app_text_styles.dart';
import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme();

  ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: AppTextStyles.textTheme,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accent,
        primary: AppColors.accent,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
      ),
    );
  }
}

extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
}
