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
    print("🎫 VoucherBloc: Constructor called");
    print(
      "🎫 VoucherBloc: getAllVoucherUsecase: ${getAllVoucherUsecase.runtimeType}",
    );
    print(
      "🎫 VoucherBloc: getVoucherByIdUsecase: ${getVoucherByIdUsecase.runtimeType}",
    );
    print(
      "🎫 VoucherBloc: claimVoucherUsecase: ${claimVoucherUsecase.runtimeType}",
    );
    print(
      "🎫 VoucherBloc: getClaimedVouchersUsecase: ${getClaimedVouchersUsecase.runtimeType}",
    );

    on<GetAllVoucherEvent>(_onGetAllVoucher);
    on<GetVoucherByIdEvent>(_onGetByIdVoucher);
    on<ClaimVoucherEvent>(_onClaimVoucher);
    on<GetClaimedVouchersEvent>(_onGetClaimedVouchers);

    print("🎫 VoucherBloc: Event handlers registered");
  }

  Future<void> _onGetAllVoucher(
    GetAllVoucherEvent event,
    Emitter<VoucherState> emit,
  ) async {
    print("🔄 VoucherBloc: _onGetAllVoucher called");
    print("🔄 VoucherBloc: Event received: ${event.runtimeType}");
    print(
      "🔄 VoucherBloc: Current state before processing: ${state.runtimeType}",
    );

    try {
      print("🔄 VoucherBloc: Emitting VoucherAllLoading state");
      emit(VoucherAllLoading());

      print("🔄 VoucherBloc: Calling getAllVoucherUsecase");
      final voucherOrFailure = await getAllVoucherUsecase(NoParams());

      await voucherOrFailure.fold(
        (failures) {
          print("❌ VoucherBloc: Voucher fetch failed: $failures");
          print("❌ VoucherBloc: Failure type: ${failures.runtimeType}");
          final errorMessage = MapFailureToMessage.map(failures);
          print("❌ VoucherBloc: Mapped error message: $errorMessage");
          emit(VoucherAllError(errorMessage));
        },
        (vouchers) async {
          print(
            "✅ VoucherBloc: Voucher fetch successful: ${vouchers.length} vouchers loaded",
          );

          // Fetch claimed vouchers to determine which vouchers are already claimed
          print(
            "🔄 VoucherBloc: Fetching claimed vouchers to check claimed status",
          );
          final claimedVouchersOrFailure = await getClaimedVouchersUsecase(
            NoParams(),
          );

          claimedVouchersOrFailure.fold(
            (failure) {
              print(
                "⚠️ VoucherBloc: Failed to fetch claimed vouchers, proceeding with unclaimed status",
              );
              // If we can't fetch claimed vouchers, proceed with all vouchers as unclaimed
              emit(VoucherAllLoaded(vouchers: vouchers));
            },
            (claimedVouchers) {
              print(
                "✅ VoucherBloc: Claimed vouchers fetched: ${claimedVouchers.length} claimed",
              );

              // Create a set of claimed voucher IDs for fast lookup
              final claimedVoucherIds = claimedVouchers
                  .map((cv) => cv.voucher.id)
                  .toSet();
              print("🔍 VoucherBloc: Claimed voucher IDs: $claimedVoucherIds");

              // Update vouchers with claimed status
              final updatedVouchers = vouchers.map((voucher) {
                final isClaimed = claimedVoucherIds.contains(voucher.id);
                print(
                  "🎫 VoucherBloc: Voucher ${voucher.code} (${voucher.id}) - isClaimed: $isClaimed",
                );

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

              print(
                "✅ VoucherBloc: Updated ${updatedVouchers.length} vouchers with claimed status",
              );
              emit(VoucherAllLoaded(vouchers: updatedVouchers));
            },
          );
        },
      );
    } catch (e) {
      print("💥 VoucherBloc: Exception in _onGetAllVoucher: $e");
      print("💥 VoucherBloc: Exception type: ${e.runtimeType}");
      emit(VoucherAllError("Terjadi kesalahan yang tidak terduga: $e"));
    }

    print("🔄 VoucherBloc: _onGetAllVoucher completed");
  }

  Future<void> _onGetByIdVoucher(
    GetVoucherByIdEvent event,
    Emitter<VoucherState> emit,
  ) async {
    print("🔄 VoucherBloc: _onGetByIdVoucher called with ID: ${event.id}");
    print(
      "🔄 VoucherBloc: Current state before processing: ${state.runtimeType}",
    );

    try {
      print("🔄 VoucherBloc: Emitting VoucherByIdLoading state");
      emit(VoucherByIdLoading());

      print(
        "🔄 VoucherBloc: Calling getVoucherByIdUsecase with ID: ${event.id}",
      );
      final voucherOrFailure = await getVoucherByIdUsecase(
        DetailParams(id: event.id),
      );

      print("🔄 VoucherBloc: Use case completed, processing result");
      await voucherOrFailure.fold(
        (failures) {
          print("❌ VoucherBloc: Voucher by ID fetch failed: $failures");
          print("❌ VoucherBloc: Failure type: ${failures.runtimeType}");
          final errorMessage = MapFailureToMessage.map(failures);
          print("❌ VoucherBloc: Mapped error message: $errorMessage");
          emit(VoucherByIdError(errorMessage));
        },
        (voucher) async {
          print("✅ VoucherBloc: Voucher by ID fetch successful");
          print(
            "✅ VoucherBloc: Voucher details: ${voucher.code} - ${voucher.description}",
          );

          // Fetch claimed vouchers to determine if this specific voucher is claimed
          print("🔄 VoucherBloc: Checking if voucher ${voucher.id} is claimed");
          final claimedVouchersOrFailure = await getClaimedVouchersUsecase(
            NoParams(),
          );

          claimedVouchersOrFailure.fold(
            (failure) {
              print(
                "⚠️ VoucherBloc: Failed to fetch claimed vouchers for detail, proceeding with unclaimed status",
              );
              emit(VoucherByIdLoaded(voucher: voucher));
            },
            (claimedVouchers) {
              print("✅ VoucherBloc: Claimed vouchers fetched for detail check");

              // Check if this voucher is in the claimed list
              final isClaimed = claimedVouchers.any(
                (cv) => cv.voucher.id == voucher.id,
              );
              print(
                "🔍 VoucherBloc: Voucher ${voucher.code} (${voucher.id}) - isClaimed: $isClaimed",
              );

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
      print("💥 VoucherBloc: Exception in _onGetByIdVoucher: $e");
      print("💥 VoucherBloc: Exception type: ${e.runtimeType}");
      emit(VoucherByIdError("Terjadi kesalahan yang tidak terduga: $e"));
    }

    print("🔄 VoucherBloc: _onGetByIdVoucher completed");
  }

  Future<void> _onClaimVoucher(
    ClaimVoucherEvent event,
    Emitter<VoucherState> emit,
  ) async {
    print(
      "🎯 VoucherBloc: _onClaimVoucher called with voucher ID: ${event.voucherId}",
    );
    print(
      "🎯 VoucherBloc: Current state before processing: ${state.runtimeType}",
    );

    try {
      print("🎯 VoucherBloc: Emitting VoucherClaimLoading state");
      emit(VoucherClaimLoading());

      print(
        "🎯 VoucherBloc: Calling claimVoucherUsecase with voucher ID: ${event.voucherId}",
      );
      final claimOrFailure = await claimVoucherUsecase(event.voucherId);

      print("🎯 VoucherBloc: Use case completed, processing result");
      claimOrFailure.fold(
        (failures) {
          print("❌ VoucherBloc: Voucher claim failed: $failures");
          print("❌ VoucherBloc: Failure type: ${failures.runtimeType}");
          final errorMessage = MapFailureToMessage.map(failures);
          print("❌ VoucherBloc: Mapped error message: $errorMessage");
          emit(VoucherClaimError(errorMessage));
        },
        (claimedVoucher) {
          print("✅ VoucherBloc: Voucher claim successful");
          print("✅ VoucherBloc: Claimed voucher ID: ${claimedVoucher.id}");
          emit(VoucherClaimSuccess(claimedVoucher: claimedVoucher));
        },
      );
    } catch (e) {
      print("💥 VoucherBloc: Exception in _onClaimVoucher: $e");
      print("💥 VoucherBloc: Exception type: ${e.runtimeType}");
      emit(VoucherClaimError("Terjadi kesalahan yang tidak terduga: $e"));
    }

    print("🎯 VoucherBloc: _onClaimVoucher completed");
  }

  Future<void> _onGetClaimedVouchers(
    GetClaimedVouchersEvent event,
    Emitter<VoucherState> emit,
  ) async {
    print("🎟️ VoucherBloc: _onGetClaimedVouchers called");
    print(
      "🎟️ VoucherBloc: Current state before processing: ${state.runtimeType}",
    );

    try {
      print("🎟️ VoucherBloc: Emitting ClaimedVouchersLoading state");
      emit(ClaimedVouchersLoading());

      print("🎟️ VoucherBloc: Calling getClaimedVouchersUsecase");
      final claimedVouchersOrFailure = await getClaimedVouchersUsecase(
        NoParams(),
      );

      print("🎟️ VoucherBloc: Use case completed, processing result");
      claimedVouchersOrFailure.fold(
        (failures) {
          print("❌ VoucherBloc: Claimed vouchers fetch failed: $failures");
          print("❌ VoucherBloc: Failure type: ${failures.runtimeType}");
          final errorMessage = MapFailureToMessage.map(failures);
          print("❌ VoucherBloc: Mapped error message: $errorMessage");
          emit(ClaimedVouchersError(errorMessage));
        },
        (claimedVouchers) {
          print(
            "✅ VoucherBloc: Claimed vouchers fetch successful: ${claimedVouchers.length} vouchers loaded",
          );
          for (int i = 0; i < claimedVouchers.length; i++) {
            print(
              "✅ VoucherBloc: Claimed voucher $i: ${claimedVouchers[i].id}",
            );
          }
          emit(ClaimedVouchersLoaded(claimedVouchers: claimedVouchers));
        },
      );
    } catch (e) {
      print("💥 VoucherBloc: Exception in _onGetClaimedVouchers: $e");
      print("💥 VoucherBloc: Exception type: ${e.runtimeType}");
      emit(ClaimedVouchersError("Terjadi kesalahan yang tidak terduga: $e"));
    }

    print("🎟️ VoucherBloc: _onGetClaimedVouchers completed");
  }
}
