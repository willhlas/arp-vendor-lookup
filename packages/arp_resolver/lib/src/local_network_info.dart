import 'dart:io';

import 'package:arp_resolver/arp_resolver.dart';

/// Lists the local machine's network addresses, matching the shape of
/// [NetworkInterface.list] flattened to just the addresses. Injected so
/// tests can stub interface discovery without depending on the real
/// host's network configuration (`NetworkInterface` itself has no public
/// constructor, so a fake can't easily be built at that level).
typedef NetworkAddressLister =
    Future<List<InternetAddress>> Function({
      InternetAddressType type,
      bool includeLoopback,
      bool includeLinkLocal,
    });

// One-method interface is intentional, mirroring ArpResolver: it exists so
// the real platform lookup is swappable with a fake in tests.
// ignore: one_member_abstracts
abstract class LocalNetworkInfo {
  /// Returns this machine's primary non-loopback IPv4 address, or `null`
  /// if no active interface currently has one — a normal result, not a
  /// failure.
  ///
  /// Throws [LocalNetworkInfoFailure] if the underlying platform call to
  /// list network interfaces itself fails.
  Future<String?> primaryIPv4Address();
}

class SystemLocalNetworkInfo implements LocalNetworkInfo {
  const SystemLocalNetworkInfo({NetworkAddressLister? listAddresses})
    : _listAddresses = listAddresses ?? _defaultListAddresses;

  final NetworkAddressLister _listAddresses;

  @override
  Future<String?> primaryIPv4Address() async {
    final List<InternetAddress> addresses;
    try {
      addresses = await _listAddresses(
        type: InternetAddressType.IPv4,
        includeLoopback: false,
        includeLinkLocal: false,
      );
    } catch (e) {
      throw LocalNetworkInfoFailure(
        'could not list network interfaces: $e',
      );
    }

    if (addresses.isEmpty) return null;
    return addresses.first.address;
  }
}

Future<List<InternetAddress>> _defaultListAddresses({
  InternetAddressType type = InternetAddressType.any,
  bool includeLoopback = false,
  bool includeLinkLocal = false,
}) async {
  final interfaces = await NetworkInterface.list(
    type: type,
    includeLoopback: includeLoopback,
    includeLinkLocal: includeLinkLocal,
  );
  return [
    for (final interface in interfaces) ...interface.addresses,
  ];
}
