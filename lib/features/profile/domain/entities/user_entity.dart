import 'package:equatable/equatable.dart';
import 'package:nusantara_mobile/features/profile/domain/entities/role_entity.dart';

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
  ];
}
