// lib/features/authentication/data/models/user_model.dart

import 'package:nusantara_mobile/features/profile/data/models/role_model.dart';
import 'package:nusantara_mobile/features/profile/domain/entities/user_entity.dart';

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
  });

  factory UserModel.fromJson(Map<String, dynamic> json, {String? token}) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      gender: json['gender'] ?? '',
      dateOfBirth: json['date_of_birth'],
      photo: json['photo'],
      role: RoleModel.fromJson(json['role']),
      status: json['status'] ?? 0,
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
      'date_of_birth': dateOfBirth,
      'photo': photo,
      'role': role,
      'status': status,
    };
  }
}
