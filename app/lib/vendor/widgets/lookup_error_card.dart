import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

class LookupErrorCard extends StatelessWidget {
  const LookupErrorCard({
    required this.title,
    required this.body,
    super.key,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return AppCard(
      variant: AppCardVariant.error,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 28),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
            ),
            child: const Text(
              '!',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleSmall?.copyWith(
                    color: AppColors.errorTitle,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.errorBody,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
