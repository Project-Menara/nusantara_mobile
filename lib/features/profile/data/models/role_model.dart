import 'package:nusantara_mobile/features/profile/domain/entities/role_entity.dart';

class RoleModel extends RoleEntity {
  const RoleModel({required super.id, required super.name});

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(id: json['id'], name: json['name']);
  }
}
