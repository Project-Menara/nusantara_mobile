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
    super.isClaimed = false,
    required super.createdAt,
    required super.updatedAt,
    required super.createdBy,
  });

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    print("🔍 Parsing voucher JSON: $json");

    try {
      return VoucherModel(
        id: json['id']?.toString() ?? '',
        code: json['code']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        pointCost: _parseToInt(json['point_cost'], 'point_cost'),
        startDate: _parseDateTime(json['start_date'], 'start_date'),
        endDate: _parseDateTime(json['end_date'], 'end_date'),
        quota: _parseToInt(json['quota'], 'quota'),
        discountAmount: _parseToInt(json['discount_amount'], 'discount_amount'),
        discountPercent: _parseToInt(
          json['discount_percent'],
          'discount_percent',
        ),
        minimumSpend: _parseToInt(json['minimum_spend'], 'minimum_spend'),
        discountType: json['discount_type']?.toString() ?? '',
        isClaimed: json['is_claimed'] == true || json['is_claimed'] == 'true',
        createdAt: _parseDateTime(json['created_at'], 'created_at'),
        updatedAt: _parseDateTime(json['updated_at'], 'updated_at'),
        createdBy: json['created_by'] != null
            ? CreatedByModel.fromJson(json['created_by'])
            : null,
      );
    } catch (e) {
      print("❌ Error parsing voucher: $e");
      print("📄 JSON that failed: $json");
      rethrow;
    }
  }

  static int _parseToInt(dynamic value, String fieldName) {
    if (value == null) {
      print("⚠️ Field '$fieldName' is null, using default 0");
      return 0;
    }
    if (value is int) return value;
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }
    print(
      "⚠️ Field '$fieldName' has unexpected type: ${value.runtimeType}, value: $value, using default 0",
    );
    return 0;
  }

  static DateTime _parseDateTime(dynamic value, String fieldName) {
    if (value == null) {
      print("⚠️ Field '$fieldName' is null, using current time");
      return DateTime.now();
    }
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        print("❌ Failed to parse '$fieldName' datetime: $value, error: $e");
        return DateTime.now();
      }
    }
    print(
      "⚠️ Field '$fieldName' has unexpected type: ${value.runtimeType}, value: $value",
    );
    return DateTime.now();
  }
}
