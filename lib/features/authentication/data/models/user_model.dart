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
    required super.status, // UserEntity mengharapkan 'int' di sini
    super.token,
  });

  factory UserModel.fromJson(
    Map<String, dynamic> json, {
    String? token,
  }) {
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

      // ✅ FIX: Hapus .toString() agar tipe data tetap int sesuai permintaan UserEntity
      status: json['status'] ?? 0,

      token: token,
    );
  }
}