import 'package:equatable/equatable.dart';
import 'package:nusantara_mobile/features/authentication/domain/entities/user_entity.dart';

class VoucherEntity extends Equatable {
  final String id;
  final String code;
  final int discountAmount;
  final int discountPercent;
  final int minimumSpend;
  final int pointCost;
  final DateTime startDate;
  final DateTime endDate;
  final int quota;
  final String description;
  final String discountType;
  final bool isClaimed;
  final UserEntity? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VoucherEntity({
    required this.id,
    required this.code,
    required this.discountAmount,
    required this.discountPercent,
    required this.minimumSpend,
    required this.pointCost,
    required this.startDate,
    required this.endDate,
    required this.quota,
    required this.description,
    required this.discountType,
    this.isClaimed = false, // Default to false
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    code,
    discountAmount,
    discountPercent,
    startDate,
    endDate,
    isClaimed,
  ];
}
