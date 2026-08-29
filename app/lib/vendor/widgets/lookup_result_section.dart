import 'package:arp_vendor_lookup/l10n/l10n.dart';
import 'package:arp_vendor_lookup/vendor/vendor.dart';
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
        final errorKind = context.select<VendorBloc, VendorLookupErrorKind?>(
          (bloc) => bloc.state.lookupErrorKind,
        );
        return LookupErrorCard(
          title: context.l10n.lookupFailedTitle,
          body: lookupErrorBody(context.l10n, errorKind),
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
