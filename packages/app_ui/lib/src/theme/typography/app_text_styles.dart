import 'package:app_ui/src/generated/fonts.gen.dart';
import 'package:app_ui/src/theme/colors/app_colors.dart';
import 'package:flutter/material.dart';

abstract final class AppTextStyles {
  static const String _headingFontFamily = FontFamily.spaceGrotesk;
  static const String _bodyFontFamily = FontFamily.inter;
  static const String _monoFontFamily = FontFamily.iBMPlexMono;
  static const String _package = 'app_ui';

  static TextTheme get textTheme {
    final headings = Typography.englishLike2021.apply(
      fontFamily: _headingFontFamily,
      package: _package,
    );
    return Typography.englishLike2021
        .apply(fontFamily: _bodyFontFamily, package: _package)
        .copyWith(
          displayLarge: headings.displayLarge,
          displayMedium: headings.displayMedium,
          displaySmall: headings.displaySmall,
          headlineLarge: headings.headlineLarge,
          headlineMedium: headings.headlineMedium,
          headlineSmall: headings.headlineSmall,
          titleLarge: headings.titleLarge,
          titleMedium: headings.titleMedium,
          titleSmall: headings.titleSmall,
        )
        .apply(
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
          package: _package,
        );
  }

  static TextStyle mono({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: _monoFontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? AppColors.textPrimary,
      package: _package,
    );
  }
}
