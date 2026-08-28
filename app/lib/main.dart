import 'package:arp_resolver/arp_resolver.dart';
import 'package:arp_vendor_lookup/app/app.dart';
import 'package:flutter/material.dart';
import 'package:vendor_api_client/vendor_api_client.dart';
import 'package:vendor_lookup_repository/vendor_lookup_repository.dart';

void main() {
  final arpResolver = createArpResolver();
  const localNetworkInfo = SystemLocalNetworkInfo();
  final vendorApiClient = VendorApiClient(
    baseUrl: 'http://localhost:3000',
  );
  final vendorLookupRepository = VendorLookupRepository(
    arpResolver: arpResolver,
    vendorApiClient: vendorApiClient,
  );

  runApp(
    App(
      vendorLookupRepository: vendorLookupRepository,
      localNetworkInfo: localNetworkInfo,
    ),
  );
}
