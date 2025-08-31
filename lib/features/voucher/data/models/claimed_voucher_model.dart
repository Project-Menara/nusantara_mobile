import 'package:nusantara_mobile/features/voucher/domain/entities/claimed_voucher_entity.dart';
import 'package:nusantara_mobile/features/voucher/data/models/voucher_model.dart';
import 'package:nusantara_mobile/features/authentication/data/models/user_model.dart';

class ClaimedVoucherModel extends ClaimedVoucherEntity {
  const ClaimedVoucherModel({
    required super.id,
    required super.user,
    required super.voucher,
    required super.voucherDetail,
    required super.isUsed,
    super.redeemedAt,
    required super.claimedAt,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ClaimedVoucherModel.fromJson(Map<String, dynamic> json) {
    print("🔄 ClaimedVoucherModel: Parsing JSON: $json");

    try {
      final id = json['id'] as String? ?? '';
      print("🆔 ClaimedVoucherModel: ID: $id");

      // Parse user
      final userJson = json['user'] as Map<String, dynamic>? ?? {};
      final user = UserModel.fromJson(userJson);
      print("👤 ClaimedVoucherModel: User parsed: ${user.name}");

      // Parse voucher
      final voucherJson = json['voucher'] as Map<String, dynamic>? ?? {};
      final voucher = VoucherModel.fromJson(voucherJson);
      print("🎫 ClaimedVoucherModel: Voucher parsed: ${voucher.code}");

      // Parse voucher detail
      final voucherDetailJson =
          json['voucher_detail'] as Map<String, dynamic>? ?? {};
      final voucherDetail = VoucherDetailModel.fromJson(voucherDetailJson);
      print(
        "📋 ClaimedVoucherModel: Voucher detail parsed: ${voucherDetail.voucherCode}",
      );

      // Parse boolean and dates
      final isUsed = json['is_used'] as bool? ?? false;

      final redeemedAtStr = json['redeemed_at'] as String?;
      final redeemedAt = redeemedAtStr != null
          ? DateTime.parse(redeemedAtStr)
          : null;

      final claimedAtStr = json['claimed_at'] as String? ?? '';
      final claimedAt = DateTime.parse(claimedAtStr);

      final createdAtStr = json['created_at'] as String? ?? '';
      final createdAt = DateTime.parse(createdAtStr);

      final updatedAtStr = json['updated_at'] as String? ?? '';
      final updatedAt = DateTime.parse(updatedAtStr);

      print("✅ ClaimedVoucherModel: Successfully parsed claimed voucher: $id");

      return ClaimedVoucherModel(
        id: id,
        user: user,
        voucher: voucher,
        voucherDetail: voucherDetail,
        isUsed: isUsed,
        redeemedAt: redeemedAt,
        claimedAt: claimedAt,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
    } catch (e) {
      print("❌ ClaimedVoucherModel: Error parsing JSON: $e");
      print("❌ ClaimedVoucherModel: JSON was: $json");
      rethrow;
    }
  }
}

class VoucherDetailModel extends VoucherDetailEntity {
  const VoucherDetailModel({
    required super.id,
    required super.voucherCode,
    required super.discountType,
    required super.discountAmount,
    required super.discountPercent,
    required super.minPurchaseAmount,
    required super.validFrom,
    required super.validUntil,
    required super.description,
    required super.createdAt,
    required super.updatedAt,
  });

  factory VoucherDetailModel.fromJson(Map<String, dynamic> json) {
    print("🔄 VoucherDetailModel: Parsing JSON: $json");

    try {
      final id = json['id'] as String? ?? '';
      final voucherCode = json['voucher_code'] as String? ?? '';
      final discountType = json['discount_type'] as String? ?? '';

      final discountAmount = _parseDouble(json['discount_amount']);
      final discountPercent = _parseDouble(json['discount_percent']);
      final minPurchaseAmount = _parseDouble(json['min_purchase_amount']);

      final validFromStr = json['valid_from'] as String? ?? '';
      final validFrom = DateTime.parse(validFromStr);

      final validUntilStr = json['valid_until'] as String? ?? '';
      final validUntil = DateTime.parse(validUntilStr);

      final description = json['description'] as String? ?? '';

      final createdAtStr = json['created_at'] as String? ?? '';
      final createdAt = DateTime.parse(createdAtStr);

      final updatedAtStr = json['updated_at'] as String? ?? '';
      final updatedAt = DateTime.parse(updatedAtStr);

      print(
        "✅ VoucherDetailModel: Successfully parsed voucher detail: $voucherCode",
      );

      return VoucherDetailModel(
        id: id,
        voucherCode: voucherCode,
        discountType: discountType,
        discountAmount: discountAmount,
        discountPercent: discountPercent,
        minPurchaseAmount: minPurchaseAmount,
        validFrom: validFrom,
        validUntil: validUntil,
        description: description,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
    } catch (e) {
      print("❌ VoucherDetailModel: Error parsing JSON: $e");
      print("❌ VoucherDetailModel: JSON was: $json");
      rethrow;
    }
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
