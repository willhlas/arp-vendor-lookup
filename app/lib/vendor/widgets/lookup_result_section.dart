import 'package:arp_vendor_lookup/l10n/l10n.dart';
import 'package:arp_vendor_lookup/vendor/bloc/vendor_bloc.dart';
import 'package:arp_vendor_lookup/vendor/widgets/lookup_arp_miss_card.dart';
import 'package:arp_vendor_lookup/vendor/widgets/lookup_empty_card.dart';
import 'package:arp_vendor_lookup/vendor/widgets/lookup_error_card.dart';
import 'package:arp_vendor_lookup/vendor/widgets/lookup_loading_card.dart';
import 'package:arp_vendor_lookup/vendor/widgets/lookup_resolved_card.dart';
import 'package:arp_vendor_lookup/vendor/widgets/lookup_unknown_vendor_card.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LookupResultSection extends StatelessWidget {
  const LookupResultSection({super.key});

  @override
  Widget build(BuildContext context) {
    final status = context.select<VendorBloc, VendorLookupStatus>(
      (bloc) => bloc.state.lookupStatus,
    );

    switch (status) {
      case VendorLookupStatus.initial:
        return const LookupEmptyCard();
      case VendorLookupStatus.loading:
        return const LookupLoadingCard();
      case VendorLookupStatus.error:
        final errorMessage = context.select<VendorBloc, String?>(
          (bloc) => bloc.state.lookupErrorMessage,
        );
        return LookupErrorCard(
          title: context.l10n.lookupFailedTitle,
          body: errorMessage ?? '',
        );
      case VendorLookupStatus.success:
        final isArpMiss = context.select<VendorBloc, bool>(
          (bloc) => bloc.state.isArpMiss,
        );
        if (isArpMiss) return const LookupArpMissCard();

        final isVendorFound = context.select<VendorBloc, bool>(
          (bloc) => bloc.state.isVendorFound,
        );
        return isVendorFound
            ? const LookupResolvedCard()
            : const LookupUnknownVendorCard();
    }
  }
}
