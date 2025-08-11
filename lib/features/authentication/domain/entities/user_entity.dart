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
  final DateTime? deletedAt;

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
    this.deletedAt,
  });
  UserEntity copyWith({
    String? name,
    String? email,
    String? phone,
    String? gender,
    DateTime? dateOfBirth,
    String? photo,
    DateTime? deletedAt,
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
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  const UserEntity.empty()
    : id = '',
      name = '          ', // Spasi agar skeleton memiliki lebar
      username = '',
      email = '                    ',
      phone = '             ',
      photo = null,
      gender = 'Laki-laki',
      dateOfBirth = null,
      role = const RoleEntity.empty(),
      status = 0,
      token = null,
      deletedAt = null;

  UserEntity.fromJson(Map<String, dynamic> json)
    : id = json['id'] ?? '',
      name = json['name'] ?? '          ', // Spasi agar skeleton memiliki lebar
      username = json['username'] ?? '',
      email = json['email'] ?? '                    ',
      phone = json['phone'] ?? '             ',
      gender = json['gender'] ?? 'Laki-laki',
      dateOfBirth = json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'].toString())
          : null,
      photo = json['photo'],
      role = json['role'] != null
          ? RoleEntity.fromJson(json['role'])
          : const RoleEntity.empty(),
      status = json['status'] ?? 0,
      token = json['token'],
      deletedAt = json['deleted_at'] != null
          ? DateTime.tryParse(json['deleted_at'].toString())
          : null;

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
