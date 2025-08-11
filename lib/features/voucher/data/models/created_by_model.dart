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
    return CreatedByModel(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      email: json['email'],
      phone: json['phone'] ?? '',
      gender: json['gender'] ?? '',
      status: json['status'] ?? 1,
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'])
          : null,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'])
          : null,
      photo: json['photo'],
      role: RoleModel.fromJson(json['role']),
      token: json['token'],
    );
  }
}
