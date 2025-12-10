import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:nusantara_mobile/core/constant/api_constant.dart';
import 'package:nusantara_mobile/core/error/exceptions.dart';
import 'package:nusantara_mobile/features/home/data/models/event_model.dart';

abstract class EventRemoteDatasource {
  Future<List<EventModel>> getAllEvents();
  Future<EventModel> getEventById(String id);
}

class EventRemoteDatasourceImpl implements EventRemoteDatasource {
  final http.Client client;

  EventRemoteDatasourceImpl({required this.client});

  @override
  Future<List<EventModel>> getAllEvents() async {
    // Endpoint publik: {{BASE_URL}}/event/all/public
    // Di app, BASE_URL = https://.../api/v1, jadi full path:
    // https://.../api/v1/event/all/public
    final uri = Uri.parse('${ApiConstant.baseUrl}/event/all/public');
    try {
      final response = await client.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      // Debug log untuk melihat response asli dari backend
      // ignore: avoid_print
      print('[EventRemoteDatasource] GET $uri -> ${response.statusCode}');
      // ignore: avoid_print
      print('[EventRemoteDatasource] body: ${response.body}');

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        try {
          final List<dynamic> data = jsonResponse['data'];
          return data
              .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
              .toList();
        } catch (e) {
          throw ServerException(e.toString());
        }
      } else {
        final message = (jsonResponse['message'] ?? 'Failed to get events')
            .toString();
        throw ServerException(
          'Failed to get events: $message '
          '(${response.statusCode})',
        );
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<EventModel> getEventById(String id) async {
    // Endpoint detail publik: {{BASE_URL}}/event/:id/public
    final uri = Uri.parse('${ApiConstant.baseUrl}/event/$id/public');
    try {
      final response = await client.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      // ignore: avoid_print
      print('[EventRemoteDatasource] GET $uri -> ${response.statusCode}');
      // ignore: avoid_print
      print('[EventRemoteDatasource] body: ${response.body}');

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        try {
          return EventModel.fromJson(
            jsonResponse['data'] as Map<String, dynamic>,
          );
        } catch (e) {
          throw ServerException(e.toString());
        }
      } else {
        final message =
            (jsonResponse['message'] ?? 'Failed to get event detail')
                .toString();
        throw ServerException(
          'Failed to get event detail: $message '
          '(${response.statusCode})',
        );
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
