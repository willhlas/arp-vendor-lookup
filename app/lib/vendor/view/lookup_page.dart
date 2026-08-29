import 'package:app_ui/app_ui.dart';
import 'package:arp_vendor_lookup/l10n/l10n.dart';
import 'package:arp_vendor_lookup/vendor/vendor.dart';
import 'package:flutter/material.dart';

class LookupPage extends StatelessWidget {
  const LookupPage({super.key});

  static const double _maxContentWidth = 1440;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.xl,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxContentWidth),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _LookupHeader(),
                  SizedBox(height: AppSpacing.xl),
                  _LookupContent(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LookupContent extends StatelessWidget {
  const _LookupContent();

  static const double _wideLayoutBreakpoint = 900;
  static const double _recentLookupsPanelHeight = 420;
  static const double _lookupSectionWidth = 520;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const recentLookupsPanel = SizedBox(
          height: _recentLookupsPanelHeight,
          child: RecentLookupsPanel(),
        );

        if (constraints.maxWidth >= _wideLayoutBreakpoint) {
          return const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: _lookupSectionWidth, child: LookupSection()),
              SizedBox(width: AppSpacing.xl),
              Expanded(child: recentLookupsPanel),
            ],
          );
        }

        return const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LookupSection(),
            SizedBox(height: AppSpacing.xl),
            recentLookupsPanel,
          ],
        );
      },
    );
  }
}

class _LookupHeader extends StatelessWidget {
  const _LookupHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = context.theme;
    final textTheme = theme.textTheme;

    return Row(
      children: [
        const AppLogo(),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.appTitle,
                style: textTheme.titleLarge,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Text(
                l10n.appSubtitle,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
