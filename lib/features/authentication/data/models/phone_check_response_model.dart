import 'package:nusantara_mobile/features/authentication/data/models/user_model.dart';
import 'package:nusantara_mobile/features/authentication/domain/entities/phone_check_entity.dart';

class PhoneCheckResponseModel {
  final String action;
  final int ttl;
  final UserModel? user; // User bisa null jika action-nya 'register'

  const PhoneCheckResponseModel({
    required this.action,
    required this.ttl,
    this.user,
  });

  factory PhoneCheckResponseModel.fromJson(Map<String, dynamic> json) {
    return PhoneCheckResponseModel(
      action: json['action'],
      ttl: json['ttl'],
      // Cek jika ada data user, baru di-parse
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }

  // Fungsi ini mengubah Model (Data Layer) menjadi Entity (Domain Layer)
  PhoneCheckEntity toEntity() {
    return PhoneCheckEntity(
      action: action,
      ttl: ttl,
      // Ambil nomor telepon dari data user jika ada, jika tidak, string kosong
      phoneNumber: user?.phone ?? '',
      // isRegistered bisa kita tentukan dari ada atau tidaknya data user
      isRegistered: user != null,
    );
  }
}
