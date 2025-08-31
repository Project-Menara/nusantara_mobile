import 'package:equatable/equatable.dart';
import 'package:nusantara_mobile/features/voucher/domain/entities/voucher_entity.dart';
import 'package:nusantara_mobile/features/authentication/domain/entities/user_entity.dart';

class ClaimedVoucherEntity extends Equatable {
  final String id;
  final UserEntity user;
  final VoucherEntity voucher;
  final VoucherDetailEntity voucherDetail;
  final bool isUsed;
  final DateTime? redeemedAt;
  final DateTime claimedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ClaimedVoucherEntity({
    required this.id,
    required this.user,
    required this.voucher,
    required this.voucherDetail,
    required this.isUsed,
    this.redeemedAt,
    required this.claimedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    user,
    voucher,
    voucherDetail,
    isUsed,
    redeemedAt,
    claimedAt,
    createdAt,
    updatedAt,
  ];
}

class VoucherDetailEntity extends Equatable {
  final String id;
  final String voucherCode;
  final String discountType;
  final double discountAmount;
  final double discountPercent;
  final double minPurchaseAmount;
  final DateTime validFrom;
  final DateTime validUntil;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VoucherDetailEntity({
    required this.id,
    required this.voucherCode,
    required this.discountType,
    required this.discountAmount,
    required this.discountPercent,
    required this.minPurchaseAmount,
    required this.validFrom,
    required this.validUntil,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object> get props => [
    id,
    voucherCode,
    discountType,
    discountAmount,
    discountPercent,
    minPurchaseAmount,
    validFrom,
    validUntil,
    description,
    createdAt,
    updatedAt,
  ];
}
