import 'package:equatable/equatable.dart';

class PhoneCheckEntity extends Equatable {
  final String action; 

  const PhoneCheckEntity({required this.action});

  @override
  List<Object?> get props => [action];
}