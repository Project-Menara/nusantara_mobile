import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nusantara_mobile/features/voucher/domain/usecases/get_all_voucher_usecase.dart';
import 'package:nusantara_mobile/features/voucher/domain/usecases/get_voucher_by_id_usecase.dart';
import 'package:nusantara_mobile/features/voucher/domain/usecases/claim_voucher_usecase.dart';
import 'package:nusantara_mobile/features/voucher/domain/usecases/get_claimed_vouchers_usecase.dart';

import 'package:equatable/equatable.dart';
import 'package:nusantara_mobile/core/error/map_failure_toMessage.dart';
import 'package:nusantara_mobile/core/usecase/usecase.dart';
import 'package:nusantara_mobile/features/voucher/domain/entities/voucher_entity.dart';
import 'package:nusantara_mobile/features/voucher/domain/entities/claimed_voucher_entity.dart';

part 'voucher_event.dart';
part 'voucher_state.dart';

class VoucherBloc extends Bloc<VoucherEvent, VoucherState> {
  final GetAllVoucherUsecase getAllVoucherUsecase;
  final GetVoucherByIdUsecase getVoucherByIdUsecase;
  final ClaimVoucherUsecase claimVoucherUsecase;
  final GetClaimedVouchersUsecase getClaimedVouchersUsecase;

  VoucherBloc({
    required this.getAllVoucherUsecase,
    required this.getVoucherByIdUsecase,
    required this.claimVoucherUsecase,
    required this.getClaimedVouchersUsecase,
  }) : super(VoucherInitial()) {
    // debug: VoucherBloc constructor called
    // debug: getAllVoucherUsecase: ${getAllVoucherUsecase.runtimeType}
    // debug: getVoucherByIdUsecase: ${getVoucherByIdUsecase.runtimeType}
    // debug: claimVoucherUsecase: ${claimVoucherUsecase.runtimeType}
    // debug: getClaimedVouchersUsecase: ${getClaimedVouchersUsecase.runtimeType}

    on<GetAllVoucherEvent>(_onGetAllVoucher);
    on<GetVoucherByIdEvent>(_onGetByIdVoucher);
    on<ClaimVoucherEvent>(_onClaimVoucher);
    on<GetClaimedVouchersEvent>(_onGetClaimedVouchers);

    // debug: VoucherBloc event handlers registered
  }

  Future<void> _onGetAllVoucher(
    GetAllVoucherEvent event,
    Emitter<VoucherState> emit,
  ) async {
    // debug: _onGetAllVoucher called
    // debug: Event received: ${event.runtimeType}
    // debug: Current state before processing: ${state.runtimeType}

    try {
      // debug: Emitting VoucherAllLoading state
      emit(VoucherAllLoading());

      // debug: Calling getAllVoucherUsecase
      final voucherOrFailure = await getAllVoucherUsecase(NoParams());

      await voucherOrFailure.fold(
        (failures) {
          // debug: Voucher fetch failed: $failures
          // debug: Failure type: ${failures.runtimeType}
          final errorMessage = MapFailureToMessage.map(failures);
          // debug: Mapped error message: $errorMessage
          emit(VoucherAllError(errorMessage));
        },
        (vouchers) async {
          // debug: Voucher fetch successful: ${vouchers.length} vouchers loaded

          // Fetch claimed vouchers to determine which vouchers are already claimed
          // debug: Fetching claimed vouchers to check claimed status
          final claimedVouchersOrFailure = await getClaimedVouchersUsecase(
            NoParams(),
          );

          claimedVouchersOrFailure.fold(
            (failure) {
              // debug: Failed to fetch claimed vouchers, proceeding with unclaimed status
              // If we can't fetch claimed vouchers, proceed with all vouchers as unclaimed
              emit(VoucherAllLoaded(vouchers: vouchers));
            },
            (claimedVouchers) {
              // debug: Claimed vouchers fetched: ${claimedVouchers.length} claimed

              // Create a set of claimed voucher IDs for fast lookup
              final claimedVoucherIds = claimedVouchers
                  .map((cv) => cv.voucher.id)
                  .toSet();
              // debug: Claimed voucher IDs: $claimedVoucherIds

              // Update vouchers with claimed status
              final updatedVouchers = vouchers.map((voucher) {
                final isClaimed = claimedVoucherIds.contains(voucher.id);
                // debug: Voucher ${voucher.code} (${voucher.id}) - isClaimed: $isClaimed

                // Create a new VoucherEntity with updated claimed status
                return VoucherEntity(
                  id: voucher.id,
                  code: voucher.code,
                  discountAmount: voucher.discountAmount,
                  discountPercent: voucher.discountPercent,
                  minimumSpend: voucher.minimumSpend,
                  pointCost: voucher.pointCost,
                  startDate: voucher.startDate,
                  endDate: voucher.endDate,
                  quota: voucher.quota,
                  description: voucher.description,
                  discountType: voucher.discountType,
                  isClaimed: isClaimed,
                  createdBy: voucher.createdBy,
                  createdAt: voucher.createdAt,
                  updatedAt: voucher.updatedAt,
                );
              }).toList();

              // debug: Updated ${updatedVouchers.length} vouchers with claimed status
              emit(VoucherAllLoaded(vouchers: updatedVouchers));
            },
          );
        },
      );
    } catch (e) {
      // debug: Exception in _onGetAllVoucher: $e
      // debug: Exception type: ${e.runtimeType}
      emit(VoucherAllError("Terjadi kesalahan yang tidak terduga: $e"));
    }

    // debug: _onGetAllVoucher completed
  }

