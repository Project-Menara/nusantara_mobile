import 'package:nusantara_mobile/features/authentication/data/models/phone_check_response_model.dart';
import 'package:nusantara_mobile/features/authentication/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  // Method untuk langkah awal, cek nomor telepon
  Future<PhoneCheckResponseModel> checkPhone(String phoneNumber);

  // Method untuk verifikasi kode OTP
  Future<void> verifyCode({required String phoneNumber, required String code});

  // Method register
  Future<void> register({
    required String name,
    required String username,
    required String email,
    required String phone,
    required String gender,
  });

  // Method untuk membuat PIN baru
  Future<void> createPin({required String phoneNumber, required String pin});

  // Method untuk verifikasi PIN, mengembalikan data user
  Future<UserModel> verifyPin({required String phoneNumber, required String pin});

  // Method logout
  Future<void> logout(String token);
}