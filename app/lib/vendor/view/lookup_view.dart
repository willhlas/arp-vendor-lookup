import 'package:arp_vendor_lookup/vendor/widgets/lookup_section.dart';
import 'package:arp_vendor_lookup/vendor/widgets/recent_lookups_panel.dart';
import 'package:flutter/widgets.dart';

class LookupView extends StatelessWidget {
  const LookupView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 520, child: LookupSection()),
        SizedBox(width: 32),
        Expanded(child: RecentLookupsPanel()),
      ],
    );
  }
}
