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
  bool _localIpDetectionFailed = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final ip = _controller.text.trim();
    if (!isValidIPv4(ip)) {
      setState(() {
        _invalidIp = ip;
        _localIpDetectionFailed = false;
      });
      return;
    }
    setState(() {
      _invalidIp = null;
      _localIpDetectionFailed = false;
    });
    context.read<VendorBloc>().add(VendorLookupRequested(ip));
  }

  void _handleUseMyIp() {
    setState(() {
      _invalidIp = null;
      _localIpDetectionFailed = false;
    });
    context.read<VendorBloc>().add(const VendorLocalIpDetectionRequested());
  }

  @override
  Widget build(BuildContext context) {
    final invalidIp = _invalidIp;

    return BlocListener<VendorBloc, VendorState>(
      listenWhen: (previous, current) =>
          previous.localIpDetectionStatus != current.localIpDetectionStatus,
      listener: (context, state) {
        switch (state.localIpDetectionStatus) {
          case LocalIpDetectionStatus.success:
            final ip = state.detectedLocalIp;
            if (ip != null) {
              setState(() => _controller.text = ip);
            }
          case LocalIpDetectionStatus.error:
            setState(() => _localIpDetectionFailed = true);
          case LocalIpDetectionStatus.initial:
          case LocalIpDetectionStatus.loading:
            break;
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LookupFormCard(
            controller: _controller,
            onSubmit: _handleSubmit,
            onUseMyIp: _handleUseMyIp,
          ),
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
          else if (_localIpDetectionFailed)
            Builder(
              builder: (context) {
                final l10n = context.l10n;

                return LookupErrorCard(
                  title: l10n.localIpDetectionErrorTitle,
                  body: l10n.localIpDetectionErrorBody,
                );
              },
            )
          else
            const LookupResultSection(),
        ],
      ),
    );
  }
}
