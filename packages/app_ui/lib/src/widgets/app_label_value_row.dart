import 'package:app_ui/src/theme/theme.dart';
import 'package:flutter/material.dart';

class AppLabelValueRow extends StatelessWidget {
  const AppLabelValueRow({
    required this.label,
    required this.value,
    this.showDivider = true,
    super.key,
  });

  final String label;
  final Widget value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return Column(
      children: [
        Row(
          children: [
            Text(
              label.toUpperCase(),
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Align(alignment: Alignment.centerRight, child: value),
            ),
          ],
        ),
        if (showDivider) ...const [
          SizedBox(height: AppSpacing.sm),
          Divider(),
          SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}
