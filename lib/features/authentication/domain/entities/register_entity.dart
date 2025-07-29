import 'package:equatable/equatable.dart';

class RegisterEntity extends Equatable {
  final String name;
  final String username;
  final String email;
  final String phone;
  final String gender;
  const RegisterEntity({
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.gender,
  });
  @override
  List<Object?> get props => [name, username, email, phone, gender];
}
