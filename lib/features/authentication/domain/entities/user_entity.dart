// import 'package:equatable/equatable.dart';
// import 'package:nusantara_mobile/features/authentication/domain/entities/role_entity.dart';

// class UserEntity extends Equatable {
//   final String id;
//   final String name;
//   final String username;
//   final String email;
//   final String phone;
//   final String gender;
//   final String? dateOfBirth;
//   final String? photo;
//   final RoleEntity role;
//   final int status;
//   final String? token;

//   const UserEntity({
//     required this.id,
//     required this.name,
//     required this.username,
//     required this.email,
//     required this.phone,
//     required this.gender,
//     this.dateOfBirth,
//     this.photo,
//     required this.role,
//     required this.status,
//     this.token,
//   });

//   @override
//   List<Object?> get props => [
//         id,
//         name,
//         username,
//         email,
//         phone,
//         gender,
//         dateOfBirth,
//         photo,
//         role,
//         status,
//         token,
//       ];
// }
// lib/features/authentication/domain/entities/user_entity.dart

import 'package:equatable/equatable.dart';
import 'package:nusantara_mobile/features/authentication/domain/entities/role_entity.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String username;
  final String email;
  final String phone;
  final String gender;
  final String? dateOfBirth;
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
