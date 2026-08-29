import 'package:app_ui/app_ui.dart';
import 'package:arp_vendor_lookup/l10n/l10n.dart';
import 'package:arp_vendor_lookup/vendor/vendor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LookupFormCard extends StatelessWidget {
  const LookupFormCard({
    required this.controller,
    required this.onSubmit,
    required this.onUseMyIp,
    super.key,
  });

  final TextEditingController controller;
  final VoidCallback onSubmit;
  final VoidCallback onUseMyIp;

  static const double _horizontalContentPadding = 14;
  static const double _verticalContentPadding = 12;
  static const double _ipFieldFontSize = 16;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;

    final isLoading = context.select<VendorBloc, bool>(
      (bloc) => bloc.state.lookupStatus == VendorLookupStatus.loading,
    );

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.lookupFormHeading,
                  style: textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              TextButton(
                onPressed: onUseMyIp,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(l10n.useMyIpLabel),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.ipAddressLabel.toUpperCase(),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: textTheme.labelMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    onSubmitted: isLoading ? null : (_) => onSubmit(),
                    style: AppTextStyles.mono(fontSize: _ipFieldFontSize),
                    decoration: InputDecoration(
                      hintText: l10n.ipAddressPlaceholder,
                      hintStyle: AppTextStyles.mono(
                        fontSize: _ipFieldFontSize,
                        color: AppColors.neutralSwatch,
                      ),
                      filled: true,
                      fillColor: AppColors.inputFill,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: _horizontalContentPadding,
                        vertical: _verticalContentPadding,
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
                          width: AppBorderWidth.thick,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                ElevatedButton(
                  onPressed: isLoading ? null : onSubmit,
                  child: Text(l10n.lookupButtonLabel),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.lookupHelperText,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
