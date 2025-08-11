// Lokasi: lib/features/voucher/domain/entities/user_entity.dart

import 'package:equatable/equatable.dart';
// Impor kedua entity (voucher dan authentication) untuk jembatan/mapper
import 'package:nusantara_mobile/features/authentication/domain/entities/role_entity.dart'
    as auth_role;
import 'package:nusantara_mobile/features/authentication/domain/entities/user_entity.dart'
    as auth_user;

// Entity lokal untuk role di dalam voucher
class RoleEntity extends Equatable {
  final String id;
  final String name;
  const RoleEntity({required this.id, required this.name});

  // Mapper untuk mengubah RoleEntity lokal menjadi RoleEntity authentication
  auth_role.RoleEntity toAuthRoleEntity() {
    return auth_role.RoleEntity(id: id, name: name);
  }

  @override
  List<Object?> get props => [id, name];
}

// Entity lokal untuk user di dalam voucher
class UserEntity extends Equatable {
  final String id;
  final String name;
  final String username;
  final String email;
  final RoleEntity role; // Menggunakan RoleEntity lokal

  // Jadikan properti ini nullable agar cocok dengan API
  final String? phone;
  final String? gender;
  final String? photo;
  final DateTime? dateOfBirth;
  final DateTime? deletedAt;
  final int? status;
  
  final dynamic createdBy;
  const UserEntity({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.role,
    this.phone,
    this.gender,
    this.photo,
    this.dateOfBirth,
    this.deletedAt,
    this.status,
    this.createdBy
  });


  // INI JEMBATANNYA (MAPPER METHOD)
  // Metode untuk mengubah UserEntity lokal menjadi UserEntity authentication
  auth_user.UserEntity toAuthUserEntity() {
    return auth_user.UserEntity(
      id: id,
      name: name,
      username: username,
      email: email,
      role: role.toAuthRoleEntity(), // Panggil mapper untuk role juga
      phone: phone ?? '',
      gender: gender ?? '',
      photo: photo ?? '',
      dateOfBirth: dateOfBirth ?? DateTime.now(),
      deletedAt: deletedAt ?? DateTime.now(),
      status: status ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, name, username, email, role, phone, gender, status];
}
