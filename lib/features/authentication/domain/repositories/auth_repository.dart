import 'package:dartz/dartz.dart';
import 'package:nusantara_mobile/core/error/failures.dart';
import 'package:nusantara_mobile/features/authentication/domain/entities/phone_check_entity.dart';
import 'package:nusantara_mobile/features/authentication/domain/entities/user_entity.dart';

// Kontrak/Blueprint untuk repository otentikasi
abstract class AuthRepository {
  /// Method untuk mengecek nomor telepon saat pertama kali login.
  Future<Either<Failures, PhoneCheckEntity>> checkPhone(String phoneNumber);

  /// Method untuk verifikasi kode OTP.
  Future<Either<Failures, Unit>> verifyCode({
    required String phoneNumber,
    required String code,
  });

  /// Method untuk mendaftarkan pengguna baru.
  Future<Either<Failures, Unit>> register({
    required String name,
    required String username,
    required String email,
    required String phone,
    required String gender,
  });

  /// Method untuk membuat PIN baru.
  Future<Either<Failures, Unit>> createPin({
    required String phoneNumber,
    required String pin,
  });

  Future<Either<Failures, void>> confirmPin({
    required String phone,
    required String confirmPin,
  });

  /// Method untuk verifikasi PIN dan melakukan login.
  Future<Either<Failures, UserEntity>> verifyPinAndLogin({
    required String phoneNumber,
    required String pin,
  });

  /// Method untuk logout.
  Future<Either<Failures, Unit>> logout();
}
