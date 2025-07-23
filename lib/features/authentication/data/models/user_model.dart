import 'package:nusantara_mobile/features/authentication/domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required String id,
    required String name,
    required String email,
    required String phoneNumber,
    required String address,
  }) : super(
         id: id,
         name: name,
         email: email,
         phoneNumber: phoneNumber,
         address: address,
       );
}
