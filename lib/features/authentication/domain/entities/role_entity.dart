import 'package:equatable/equatable.dart';

class RoleEntity extends Equatable {
  final String id;
  final String name;

  const RoleEntity({required this.id, required this.name});

  const RoleEntity.empty() : id = '', name = '';

  factory RoleEntity.fromJson(Map<String, dynamic> json) {
    return RoleEntity(id: json['id'] as String, name: json['name'] as String);
  }

  @override
  List<Object?> get props => [id, name];
}
