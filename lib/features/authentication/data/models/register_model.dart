import 'package:nusantara_mobile/features/authentication/domain/entities/register_entity.dart';

class RegisterModel extends RegisterEntity {
  const RegisterModel({
    required super.name,
    required super.username,
    required super.email,
    required super.phone,
    required super.gender,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "username": username,
      "email": email,
      "phone": phone,
      "gender": gender,
    };
  }

  factory RegisterModel.fromEntity(RegisterEntity data) {
    return RegisterModel(
      name: data.name,
      username: data.username,
      email: data.email,
      phone: data.phone,
      gender: data.gender,
    );
  }
}
