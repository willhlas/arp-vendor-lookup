import 'package:app_ui/app_ui.dart';
import 'package:arp_vendor_lookup/l10n/l10n.dart';
import 'package:arp_vendor_lookup/vendor/bloc/vendor_bloc.dart';
import 'package:arp_vendor_lookup/vendor/widgets/recent_lookup_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vendor_api_client/vendor_api_client.dart';

class RecentLookupsPanel extends StatelessWidget {
  const RecentLookupsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = context.theme;

    final status = context.select<VendorBloc, RecentLookupsStatus>(
      (bloc) => bloc.state.recentStatus,
    );
    final recentLookups = context.select<VendorBloc, List<Lookup>>(
      (bloc) => bloc.state.recentLookups,
    );
    final count = recentLookups.length;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.recentLookupsHeading,
                  style: theme.textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (status == RecentLookupsStatus.success)
                Text(
                  l10n.recentLookupsCount(count),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(child: _buildBody(context, status, recentLookups)),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    RecentLookupsStatus status,
    List<Lookup> recentLookups,
  ) {
    final l10n = context.l10n;
    final theme = context.theme;

    switch (status) {
      case RecentLookupsStatus.initial:
      case RecentLookupsStatus.loading:
        return Center(
          child: Text(
            l10n.recentLookupsLoading,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        );
      case RecentLookupsStatus.error:
        return Center(
          child: Text(
            l10n.recentLookupsError,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        );
      case RecentLookupsStatus.success:
        if (recentLookups.isEmpty) {
          return Center(
            child: Text(
              l10n.recentLookupsEmpty,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ColumnHeaderRow(l10n: l10n, theme: theme),
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
  const _ColumnHeaderRow({required this.l10n, required this.theme});

  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final style = theme.textTheme.labelSmall?.copyWith(
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
            child: Text(l10n.ipColumnHeader.toUpperCase(), style: style),
          ),
          Expanded(
            flex: 2,
            child: Text(l10n.macColumnHeader.toUpperCase(), style: style),
          ),
          Expanded(
            flex: 4,
            child: Text(l10n.vendorColumnHeader.toUpperCase(), style: style),
          ),
          Expanded(
            child: Text(
              l10n.timeColumnHeader.toUpperCase(),
              textAlign: TextAlign.right,
              style: style,
            ),
          ),
        ],
      ),
    );
  }
}
