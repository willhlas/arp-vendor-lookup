import 'package:app_ui/src/theme/theme.dart';
import 'package:flutter/widgets.dart';

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
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label.toUpperCase(),
              style: AppTextStyles.textTheme.labelMedium?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 0.4,
              ),
            ),
            value,
          ],
        ),
        if (showDivider) ...[
          const SizedBox(height: 14),
          Container(height: 1, color: AppColors.divider),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}
