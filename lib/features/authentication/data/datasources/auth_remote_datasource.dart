import 'package:nusantara_mobile/features/authentication/data/models/phone_check_response_model.dart';
import 'package:nusantara_mobile/features/authentication/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  // Method untuk langkah awal, cek nomor telepon
  Future<PhoneCheckResponseModel> checkPhone(String phoneNumber);

  // Method untuk verifikasi PIN, mengembalikan data user
  Future<UserModel> verifyPin({required String phoneNumber, required String pin});

  // Method register disesuaikan dengan JSON
  Future<void> register({
    required String name,
    required String username,
    required String email,
    required String phone,
    required String gender,
  });

  // Method logout
  Future<void> logout(String token);
}