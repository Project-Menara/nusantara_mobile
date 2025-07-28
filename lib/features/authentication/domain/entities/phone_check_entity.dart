// Di file phone_check_entity.dart
import 'package:equatable/equatable.dart';
import 'package:nusantara_mobile/features/authentication/domain/entities/user_entity.dart';

class PhoneCheckEntity extends Equatable {
  final String action;
  final UserEntity? user;

  const PhoneCheckEntity({required this.action, this.user});

  @override
  List<Object?> get props => [action, user];
}
