import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nusantara_mobile/features/voucher/domain/usecases/get_all_voucher_usecase.dart';
import 'package:nusantara_mobile/features/voucher/domain/usecases/get_voucher_by_id_usecase.dart';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:nusantara_mobile/core/error/map_failure_toMessage.dart';
import 'package:nusantara_mobile/core/usecase/usecase.dart';
import 'package:nusantara_mobile/features/voucher/domain/entities/voucher_entity.dart';

part 'voucher_event.dart';
part 'voucher_state.dart';

class VoucherBloc extends Bloc<VoucherEvent, VoucherState> {
  final GetAllVoucherUsecase getAllVoucherUsecase;
  final GetVoucherByIdUsecase getVoucherByIdUsecase;

  VoucherBloc({
    required this.getAllVoucherUsecase,
    required this.getVoucherByIdUsecase,
  }) : super(VoucherInitial()) {
    on<GetAllVoucherEvent>(_onGetAllVoucher);
    on<GetVoucherByIdEvent>(_onGetByIdVoucher);
  }

  Future<void> _onGetAllVoucher(
    GetAllVoucherEvent event,
    Emitter<VoucherState> emit,
  ) async {
    emit(VoucherAllLoading());
    final voucherOrFailure = await getAllVoucherUsecase(NoParams());
    voucherOrFailure.fold(
      (failures) => emit(VoucherAllError(MapFailureToMessage.map(failures))),
      (vouchers) => emit(VoucherAllLoaded(vouchers: vouchers)),
    );
  }

  Future<void> _onGetByIdVoucher(
    GetVoucherByIdEvent event,
    Emitter<VoucherState> emit,
  ) async {
    emit(VoucherByIdLoading());
    final voucherOrFailure = await getVoucherByIdUsecase(
      DetailParams(id: event.id),
    );
    voucherOrFailure.fold(
      (failures) => emit(VoucherByIdError(MapFailureToMessage.map(failures))),
      (voucher) => emit(VoucherByIdLoaded(voucher: voucher)),
    );
  }
}
