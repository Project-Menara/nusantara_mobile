import 'package:equatable/equatable.dart';
import 'package:nusantara_mobile/features/authentication/domain/entities/user_entity.dart';

class PointHistoryEntity extends Equatable {
  final String id;
  final UserEntity user;
  final String pointType;
  final String source;
  final String sourceId;
  final int points;
  final DateTime? expiredAt;
  final String description;
  final String direction; // "in" or "out"
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const PointHistoryEntity({
    required this.id,
    required this.user,
    required this.pointType,
    required this.source,
    required this.sourceId,
    required this.points,
    this.expiredAt,
    required this.description,
    required this.direction,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  @override
  List<Object?> get props => [
    id,
    user,
    pointType,
    source,
    sourceId,
    points,
    expiredAt,
    description,
    direction,
    createdAt,
    updatedAt,
    deletedAt,
  ];
}
