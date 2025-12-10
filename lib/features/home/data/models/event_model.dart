import 'dart:convert';

import 'package:nusantara_mobile/features/home/domain/entities/event_entity.dart';

class EventModel extends EventEntity {
  const EventModel({
    required super.id,
    required super.name,
    required super.cover,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      name: json['name'] as String,
      cover: json['cover'] as String,
    );
  }

  static List<EventModel> listFromWrappedJson(String source) {
    final Map<String, dynamic> jsonMap = jsonDecode(source);
    final List<dynamic> data = jsonMap['data'] as List<dynamic>;
    return data
        .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static EventModel fromWrappedDetailJson(String source) {
    final Map<String, dynamic> jsonMap = jsonDecode(source);
    return EventModel.fromJson(jsonMap['data'] as Map<String, dynamic>);
  }
}
