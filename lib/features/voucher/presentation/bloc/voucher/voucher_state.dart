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

// States for claiming a voucher
class VoucherClaimLoading extends VoucherState {}

class VoucherClaimSuccess extends VoucherState {
  final ClaimedVoucherEntity claimedVoucher;

  const VoucherClaimSuccess({required this.claimedVoucher});

  @override
  List<Object?> get props => [claimedVoucher];
}

class VoucherClaimError extends VoucherState {
  final String message;
  const VoucherClaimError(this.message);

  @override
  List<Object?> get props => [message];
}

// States for getting claimed vouchers
class ClaimedVouchersLoading extends VoucherState {}

class ClaimedVouchersLoaded extends VoucherState {
  final List<ClaimedVoucherEntity> claimedVouchers;

  const ClaimedVouchersLoaded({required this.claimedVouchers});

  @override
  List<Object?> get props => [claimedVouchers];
}

class ClaimedVouchersError extends VoucherState {
  final String message;
  const ClaimedVouchersError(this.message);

  @override
  List<Object?> get props => [message];
}
