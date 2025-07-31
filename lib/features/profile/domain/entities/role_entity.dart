import 'package:equatable/equatable.dart';

class RoleEntity extends Equatable {
  final String id;
  final String name;

  const RoleEntity({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}
