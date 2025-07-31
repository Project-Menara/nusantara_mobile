import 'package:equatable/equatable.dart';

class PhoneCheckEntity extends Equatable {
  final String action;
  final String phoneNumber;
  final int ttl;
  final bool isRegistered;

  const PhoneCheckEntity({
    required this.action,
    required this.phoneNumber,
    required this.ttl,
    required this.isRegistered,
  });

  @override
  List<Object?> get props => [action, phoneNumber, ttl, isRegistered];
}