  Future<void> _onGetByIdVoucher(
    GetVoucherByIdEvent event,
    Emitter<VoucherState> emit,
  ) async {
    // debug: 🔄 VoucherBloc: _onGetByIdVoucher called with ID: ${event.id}
    // debug: 🔄 VoucherBloc: Current state before processing: ${state.runtimeType}

    try {
      // debug: 🔄 VoucherBloc: Emitting VoucherByIdLoading state
      emit(VoucherByIdLoading());

      // debug: 🔄 VoucherBloc: Calling getVoucherByIdUsecase with ID: ${event.id}
      final voucherOrFailure = await getVoucherByIdUsecase(
        DetailParams(id: event.id),
      );

      // debug: 🔄 VoucherBloc: Use case completed, processing result
      await voucherOrFailure.fold(
        (failures) {
          // debug: ❌ VoucherBloc: Voucher by ID fetch failed: $failures
          // debug: ❌ VoucherBloc: Failure type: ${failures.runtimeType}
          final errorMessage = MapFailureToMessage.map(failures);
          // debug: ❌ VoucherBloc: Mapped error message: $errorMessage
          emit(VoucherByIdError(errorMessage));
        },
        (voucher) async {
          // debug: ✅ VoucherBloc: Voucher by ID fetch successful
          // debug: ✅ VoucherBloc: Voucher details: ${voucher.code} - ${voucher.description}

          // Fetch claimed vouchers to determine if this specific voucher is claimed
          // debug: 🔄 VoucherBloc: Checking if voucher ${voucher.id} is claimed
          final claimedVouchersOrFailure = await getClaimedVouchersUsecase(
            NoParams(),
          );

          claimedVouchersOrFailure.fold(
            (failure) {
              // debug: ⚠️ VoucherBloc: Failed to fetch claimed vouchers for detail, proceeding with unclaimed status
              emit(VoucherByIdLoaded(voucher: voucher));
            },
            (claimedVouchers) {
              // debug: ✅ VoucherBloc: Claimed vouchers fetched for detail check

              // Check if this voucher is in the claimed list
              final isClaimed = claimedVouchers.any(
                (cv) => cv.voucher.id == voucher.id,
              );
              // debug: 🔍 VoucherBloc: Voucher ${voucher.code} (${voucher.id}) - isClaimed: $isClaimed

              // Create updated voucher with claimed status
              final updatedVoucher = VoucherEntity(
                id: voucher.id,
                code: voucher.code,
                discountAmount: voucher.discountAmount,
                discountPercent: voucher.discountPercent,
                minimumSpend: voucher.minimumSpend,
                pointCost: voucher.pointCost,
                startDate: voucher.startDate,
                endDate: voucher.endDate,
                quota: voucher.quota,
                description: voucher.description,
                discountType: voucher.discountType,
                isClaimed: isClaimed,
                createdBy: voucher.createdBy,
                createdAt: voucher.createdAt,
                updatedAt: voucher.updatedAt,
              );

              emit(VoucherByIdLoaded(voucher: updatedVoucher));
            },
          );
        },
      );
    } catch (e) {
      // debug: 💥 VoucherBloc: Exception in _onGetByIdVoucher: $e
      // debug: 💥 VoucherBloc: Exception type: ${e.runtimeType}
      emit(VoucherByIdError("Terjadi kesalahan yang tidak terduga: $e"));
    }

    // debug: 🔄 VoucherBloc: _onGetByIdVoucher completed
  }

