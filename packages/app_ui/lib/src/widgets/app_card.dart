import 'package:app_ui/src/theme/theme.dart';
import 'package:flutter/material.dart';

enum AppCardVariant { neutral, error }

class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.variant = AppCardVariant.neutral,
    super.key,
  });

  final EdgeInsetsGeometry padding;
  final AppCardVariant variant;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = variant.colors;

    return Material(
      color: colors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: colors.border),
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}

extension on AppCardVariant {
  ({Color background, Color border}) get colors => switch (this) {
    AppCardVariant.neutral => (
      background: AppColors.surface,
      border: AppColors.border,
    ),
    AppCardVariant.error => (
      background: AppColors.errorBackground,
      border: AppColors.errorBorder,
    ),
  };
}
