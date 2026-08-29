import 'package:app_ui/app_ui.dart';
import 'package:arp_vendor_lookup/l10n/l10n.dart';
import 'package:arp_vendor_lookup/vendor/vendor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vendor_api_client/vendor_api_client.dart';

class RecentLookupsPanel extends StatelessWidget {
  const RecentLookupsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;

    final status = context.select<VendorBloc, RecentLookupsStatus>(
      (bloc) => bloc.state.recentStatus,
    );
    final recentLookupsCount = context.select<VendorBloc, int>(
      (bloc) => bloc.state.recentLookups.length,
    );

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.recentLookupsHeading,
                  style: textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (status == RecentLookupsStatus.success) ...[
                const SizedBox(width: AppSpacing.sm),
                Text(
                  l10n.recentLookupsCount(recentLookupsCount),
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Expanded(child: _RecentLookups()),
        ],
      ),
    );
  }
}

class _RecentLookups extends StatelessWidget {
  const _RecentLookups();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;

    final status = context.select<VendorBloc, RecentLookupsStatus>(
      (bloc) => bloc.state.recentStatus,
    );
    final recentLookups = context.select<VendorBloc, List<Lookup>>(
      (bloc) => bloc.state.recentLookups,
    );

    switch (status) {
      case RecentLookupsStatus.initial:
      case RecentLookupsStatus.loading:
        return Center(
          child: Text(
            l10n.recentLookupsLoading,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        );
      case RecentLookupsStatus.error:
        return Center(
          child: Text(
            l10n.recentLookupsError,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        );
      case RecentLookupsStatus.success:
        if (recentLookups.isEmpty) {
          return Center(
            child: Text(
              l10n.recentLookupsEmpty,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _ColumnHeaderRow(),
            Expanded(
              child: ListView.builder(
                itemCount: recentLookups.length,
                itemBuilder: (context, index) {
                  return RecentLookupRow(lookup: recentLookups[index]);
                },
              ),
            ),
          ],
        );
    }
  }
}

class _ColumnHeaderRow extends StatelessWidget {
  const _ColumnHeaderRow();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;

    final style = textTheme.labelSmall?.copyWith(
      color: AppColors.textSecondary,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
    );

    return Container(
      padding: const EdgeInsets.only(left: 14, right: 14, bottom: 10),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 1.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              l10n.ipColumnHeader.toUpperCase(),
              style: style,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            flex: 2,
            child: Text(
              l10n.macColumnHeader.toUpperCase(),
              style: style,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            flex: 4,
            child: Text(
              l10n.vendorColumnHeader.toUpperCase(),
              style: style,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              l10n.timeColumnHeader.toUpperCase(),
              textAlign: TextAlign.right,
              style: style,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
