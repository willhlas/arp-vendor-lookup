import 'package:app_ui/src/theme/theme.dart';
import 'package:flutter/widgets.dart';

enum AppCardVariant { neutral, error }

class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(28),
    this.variant = AppCardVariant.neutral,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final AppCardVariant variant;

  @override
  Widget build(BuildContext context) {
    final isError = variant == AppCardVariant.error;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: isError ? AppColors.errorBackground : AppColors.surface,
        border: Border.all(
          color: isError ? AppColors.errorBorder : AppColors.border,
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: child,
    );
  }
}
