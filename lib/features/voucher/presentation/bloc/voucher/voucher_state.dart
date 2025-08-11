part of 'voucher_bloc.dart';

abstract class VoucherState extends Equatable {
  const VoucherState();

  @override
  List<Object?> get props => [];
}

class VoucherInitial extends VoucherState {}

// States for getting all vouchers
class VoucherAllLoading extends VoucherState {}

class VoucherAllLoaded extends VoucherState {
  final List<VoucherEntity> vouchers;

  const VoucherAllLoaded({required this.vouchers});

  @override
  List<Object?> get props => [vouchers];
}

class VoucherAllError extends VoucherState {
  final String message;
  const VoucherAllError(this.message);

  @override
  List<Object?> get props => [message];
}

// States for getting a single voucher by ID
class VoucherByIdLoading extends VoucherState {}

class VoucherByIdLoaded extends VoucherState {
  final VoucherEntity voucher;

  const VoucherByIdLoaded({required this.voucher});

  @override
  List<Object?> get props => [voucher];
}

class VoucherByIdError extends VoucherState {
  final String message;
  const VoucherByIdError(this.message);

  @override
  List<Object?> get props => [message];
}