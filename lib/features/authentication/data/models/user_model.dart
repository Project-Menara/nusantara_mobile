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
    super.token, // Tambahkan token jika belum ada
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
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json, {String? token}) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      username: json['username'],
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      gender: json['gender'],
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'])
          : null,
      photo: json['photo'],
      role: RoleModel.fromJson(json['role']),
      status: json['status'] ?? 0,
      token: token,
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
