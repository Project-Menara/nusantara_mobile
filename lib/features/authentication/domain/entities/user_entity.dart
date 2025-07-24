import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final int id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? gender; // Bisa null jika tidak wajib
  final String token; // Token untuk otentikasi sesi

  const UserEntity({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.gender,
    required this.token, required String name,
  });

  @override
  List<Object?> get props => [id, fullName, email, phoneNumber, gender, token];
}