import 'package:nusantara_mobile/features/authentication/domain/entities/user_entity.dart';
import 'package:nusantara_mobile/features/home/domain/entities/banner_entity.dart';

class BannerModel extends BannerEntity {
  const BannerModel({
    required super.id,
    required super.photo,
    required super.name,
    required super.description,
    required super.user,
    required super.createdAt,
    required super.updatedAt,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json["id"] as String,
      photo: json["photo"] as String,
      name: json["name"] as String,
      description: json["description"] as String,
      user: json["user"] != null
          ? UserEntity.fromJson(json["user"] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json["created_at"] as String),
      updatedAt: DateTime.parse(json["updated_at"] as String),
    );
  }

  // factory BannerModel.fromEntity(BannerEntity banner) {
  //   return BannerModel(
  //     id: banner.id,
  //     photo: banner.photo,
  //     name: banner.name,
  //     status: banner.status,
  //     createdAt: banner.createdAt,
  //     deletedAt: banner.deletedAt,
  //   );
  // }
}
