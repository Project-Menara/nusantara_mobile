import 'package:equatable/equatable.dart';

class EventEntity extends Equatable {
  final String id;
  final String name;
  final String cover;

  const EventEntity({
    required this.id,
    required this.name,
    required this.cover,
  });

  @override
  List<Object?> get props => [id, name, cover];
}
