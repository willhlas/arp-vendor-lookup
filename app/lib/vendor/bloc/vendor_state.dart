part of 'vendor_bloc.dart';

enum VendorLookupStatus { initial, loading, success, error }

enum RecentLookupsStatus { initial, loading, success, error }

enum LocalIpDetectionStatus { initial, loading, success, error }

enum VendorLookupErrorKind {
  arpCommandFailed,
  arpOutputUnparseable,
  networkUnreachable,
  upstreamUnavailable,
  upstreamBadResponse,
  rateLimited,
  invalidMac,
  unexpectedResponse,
  unknown,
}

class VendorState extends Equatable {
  const VendorState({
    this.lookupStatus = VendorLookupStatus.initial,
    this.result,
    this.lookupErrorMessage,
    this.lookupErrorKind,
    this.recentStatus = RecentLookupsStatus.initial,
    this.recentLookups = const [],
    this.recentErrorMessage,
    this.localIpDetectionStatus = LocalIpDetectionStatus.initial,
    this.detectedLocalIp,
    this.localIpDetectionErrorMessage,
  });

  final VendorLookupStatus lookupStatus;
  final VendorLookupResult? result;
  final String? lookupErrorMessage;
  final VendorLookupErrorKind? lookupErrorKind;

  final RecentLookupsStatus recentStatus;
  final List<Lookup> recentLookups;
  final String? recentErrorMessage;

  final LocalIpDetectionStatus localIpDetectionStatus;
  final String? detectedLocalIp;
  final String? localIpDetectionErrorMessage;

  bool get isArpMiss => result?.arpMiss ?? false;
  bool get isVendorFound => result?.found ?? false;

  VendorState copyWith({
    VendorLookupStatus? lookupStatus,
    VendorLookupResult? result,
    String? lookupErrorMessage,
    VendorLookupErrorKind? lookupErrorKind,
    RecentLookupsStatus? recentStatus,
    List<Lookup>? recentLookups,
    String? recentErrorMessage,
    LocalIpDetectionStatus? localIpDetectionStatus,
    String? detectedLocalIp,
    String? localIpDetectionErrorMessage,
  }) {
    return VendorState(
      lookupStatus: lookupStatus ?? this.lookupStatus,
      result: result ?? this.result,
      lookupErrorMessage: lookupErrorMessage ?? this.lookupErrorMessage,
      lookupErrorKind: lookupErrorKind ?? this.lookupErrorKind,
      recentStatus: recentStatus ?? this.recentStatus,
      recentLookups: recentLookups ?? this.recentLookups,
      recentErrorMessage: recentErrorMessage ?? this.recentErrorMessage,
      localIpDetectionStatus:
          localIpDetectionStatus ?? this.localIpDetectionStatus,
      detectedLocalIp: detectedLocalIp ?? this.detectedLocalIp,
      localIpDetectionErrorMessage:
          localIpDetectionErrorMessage ?? this.localIpDetectionErrorMessage,
    );
  }

  @override
  List<Object?> get props => [
    lookupStatus,
    result,
    lookupErrorMessage,
    lookupErrorKind,
    recentStatus,
    recentLookups,
    recentErrorMessage,
    localIpDetectionStatus,
    detectedLocalIp,
    localIpDetectionErrorMessage,
  ];
}
