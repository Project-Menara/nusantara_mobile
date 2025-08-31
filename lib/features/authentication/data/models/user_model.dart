// lib/features/authentication/data/models/user_model.dart

import 'package:intl/intl.dart';
import 'package:nusantara_mobile/features/authentication/data/models/role_model.dart';
import 'package:nusantara_mobile/features/authentication/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.username,
    required super.email,
    required super.phone,
    required super.gender,
    super.dateOfBirth,
    super.photo,
    required super.role,
    required super.status,
    super.token,
    required super.deletedAt,
  });

  // <<< PERBAIKAN: Tambahkan factory constructor ini >>>
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      username: entity.username,
      email: entity.email,
      phone: entity.phone,
      gender: entity.gender,
      dateOfBirth: entity.dateOfBirth,
      photo: entity.photo,
      role: entity.role,
      status: entity.status,
      token: entity.token,
      deletedAt:
          entity.deletedAt ?? DateTime.now(), // Gunakan default value jika null
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json, {String? token}) {
    return UserModel(
      id: (json['id'] ?? json['ID'])?.toString() ?? '',
      name: (json['name'] ?? json['Name'])?.toString() ?? '',
      username: (json['username'] ?? json['Username'])?.toString() ?? '',
      email: (json['email'] ?? json['Email'])?.toString() ?? '',
      phone: (json['phone'] ?? json['Phone'])?.toString() ?? '',
      gender: (json['gender'] ?? json['Gender'])?.toString() ?? '',
      dateOfBirth: (json['date_of_birth'] ?? json['DateOfBirth']) != null
          ? DateTime.tryParse(
              (json['date_of_birth'] ?? json['DateOfBirth']).toString(),
            )
          : null,
      photo: (json['photo'] ?? json['Photo'])?.toString(),
      role: RoleModel.fromJson((json['role'] ?? json['Role']) ?? {}),
      status: ((json['status'] ?? json['Status']) as num?)?.toInt() ?? 0,
      token: token,
      deletedAt: (json['deleted_at'] ?? json['DeletedAt']) != null
          ? DateTime.parse((json['deleted_at'] ?? json['DeletedAt']).toString())
          : DateTime.now(), // Gunakan default value jika null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'phone': phone,
      'gender': gender,
      'date_of_birth': dateOfBirth != null
          ? DateFormat('yyyy-MM-dd').format(
              dateOfBirth!,
            ) // <-- FORMAT SESUAI API
          : null,
      'photo': photo,
      'status': status,
    };
  }
}
