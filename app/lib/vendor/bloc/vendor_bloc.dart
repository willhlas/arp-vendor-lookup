import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vendor_api_client/vendor_api_client.dart';
import 'package:vendor_lookup_repository/vendor_lookup_repository.dart';

part 'vendor_event.dart';
part 'vendor_state.dart';

class VendorBloc extends Bloc<VendorEvent, VendorState> {
  VendorBloc({required this._vendorLookupRepository})
    : super(const VendorState()) {
    on<VendorLookupRequested>(_onLookupRequested);
    on<VendorRecentLookupsRequested>(_onRecentLookupsRequested);
    add(const VendorRecentLookupsRequested());
  }

  final VendorLookupRepository _vendorLookupRepository;

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
        ),
      );
    }
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
}
