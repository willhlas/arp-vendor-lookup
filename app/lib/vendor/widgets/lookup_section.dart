import 'package:arp_vendor_lookup/l10n/l10n.dart';
import 'package:arp_vendor_lookup/vendor/bloc/vendor_bloc.dart';
import 'package:arp_vendor_lookup/vendor/util/ip_validator.dart';
import 'package:arp_vendor_lookup/vendor/widgets/lookup_error_card.dart';
import 'package:arp_vendor_lookup/vendor/widgets/lookup_form_card.dart';
import 'package:arp_vendor_lookup/vendor/widgets/lookup_result_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LookupSection extends StatefulWidget {
  const LookupSection({super.key});

  @override
  State<LookupSection> createState() => _LookupSectionState();
}

class _LookupSectionState extends State<LookupSection> {
  final _controller = TextEditingController();
  String? _invalidIp;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final ip = _controller.text.trim();
    if (!isValidIPv4(ip)) {
      setState(() => _invalidIp = ip);
      return;
    }
    setState(() => _invalidIp = null);
    context.read<VendorBloc>().add(VendorLookupRequested(ip));
  }

  @override
  Widget build(BuildContext context) {
    final invalidIp = _invalidIp;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LookupFormCard(controller: _controller, onSubmit: _handleSubmit),
        const SizedBox(height: 20),
        if (invalidIp != null)
          Builder(
            builder: (context) {
              final l10n = context.l10n;

              return LookupErrorCard(
                title: l10n.invalidIpTitle,
                body: l10n.invalidIpBody(invalidIp),
              );
            },
          )
        else
          const LookupResultSection(),
      ],
    );
  }
}
