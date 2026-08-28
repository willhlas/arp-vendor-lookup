part of 'vendor_bloc.dart';

enum VendorLookupStatus { initial, loading, success, error }

enum RecentLookupsStatus { initial, loading, success, error }

class VendorState extends Equatable {
  const VendorState({
    this.lookupStatus = VendorLookupStatus.initial,
    this.result,
    this.lookupErrorMessage,
    this.recentStatus = RecentLookupsStatus.initial,
    this.recentLookups = const [],
    this.recentErrorMessage,
  });

  final VendorLookupStatus lookupStatus;
  final VendorLookupResult? result;
  final String? lookupErrorMessage;

  final RecentLookupsStatus recentStatus;
  final List<Lookup> recentLookups;
  final String? recentErrorMessage;

  bool get isArpMiss => result?.arpMiss ?? false;
  bool get isVendorFound => result?.found ?? false;

  VendorState copyWith({
    VendorLookupStatus? lookupStatus,
    VendorLookupResult? result,
    String? lookupErrorMessage,
    RecentLookupsStatus? recentStatus,
    List<Lookup>? recentLookups,
    String? recentErrorMessage,
  }) {
    return VendorState(
      lookupStatus: lookupStatus ?? this.lookupStatus,
      result: result ?? this.result,
      lookupErrorMessage: lookupErrorMessage ?? this.lookupErrorMessage,
      recentStatus: recentStatus ?? this.recentStatus,
      recentLookups: recentLookups ?? this.recentLookups,
      recentErrorMessage: recentErrorMessage ?? this.recentErrorMessage,
    );
  }

  @override
  List<Object?> get props => [
    lookupStatus,
    result,
    lookupErrorMessage,
    recentStatus,
    recentLookups,
    recentErrorMessage,
  ];
}
