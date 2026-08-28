import 'package:arp_resolver/arp_resolver.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vendor_api_client/vendor_api_client.dart';
import 'package:vendor_lookup_repository/vendor_lookup_repository.dart';

part 'vendor_event.dart';
part 'vendor_state.dart';

class VendorBloc extends Bloc<VendorEvent, VendorState> {
  VendorBloc({
    required this._vendorLookupRepository,
    required this._localNetworkInfo,
  }) : super(const VendorState()) {
    on<VendorLookupRequested>(_onLookupRequested);
    on<VendorRecentLookupsRequested>(_onRecentLookupsRequested);
    on<VendorLocalIpDetectionRequested>(_onLocalIpDetectionRequested);
  }

  final VendorLookupRepository _vendorLookupRepository;
  final LocalNetworkInfo _localNetworkInfo;

  Future<void> _onLookupRequested(
    VendorLookupRequested event,
    Emitter<VendorState> emit,
  ) async {
    emit(state.copyWith(lookupStatus: VendorLookupStatus.loading));
    try {
      final result = await _vendorLookupRepository.lookupByIp(event.ip);
      if (isClosed) return;
      emit(
        state.copyWith(
          lookupStatus: VendorLookupStatus.success,
          result: result,
        ),
      );
      add(const VendorRecentLookupsRequested());
    } on VendorLookupRepositoryException catch (e) {
      if (isClosed) return;
      addError(e);
      emit(
        state.copyWith(
          lookupStatus: VendorLookupStatus.error,
          lookupErrorMessage: e.message,
          lookupErrorKind: _classifyLookupError(e),
        ),
      );
    }
  }

  VendorLookupErrorKind _classifyLookupError(
    VendorLookupRepositoryException exception,
  ) {
    final cause = switch (exception) {
      ArpLookupFailure(:final cause) => cause,
      VendorApiLookupFailure(:final cause) => cause,
    };

    return switch (cause) {
      ArpCommandFailure() => VendorLookupErrorKind.arpCommandFailed,
      ArpParseFailure() => VendorLookupErrorKind.arpOutputUnparseable,
      NetworkFailure() => VendorLookupErrorKind.networkUnreachable,
      UpstreamUnavailableFailure() => VendorLookupErrorKind.upstreamUnavailable,
      UpstreamLookupFailure() => VendorLookupErrorKind.upstreamBadResponse,
      RateLimitedFailure() => VendorLookupErrorKind.rateLimited,
      InvalidMacFailure() => VendorLookupErrorKind.invalidMac,
      UnexpectedResponseFailure() => VendorLookupErrorKind.unexpectedResponse,
      _ => VendorLookupErrorKind.unknown,
    };
  }

  Future<void> _onRecentLookupsRequested(
    VendorRecentLookupsRequested event,
    Emitter<VendorState> emit,
  ) async {
    emit(state.copyWith(recentStatus: RecentLookupsStatus.loading));
    try {
      final lookups = await _vendorLookupRepository.recentLookups();
      if (isClosed) return;
      emit(
        state.copyWith(
          recentStatus: RecentLookupsStatus.success,
          recentLookups: lookups,
        ),
      );
    } on VendorLookupRepositoryException catch (e) {
      if (isClosed) return;
      addError(e);
      emit(
        state.copyWith(
          recentStatus: RecentLookupsStatus.error,
          recentErrorMessage: e.message,
        ),
      );
    }
  }

  Future<void> _onLocalIpDetectionRequested(
    VendorLocalIpDetectionRequested event,
    Emitter<VendorState> emit,
  ) async {
    emit(
      state.copyWith(localIpDetectionStatus: LocalIpDetectionStatus.loading),
    );
    try {
      final ip = await _localNetworkInfo.primaryIPv4Address();
      if (isClosed) return;
      if (ip == null) {
        emit(
          state.copyWith(
            localIpDetectionStatus: LocalIpDetectionStatus.error,
            localIpDetectionErrorMessage: 'no active network interface found',
          ),
        );
        return;
      }
      emit(
        state.copyWith(
          localIpDetectionStatus: LocalIpDetectionStatus.success,
          detectedLocalIp: ip,
        ),
      );
    } on LocalNetworkInfoException catch (e) {
      if (isClosed) return;
      addError(e);
      emit(
        state.copyWith(
          localIpDetectionStatus: LocalIpDetectionStatus.error,
          localIpDetectionErrorMessage: e.message,
        ),
      );
    }
  }
}
