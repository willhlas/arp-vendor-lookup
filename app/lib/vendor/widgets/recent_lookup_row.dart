import 'package:app_ui/app_ui.dart';
import 'package:arp_vendor_lookup/l10n/l10n.dart';
import 'package:arp_vendor_lookup/vendor/util/relative_time.dart';
import 'package:flutter/material.dart';
import 'package:vendor_api_client/vendor_api_client.dart';

class RecentLookupRow extends StatelessWidget {
  const RecentLookupRow({required this.lookup, super.key});

  final Lookup lookup;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = context.theme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(lookup.ip, style: AppTextStyles.mono(fontSize: 13)),
          ),
          Expanded(
            flex: 2,
            child: Text(lookup.mac, style: AppTextStyles.mono(fontSize: 13)),
          ),
          Expanded(
            flex: 4,
            child: lookup.found
                ? Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: vendorSwatchColor(lookup.vendorName!),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          lookup.vendorName!,
                          style: theme.textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                : Text(
                    l10n.unknownVendorRowText,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
          ),
          Expanded(
            child: Text(
              formatRelativeTime(lookup.createdAt, l10n: l10n),
              textAlign: TextAlign.right,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
