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
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      email: json['email'],
      phone: json['phone'],
      gender: json['gender'],
      dateOfBirth: json['date_of_birth'],
      photo: json['photo'],
      role: RoleModel.fromJson(json['role']), // Parsing objek role
      status: json['status'],
      token: json['token'],
    );
  }
}
