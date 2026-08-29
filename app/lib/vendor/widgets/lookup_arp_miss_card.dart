import 'package:app_ui/app_ui.dart';
import 'package:arp_vendor_lookup/l10n/l10n.dart';
import 'package:arp_vendor_lookup/vendor/vendor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vendor_lookup_repository/vendor_lookup_repository.dart';

class LookupArpMissCard extends StatelessWidget {
  const LookupArpMissCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = context.theme;
    final textTheme = theme.textTheme;

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
                label: l10n.noArpEntryBadgeLabel,
                variant: AppBadgeVariant.warning,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppLabelValueRow(
            label: l10n.ipAddressLabel,
            value: Text(result?.ip ?? '', style: AppTextStyles.mono()),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.noArpEntryExplanation,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
