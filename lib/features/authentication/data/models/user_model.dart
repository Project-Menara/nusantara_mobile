import 'package:nusantara_mobile/features/authentication/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required id,
    required String name,
    required String fullName, // Hanya gunakan fullName
    required String email,
    required String phoneNumber,
    String? gender,
    required String token,
  }) : super(
         id: id,
         name: name,
         fullName: fullName,
         email: email,
         phoneNumber: phoneNumber,
         gender: gender,
         token: token,
       );
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      fullName: json['full_name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      gender: json['gender'],
      token: json['token'], // Asumsi token ada di dalam data user
    );
  }
}
