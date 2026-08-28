import 'package:app_ui/app_ui.dart';
import 'package:arp_vendor_lookup/l10n/l10n.dart';
import 'package:arp_vendor_lookup/vendor/vendor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vendor_lookup_repository/vendor_lookup_repository.dart';

class App extends StatelessWidget {
  const App({
    required this.vendorLookupRepository,
    super.key,
  });

  final VendorLookupRepository vendorLookupRepository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          VendorBloc(vendorLookupRepository: vendorLookupRepository)
            ..add(const VendorRecentLookupsRequested()),
      child: const AppView(),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: const AppTheme().themeData,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const LookupPage(),
    );
  }
}
