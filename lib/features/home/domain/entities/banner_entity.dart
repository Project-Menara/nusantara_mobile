import 'package:equatable/equatable.dart';
import 'package:nusantara_mobile/features/authentication/domain/entities/user_entity.dart';

class BannerEntity extends Equatable {
  final String id;
  final String photo;
  final String name;
  final String description;
  final UserEntity? user;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BannerEntity({
    required this.id,
    required this.photo,
    required this.name,
    required this.description,
    this.user,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, photo, name, createdAt, updatedAt];
}
