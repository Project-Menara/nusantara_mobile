import 'package:equatable/equatable.dart';
import 'package:nusantara_mobile/features/authentication/domain/entities/user_entity.dart';

class PointEntity extends Equatable {
  final String id;
  final UserEntity user;
  final int totalPoints;
  final DateTime? expiredDates;
  final int totalExpired;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const PointEntity({
    required this.id,
    required this.user,
    required this.totalPoints,
    this.expiredDates,
    required this.totalExpired,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  @override
  List<Object?> get props => [
    id,
    user,
    totalPoints,
    expiredDates,
    totalExpired,
    createdAt,
    updatedAt,
    deletedAt,
  ];
}
