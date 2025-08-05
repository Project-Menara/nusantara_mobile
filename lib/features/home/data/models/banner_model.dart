import 'package:nusantara_mobile/features/home/domain/entities/banner_entity.dart';

class BannerModel extends BannerEntity {
  const BannerModel({
    required super.id,
    required super.photo,
    required super.name,
    required super.createdAt,
    required super.updatedAt,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json["id"] as String,
      photo: json["photo"] as String,
      name: json["name"] as String,
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
