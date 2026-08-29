import 'package:app_ui/app_ui.dart';
import 'package:arp_vendor_lookup/l10n/l10n.dart';
import 'package:arp_vendor_lookup/vendor/vendor.dart';
import 'package:flutter/material.dart';
import 'package:vendor_api_client/vendor_api_client.dart';

class RecentLookupRow extends StatelessWidget {
  const RecentLookupRow({required this.lookup, super.key});

  final Lookup lookup;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              lookup.ip,
              style: AppTextStyles.mono(fontSize: 13),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            flex: 2,
            child: Text(
              lookup.mac,
              style: AppTextStyles.mono(fontSize: 13),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
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
                          style: textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  )
                : Text(
                    l10n.unknownVendorRowText,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              formatRelativeTime(lookup.createdAt, l10n: l10n),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
