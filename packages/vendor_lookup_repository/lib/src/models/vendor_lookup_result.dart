import 'package:equatable/equatable.dart';
import 'package:vendor_api_client/vendor_api_client.dart';

class VendorLookupResult extends Equatable {
  const VendorLookupResult({
    required this.ip,
    required this.mac,
    required this.vendorLookup,
  });

  final String ip;

  /// The MAC resolved from the local ARP table for [ip], or `null` if the
  /// ARP table had no entry ("ARP miss") — a normal outcome, not a failure.
  final String? mac;

  /// The vendor API's result for [mac], or `null` when [mac] is `null`
  /// (ARP miss — no vendor lookup was attempted). Never `null` when [mac]
  /// is non-null.
  final Lookup? vendorLookup;

  /// True when the local ARP table has no entry for [ip].
  bool get arpMiss => mac == null;

  /// True when a vendor name was found. Always `false` when [arpMiss].
  bool get found => vendorLookup?.found ?? false;

  @override
  List<Object?> get props => [ip, mac, vendorLookup];
}
