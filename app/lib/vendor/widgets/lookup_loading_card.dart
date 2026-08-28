import 'package:app_ui/app_ui.dart';
import 'package:arp_vendor_lookup/l10n/l10n.dart';
import 'package:flutter/material.dart';

class LookupLoadingCard extends StatelessWidget {
  const LookupLoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 28),
      child: Column(
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.loadingStateText,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