  Future<void> _onClaimVoucher(
    ClaimVoucherEvent event,
    Emitter<VoucherState> emit,
  ) async {
    // debug: 🎯 VoucherBloc: _onClaimVoucher called with voucher ID: ${event.voucherId}
    // debug: 🎯 VoucherBloc: Current state before processing: ${state.runtimeType}

    try {
      // debug: 🎯 VoucherBloc: Emitting VoucherClaimLoading state
      emit(VoucherClaimLoading());

      // debug: 🎯 VoucherBloc: Calling claimVoucherUsecase with voucher ID: ${event.voucherId}
      final claimOrFailure = await claimVoucherUsecase(event.voucherId);

      // debug: 🎯 VoucherBloc: Use case completed, processing result
      claimOrFailure.fold(
        (failures) {
          // debug: ❌ VoucherBloc: Voucher claim failed: $failures
          // debug: ❌ VoucherBloc: Failure type: ${failures.runtimeType}
          final errorMessage = MapFailureToMessage.map(failures);
          // debug: ❌ VoucherBloc: Mapped error message: $errorMessage
          emit(VoucherClaimError(errorMessage));
        },
        (claimedVoucher) {
          // debug: ✅ VoucherBloc: Voucher claim successful
          // debug: ✅ VoucherBloc: Claimed voucher ID: ${claimedVoucher.id}
          emit(VoucherClaimSuccess(claimedVoucher: claimedVoucher));
        },
      );
    } catch (e) {
      // debug: 💥 VoucherBloc: Exception in _onClaimVoucher: $e
      // debug: 💥 VoucherBloc: Exception type: ${e.runtimeType}
      emit(VoucherClaimError("Terjadi kesalahan yang tidak terduga: $e"));
    }

    // debug: 🎯 VoucherBloc: _onClaimVoucher completed
  }

  Future<void> _onGetClaimedVouchers(
    GetClaimedVouchersEvent event,
    Emitter<VoucherState> emit,
  ) async {
    // debug: 🎟️ VoucherBloc: _onGetClaimedVouchers called
    // debug: 🎟️ VoucherBloc: Current state before processing: ${state.runtimeType}

    try {
      // debug: 🎟️ VoucherBloc: Emitting ClaimedVouchersLoading state
      emit(ClaimedVouchersLoading());

      // debug: 🎟️ VoucherBloc: Calling getClaimedVouchersUsecase
      final claimedVouchersOrFailure = await getClaimedVouchersUsecase(
        NoParams(),
      );

      // debug: 🎟️ VoucherBloc: Use case completed, processing result
      claimedVouchersOrFailure.fold(
        (failures) {
          // debug: ❌ VoucherBloc: Claimed vouchers fetch failed: $failures
          // debug: ❌ VoucherBloc: Failure type: ${failures.runtimeType}
          final errorMessage = MapFailureToMessage.map(failures);
          // debug: ❌ VoucherBloc: Mapped error message: $errorMessage
          emit(ClaimedVouchersError(errorMessage));
        },
        (claimedVouchers) {
          // debug: ✅ VoucherBloc: Claimed vouchers fetch successful: ${claimedVouchers.length} vouchers loaded
          // debug: for (int i = 0; i < claimedVouchers.length; i++) {
          // debug:   // debug: ✅ VoucherBloc: Claimed voucher $i: ${claimedVouchers[i].id}
          // debug: }
          emit(ClaimedVouchersLoaded(claimedVouchers: claimedVouchers));
        },
      );
    } catch (e) {
      // debug: 💥 VoucherBloc: Exception in _onGetClaimedVouchers: $e
      // debug: 💥 VoucherBloc: Exception type: ${e.runtimeType}
      emit(ClaimedVouchersError("Terjadi kesalahan yang tidak terduga: $e"));
    }

    // debug: 🎟️ VoucherBloc: _onGetClaimedVouchers completed
  }
}
