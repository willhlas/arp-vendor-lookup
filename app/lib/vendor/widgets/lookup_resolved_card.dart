import 'package:app_ui/app_ui.dart';
import 'package:arp_vendor_lookup/l10n/l10n.dart';
import 'package:arp_vendor_lookup/vendor/vendor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vendor_lookup_repository/vendor_lookup_repository.dart';

class LookupResolvedCard extends StatelessWidget {
  const LookupResolvedCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;

    final result = context.select<VendorBloc, VendorLookupResult?>(
      (bloc) => bloc.state.result,
    );
    final vendorName = result?.vendorLookup?.vendorName ?? '';

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
                label: l10n.resolvedBadgeLabel,
                variant: AppBadgeVariant.success,
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
            value: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: vendorSwatchColor(vendorName),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  vendorName,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: textTheme.titleSmall?.copyWith(
                    color: AppColors.textPrimary,
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
