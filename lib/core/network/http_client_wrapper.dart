import 'dart:async';
import 'package:http/http.dart' as http;

class HttpClientWrapper extends http.BaseClient {
  final http.Client _client;

  HttpClientWrapper(this._client);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await _client.send(request);
    return response;
  }

  @override
  void close() {
    _client.close();
  }
}
