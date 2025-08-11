// Lokasi: lib/features/voucher/data/models/role_model.dart

// 1. Impor RoleEntity (sesuaikan path jika perlu)
import 'package:nusantara_mobile/features/authentication/domain/entities/role_entity.dart';

// 2. Tambahkan "extends RoleEntity"
class RoleModel extends RoleEntity {

  // 3. Gunakan 'super' untuk mengisi properti dari RoleEntity
  const RoleModel({
    required super.id,
    required super.name,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'],
      name: json['name'],
    );
  }
}