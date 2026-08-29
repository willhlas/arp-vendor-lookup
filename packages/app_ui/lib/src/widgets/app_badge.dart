import 'package:app_ui/src/theme/theme.dart';
import 'package:flutter/material.dart';

enum AppBadgeVariant { success, warning, error, neutral }

class AppBadge extends StatelessWidget {
  const AppBadge({
    required this.label,
    required this.variant,
    super.key,
  });

  final String label;
  final AppBadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colors = variant.colors;

    return Material(
      color: colors.background,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        child: Text(
          label.toUpperCase(),
          style: textTheme.labelSmall?.copyWith(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: colors.foreground,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

extension on AppBadgeVariant {
  ({Color background, Color foreground}) get colors => switch (this) {
    AppBadgeVariant.success => (
      background: AppColors.successBackground,
      foreground: AppColors.success,
    ),
    AppBadgeVariant.warning => (
      background: AppColors.warningBackground,
      foreground: AppColors.warning,
    ),
    AppBadgeVariant.error => (
      background: AppColors.errorBackground,
      foreground: AppColors.error,
    ),
    AppBadgeVariant.neutral => (
      background: AppColors.hoverFill,
      foreground: AppColors.textSecondary,
    ),
  };
}
