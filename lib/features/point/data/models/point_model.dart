import 'package:nusantara_mobile/features/authentication/data/models/user_model.dart';
import 'package:nusantara_mobile/features/authentication/data/models/role_model.dart';
import 'package:nusantara_mobile/features/point/domain/entities/point_entity.dart';

class PointModel extends PointEntity {
  const PointModel({
    required super.id,
    required super.user,
    required super.totalPoints,
    super.expiredDates,
    required super.totalExpired,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
  });

  factory PointModel.fromJson(Map<String, dynamic> json) {
    try {
      print("🔍 PointModel.fromJson: Processing JSON data");
      print("📦 JSON data: $json");

      // Safe parsing with detailed logging
      final userJson = json['user'];
      print("👤 User data type: ${userJson.runtimeType}, value: $userJson");

      UserModel user;
      if (userJson != null && userJson is Map<String, dynamic>) {
        user = UserModel.fromJson(userJson);
      } else {
        print("⚠️ Creating default user model due to null/invalid user data");
        user = UserModel(
          id: '',
          name: '',
          username: '',
          email: '',
          phone: '',
          gender: '',
          role: RoleModel(id: '', name: ''),
          status: 0,
          deletedAt: DateTime.now(),
        );
      }

      return PointModel(
        id: json['id']?.toString() ?? '',
        user: user,
        totalPoints: (json['total_points'] as num?)?.toInt() ?? 0,
        expiredDates: json['expired_dates'] != null
            ? DateTime.parse(json['expired_dates'].toString())
            : null,
        totalExpired: (json['total_expired'] as num?)?.toInt() ?? 0,
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
      print("❌ PointModel.fromJson error: $e");
      print("📦 JSON data: $json");
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': (user as UserModel).toJson(),
      'total_points': totalPoints,
      'expired_dates': expiredDates?.toIso8601String(),
      'total_expired': totalExpired,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }
}
