import 'package:app_ui/app_ui.dart';
import 'package:arp_vendor_lookup/l10n/l10n.dart';
import 'package:arp_vendor_lookup/vendor/bloc/vendor_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vendor_lookup_repository/vendor_lookup_repository.dart';

class LookupUnknownVendorCard extends StatelessWidget {
  const LookupUnknownVendorCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = context.theme;

    final result = context.select<VendorBloc, VendorLookupResult?>(
      (bloc) => bloc.state.result,
    );

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
              style: theme.textTheme.bodySmall?.copyWith(
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
