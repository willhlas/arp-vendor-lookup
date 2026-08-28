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
      create: (_) => VendorBloc(vendorLookupRepository: vendorLookupRepository),
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
      home: Scaffold(
        appBar: AppBar(title: const Text('ARP Vendor Lookup')),
        body: const Center(
          child: Text('Welcome to the ARP Vendor Lookup app!'),
        ),
      ),
    );
  }
}
