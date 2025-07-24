import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/features/authentication/domain/entities/phone_check_entity.dart';
import 'package:nusantara_mobile/features/authentication/domain/entities/user_entity.dart';

// Kontrak/Blueprint untuk repository otentikasi
abstract class AuthRepository {
  /// Method untuk mengecek nomor telepon saat pertama kali login.
  /// Mengembalikan [PhoneCheckEntity] yang berisi action ('login' atau 'register').
  Future<Either<Failures, PhoneCheckEntity>> checkPhone(String phoneNumber);

  /// Method untuk verifikasi PIN dan melakukan login.
  /// Mengembalikan [UserEntity] yang berisi data pengguna dan token jika berhasil.
  Future<Either<Failures, UserEntity>> verifyPinAndLogin({
    required String phoneNumber,
    required String pin,
  });

  /// Method untuk mendaftarkan pengguna baru.
  /// Mengembalikan [Unit] (mirip void) jika registrasi berhasil.
  Future<Either<Failures, Unit>> register({
    required String name,
    required String username,
    required String email,
    required String phone,
    required String gender,
  });

  /// Method untuk logout.
  Future<Either<Failures, Unit>> logout();
}