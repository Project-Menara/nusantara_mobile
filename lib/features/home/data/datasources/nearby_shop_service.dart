import 'package:http/http.dart' as http;
import 'package:nusantara_mobile/core/constant/api_constant.dart';
import 'package:nusantara_mobile/core/injection_container.dart' as di;
import 'package:nusantara_mobile/features/authentication/data/datasources/local_dataSource.dart';
import '../models/shop_model.dart';

class NearbyShopService {
  final http.Client client;

  NearbyShopService({http.Client? client}) : client = client ?? http.Client();

  /// Fetch nearby shops for the current customer.
  /// If [lat] and [lang] are provided, they will be added as query parameters
  /// so the backend can compute nearby shops relative to that coordinate.
  Future<List<ShopModel>> fetchNearbyShops({double? lat, double? lng}) async {
    // Use public endpoint when there's no auth token available
    final local = di.sl<LocalDatasource>();
    final token = await local.getAuthToken();
    final basePath = token == null
        ? '${ApiConstant.baseUrl}/customer/addresses/public-nearby-shops'
        : '${ApiConstant.baseUrl}/customer/addresses/nearby-shops';

    // Build URI with optional lat/lng query parameters
    Uri uri = Uri.parse(basePath);
    if (lat != null && lng != null) {
      uri = uri.replace(
        queryParameters: {'lat': lat.toString(), 'lng': lng.toString()},
      );
    }

    // Build headers. Only include Authorization when token exists.
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final resp = await client.get(uri, headers: headers);

    // Debug: log raw response for troubleshooting
    // ignore: avoid_print
    print('[NearbyShopService] GET $uri -> ${resp.statusCode}');
    // ignore: avoid_print
    print('[NearbyShopService] body: ${resp.body}');

    if (resp.statusCode == 200) {
      final list = ShopModel.listFromJson(resp.body);
      // ignore: avoid_print
      print('[NearbyShopService] parsed ${list.length} shops');
      return list;
    }

    // Throw including body for easier debugging in UI
    throw Exception(
      'Failed to load nearby shops: ${resp.statusCode} - ${resp.body}',
    );
  }
}
