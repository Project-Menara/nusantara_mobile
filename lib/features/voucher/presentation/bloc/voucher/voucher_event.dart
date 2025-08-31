part of 'voucher_bloc.dart';

abstract class VoucherEvent extends Equatable {
  const VoucherEvent();

  @override
  List<Object?> get props => [];
}

/// Event untuk mengambil semua voucher yang tersedia.
class GetAllVoucherEvent extends VoucherEvent {}

/// Event untuk mengambil detail satu voucher berdasarkan ID.
class GetVoucherByIdEvent extends VoucherEvent {
  final String id;

  const GetVoucherByIdEvent(this.id);

  @override
  List<Object?> get props => [id];
}

/// Event untuk claim voucher berdasarkan ID voucher.
class ClaimVoucherEvent extends VoucherEvent {
  final String voucherId;

  const ClaimVoucherEvent(this.voucherId);

  @override
  List<Object?> get props => [voucherId];
}

/// Event untuk mengambil semua voucher yang sudah diklaim user.
class GetClaimedVouchersEvent extends VoucherEvent {}
