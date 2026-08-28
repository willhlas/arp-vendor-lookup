import 'package:app_ui/app_ui.dart';
import 'package:arp_vendor_lookup/l10n/l10n.dart';
import 'package:flutter/material.dart';

class LookupFormCard extends StatelessWidget {
  const LookupFormCard({
    required this.controller,
    required this.onSubmit,
    super.key,
  });

  final TextEditingController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = context.theme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.lookupFormHeading, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.ipAddressLabel.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  onSubmitted: (_) => onSubmit(),
                  style: AppTextStyles.mono(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: l10n.ipAddressPlaceholder,
                    filled: true,
                    fillColor: AppColors.inputFill,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      borderSide: const BorderSide(
                        color: AppColors.borderStrong,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      borderSide: const BorderSide(
                        color: AppColors.borderStrong,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      borderSide: const BorderSide(
                        color: AppColors.accent,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              ElevatedButton(
                onPressed: onSubmit,
                child: Text(l10n.lookupButtonLabel),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.lookupHelperText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
