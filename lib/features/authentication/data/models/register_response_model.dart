import 'package:nusantara_mobile/features/authentication/data/models/user_model.dart';

class RegisterResponseModel {
  final int ttl;
  final UserModel user;

  const RegisterResponseModel({required this.ttl, required this.user});

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      ttl: json["ttl"],
      user: UserModel.fromJson(json["user"]),
    );
  }
}
