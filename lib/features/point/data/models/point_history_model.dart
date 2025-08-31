import 'package:nusantara_mobile/features/authentication/data/models/user_model.dart';
import 'package:nusantara_mobile/features/point/domain/entities/point_history_entity.dart';

class PointHistoryModel extends PointHistoryEntity {
  const PointHistoryModel({
    required super.id,
    required super.user,
    required super.pointType,
    required super.source,
    required super.sourceId,
    required super.points,
    super.expiredAt,
    required super.description,
    required super.direction,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
  });

  factory PointHistoryModel.fromJson(Map<String, dynamic> json) {
    try {
      return PointHistoryModel(
        id: json['id']?.toString() ?? '',
        user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
        pointType: json['point_type']?.toString() ?? '',
        source: json['source']?.toString() ?? '',
        sourceId: json['source_id']?.toString() ?? '',
        points: (json['points'] as num?)?.toInt() ?? 0,
        expiredAt: json['expired_at'] != null
            ? DateTime.parse(json['expired_at'].toString())
            : null,
        description: json['description']?.toString() ?? '',
        direction: json['direction']?.toString() ?? '',
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'].toString())
            : DateTime.now(),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'].toString())
            : DateTime.now(),
        deletedAt: json['deleted_at'] != null
            ? DateTime.parse(json['deleted_at'].toString())
            : null,
      );
    } catch (e) {
      print("❌ PointHistoryModel.fromJson error: $e");
      print("📦 JSON data: $json");
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': (user as UserModel).toJson(),
      'point_type': pointType,
      'source': source,
      'source_id': sourceId,
      'points': points,
      'expired_at': expiredAt?.toIso8601String(),
      'description': description,
      'direction': direction,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }
}
