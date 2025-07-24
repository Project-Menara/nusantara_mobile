import 'package:equatable/equatable.dart';

class Register extends Equatable {
  final String email;
  final String password;
  final String name;

  const Register({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object?> get props => [email, password, name];
}
