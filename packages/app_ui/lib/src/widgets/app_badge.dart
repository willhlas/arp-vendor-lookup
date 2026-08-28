import 'package:app_ui/src/theme/theme.dart';
import 'package:flutter/widgets.dart';

enum AppBadgeVariant { success, warning, error, neutral }

class AppBadge extends StatelessWidget {
  const AppBadge({required this.label, required this.variant, super.key});

  final String label;
  final AppBadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (variant) {
      AppBadgeVariant.success => (
        AppColors.successBackground,
        AppColors.success,
      ),
      AppBadgeVariant.warning => (
        AppColors.warningBackground,
        AppColors.warning,
      ),
      AppBadgeVariant.error => (AppColors.errorBackground, AppColors.error),
      AppBadgeVariant.neutral => (AppColors.hoverFill, AppColors.textSecondary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.textTheme.labelSmall?.copyWith(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: foreground,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
