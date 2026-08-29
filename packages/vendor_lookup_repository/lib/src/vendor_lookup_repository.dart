import 'package:arp_resolver/arp_resolver.dart';
import 'package:vendor_api_client/vendor_api_client.dart';
import 'package:vendor_lookup_repository/vendor_lookup_repository.dart';

class VendorLookupRepository {
  const VendorLookupRepository({
    required this._arpResolver,
    required this._vendorApiClient,
  });

  final ArpResolver _arpResolver;
  final VendorApiClient _vendorApiClient;

  Future<VendorLookupResult> lookupByIp(String ip) async {
    final ArpEntry? entry;
    try {
      entry = await _arpResolver.resolve(ip);
    } catch (e) {
      throw ArpLookupFailure(
        'could not resolve $ip via the local ARP table: $e',
        e,
      );
    }

    if (entry == null) {
      return VendorLookupResult(ip: ip, mac: null, vendorLookup: null);
    }

    final Lookup lookup;
    try {
      lookup = await _vendorApiClient.lookupByMac(entry.mac, ip);
    } catch (e) {
      throw VendorApiLookupFailure(
        'could not look up vendor for ${entry.mac}: $e',
        e,
      );
    }

    return VendorLookupResult(ip: ip, mac: entry.mac, vendorLookup: lookup);
  }

  Future<List<Lookup>> recentLookups() async {
    try {
      return await _vendorApiClient.recentLookups();
    } catch (e) {
      throw VendorApiLookupFailure('could not fetch recent lookups: $e', e);
    }
  }
}
