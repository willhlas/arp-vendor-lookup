import 'package:app_ui/app_ui.dart';
import 'package:arp_vendor_lookup/l10n/l10n.dart';
import 'package:arp_vendor_lookup/vendor/vendor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vendor_lookup_repository/vendor_lookup_repository.dart';

class LookupUnknownVendorCard extends StatelessWidget {
  const LookupUnknownVendorCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;

    final result = context.select<VendorBloc, VendorLookupResult?>(
      (bloc) => bloc.state.result,
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
                  l10n.resultHeading,
                  style: textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              AppBadge(
                label: l10n.unknownVendorBadgeLabel,
                variant: AppBadgeVariant.warning,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppLabelValueRow(
            label: l10n.ipAddressLabel,
            value: Text(result?.ip ?? '', style: AppTextStyles.mono()),
          ),
          AppLabelValueRow(
            label: l10n.macAddressRowLabel,
            value: Text(result?.mac ?? '', style: AppTextStyles.mono()),
          ),
          AppLabelValueRow(
            label: l10n.vendorRowLabel,
            showDivider: false,
            value: Text(
              l10n.noVendorMatchText,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
