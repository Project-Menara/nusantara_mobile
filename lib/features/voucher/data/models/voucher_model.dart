import '../../domain/entities/voucher_entity.dart';
import 'created_by_model.dart';

class VoucherModel extends VoucherEntity {
  const VoucherModel({
    required super.id,
    required super.code,
    required super.description,
    required super.discountAmount,
    required super.discountPercent,
    required super.minimumSpend,
    required super.pointCost,
    required super.startDate,
    required super.endDate,
    required super.quota,
    required super.discountType,
    required super.createdAt,
    required super.updatedAt,
    required super.createdBy,
  });

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    return VoucherModel(
      id: json['id'],
      code: json['code'],
      description: json['description'],
      pointCost: json['point_cost'] as int,
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      quota: json['quota'] as int,
      discountAmount: json['discount_amount'] as int,
      discountPercent: json['discount_percent'] as int,
      minimumSpend: json['minimum_spend'] as int,
      discountType: json['discount_type'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),

      // 3. Pastikan `CreatedByModel` Anda juga sudah di-extend dari UserEntity yang benar.
      //    Casting `as UserEntity` sudah tidak diperlukan lagi.
      createdBy: json['created_by'] != null
          ? CreatedByModel.fromJson(json['created_by'])
          : null,
    );
  }
}
