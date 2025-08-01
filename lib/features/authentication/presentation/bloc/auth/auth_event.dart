import 'package:equatable/equatable.dart';
import 'package:nusantara_mobile/features/authentication/data/models/register_response_model.dart';
import 'package:nusantara_mobile/features/authentication/domain/entities/register_entity.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

/// Event saat pengguna menekan tombol 'Lanjutkan' untuk mengecek nomor telepon.
class AuthCheckPhonePressed extends AuthEvent {
  final String phoneNumber;
  const AuthCheckPhonePressed(this.phoneNumber);
  @override
  List<Object> get props => [phoneNumber];
}

/// Event saat pengguna memasukkan PIN untuk login.
class AuthLoginWithPinSubmitted extends AuthEvent {
  final String phoneNumber;
  final String pin;

  const AuthLoginWithPinSubmitted({
    required this.phoneNumber,
    required this.pin,
  });

  @override
  List<Object> get props => [phoneNumber, pin];
}

class GetUserEvent extends AuthEvent {
  @override
  List<Object> get props => [];
}

/// Event saat pengguna menekan tombol 'Create Account' di halaman registrasi.
class AuthRegisterPressed extends AuthEvent {
  final RegisterEntity registerEntity;

  const AuthRegisterPressed(this.registerEntity);
  @override
  List<Object> get props => [registerEntity];
}

/// Event saat pengguna menekan tombol logout.
class AuthLogoutRequested extends AuthEvent {}

class AuthCheckStatusRequested extends AuthEvent {}

