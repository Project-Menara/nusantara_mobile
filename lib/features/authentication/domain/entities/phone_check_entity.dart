import 'package:equatable/equatable.dart';

class PhoneCheckEntity extends Equatable {
  final String action; // Berisi 'login' atau 'register'

  const PhoneCheckEntity({required this.action});

  @override
  List<Object?> get props => [action];
}