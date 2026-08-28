part of 'vendor_bloc.dart';

sealed class VendorEvent extends Equatable {
  const VendorEvent();

  @override
  List<Object?> get props => [];
}

final class VendorLookupRequested extends VendorEvent {
  const VendorLookupRequested(this.ip);

  final String ip;

  @override
  List<Object?> get props => [ip];
}

final class VendorRecentLookupsRequested extends VendorEvent {
  const VendorRecentLookupsRequested();
}

final class VendorLocalIpDetectionRequested extends VendorEvent {
  const VendorLocalIpDetectionRequested();
}
