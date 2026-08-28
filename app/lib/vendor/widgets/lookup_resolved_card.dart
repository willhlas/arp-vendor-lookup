import 'package:app_ui/app_ui.dart';
import 'package:arp_vendor_lookup/l10n/l10n.dart';
import 'package:arp_vendor_lookup/vendor/bloc/vendor_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vendor_lookup_repository/vendor_lookup_repository.dart';

class LookupResolvedCard extends StatelessWidget {
  const LookupResolvedCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = context.theme;

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.resultHeading, style: theme.textTheme.titleMedium),
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
                  style: theme.textTheme.titleSmall?.copyWith(
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
