// Lokasi: lib/features/voucher/data/models/created_by_model.dart

// 1. PERBAIKI IMPOR: Arahkan ke UserEntity yang benar di folder 'authentication'
import 'package:nusantara_mobile/features/authentication/domain/entities/user_entity.dart';
import 'package:nusantara_mobile/features/voucher/data/models/role_model.dart';

class CreatedByModel extends UserEntity {
  const CreatedByModel({
    required super.id,
    required super.name,
    required super.username,
    required super.email,
    required super.phone,
    required super.gender,
    required super.role,
    required super.status,
    super.deletedAt,
    super.dateOfBirth,
    super.photo,
    super.token,
  });

  factory CreatedByModel.fromJson(Map<String, dynamic> json) {
    // debug: 👤 Parsing created_by JSON: $json

    try {
      return CreatedByModel(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        username: json['username']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        gender: json['gender']?.toString() ?? '',
        status: _parseToInt(json['status'], 'status', defaultValue: 1),
        deletedAt: json['deleted_at'] != null
            ? _parseDateTime(json['deleted_at'], 'deleted_at')
            : null,
        dateOfBirth: json['date_of_birth'] != null
            ? _parseDateTime(json['date_of_birth'], 'date_of_birth')
            : null,
        photo: json['photo']?.toString(),
        role: json['role'] != null
            ? RoleModel.fromJson(json['role'])
            : RoleModel.fromJson({'id': '', 'name': 'unknown'}), // Default role
        token: json['token']?.toString(),
      );
    } catch (e) {
      // debug: ❌ Error parsing created_by: $e
      // debug: 📄 JSON that failed: $json
      rethrow;
    }
  }

  static int _parseToInt(
    dynamic value,
    String fieldName, {
    int defaultValue = 0,
  }) {
    if (value == null) {
      // debug: ⚠️ Field '$fieldName' is null, using default $defaultValue
      return defaultValue;
    }
    if (value is int) return value;
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }
    // debug: ⚠️ Field '$fieldName' has unexpected type: ${value.runtimeType}, value: $value, using default $defaultValue
    return defaultValue;
  }

  static DateTime? _parseDateTime(dynamic value, String fieldName) {
    if (value == null) return null;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        // debug: ❌ Failed to parse '$fieldName' datetime: $value, error: $e
        return null;
      }
    }
    // debug: ⚠️ Field '$fieldName' has unexpected type: ${value.runtimeType}, value: $value
    return null;
  }
}
