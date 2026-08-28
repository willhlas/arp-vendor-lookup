import 'package:app_ui/app_ui.dart';
import 'package:arp_vendor_lookup/l10n/l10n.dart';
import 'package:flutter/material.dart';

class LookupEmptyCard extends StatelessWidget {
  const LookupEmptyCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = context.theme;

    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 28),
      child: Column(
        children: [
          const Text(
            '◌',
            style: TextStyle(fontSize: 32, color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.emptyStateTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.emptyStateBody,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
