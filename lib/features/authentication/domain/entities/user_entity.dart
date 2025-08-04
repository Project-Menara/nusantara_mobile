import 'package:equatable/equatable.dart';
import 'package:nusantara_mobile/features/authentication/domain/entities/role_entity.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String username;
  final String email;
  final String phone;
  final String gender;
  final DateTime? dateOfBirth;
  final String? photo;
  final RoleEntity role;
  final int status;
  final String? token;

  const UserEntity({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.gender,
    this.dateOfBirth,
    this.photo,
    required this.role,
    required this.status,
    this.token,
  });
 UserEntity copyWith({
    String? name,
    String? email,
    String? phone,
    String? gender,
    DateTime? dateOfBirth,
    String? photo,
  }) {
    return UserEntity(
      id: id,
      name: name ?? this.name,
      username: username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      photo: photo ?? this.photo,
      role: role,
      status: status,
      token: token,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    username,
    email,
    phone,
    gender,
    dateOfBirth,
    photo,
    role,
    status,
    token,
  ];
}
