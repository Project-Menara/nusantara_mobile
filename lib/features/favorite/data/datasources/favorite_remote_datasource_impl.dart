import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nusantara_mobile/core/constant/api_constant.dart';
import 'package:nusantara_mobile/features/authentication/data/datasources/local_dataSource.dart';
import 'package:nusantara_mobile/core/error/exceptions.dart';
import 'package:nusantara_mobile/features/favorite/data/datasources/favorite_remote_datasource.dart';
import 'package:nusantara_mobile/features/favorite/data/models/favorite_model.dart';

class FavoriteRemoteDataSourceImpl implements FavoriteRemoteDataSource {
  final http.Client client;
  final LocalDatasource localDatasource;
  final Function()? onTokenExpired;

  FavoriteRemoteDataSourceImpl({
    required this.client,
    required this.localDatasource,
    this.onTokenExpired,
  });

  Future<Map<String, String>> _getHeaders() async {
    final token = await localDatasource.getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<List<FavoriteModel>> getMyFavorite() async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('${ApiConstant.baseUrl}/customer/my-favorite');

      print('💝 [GET FAVORITE] REQUEST:');
      print('   URL: $uri');
      print('   Headers: ${headers.keys.toList()}');

      final response = await client.get(uri, headers: headers);

      print('💝 [GET FAVORITE] RESPONSE:');
      print('   Status Code: ${response.statusCode}');
      print('   Body Length: ${response.body.length}');

      if (response.statusCode == 200) {
        // 🔥 DEBUG: Print RAW API response untuk favorite
        print('\n🔥🔥🔥 [FAVORITE API] RAW RESPONSE 🔥🔥🔥');
        final jsonData = json.decode(response.body);

        if (jsonData['data'] != null &&
            jsonData['data']['favorite_item'] is List) {
          final items = jsonData['data']['favorite_item'] as List;
          print('\n💝 Total Favorite Items: ${items.length}');

          if (items.isNotEmpty) {
            final firstItem = items[0];
            print('\n🎯 First Favorite Item Data:');
            print('   Keys: ${firstItem.keys.toList()}');

            if (firstItem['Product'] != null) {
              final product = firstItem['Product'];
              print('\n   📦 Product Object:');
              print('      Keys: ${product.keys.toList()}');
              print('      Name: ${product['name']}');
              print(
                '      product_images exists: ${product.containsKey('product_images')}',
              );
              print(
                '      product_images type: ${product['product_images'].runtimeType}',
              );
              print(
                '      product_images raw value: ${product['product_images']}',
              );
            }
          }
        }
        print('🔥🔥🔥 END RAW RESPONSE 🔥🔥🔥\n');

        final favoriteList = FavoriteModel.fromJsonList(response.body);
        print('✅ [GET FAVORITE] SUCCESS: ${favoriteList.length} items found');
        return favoriteList;
      } else if (response.statusCode == 404) {
        print('ℹ️ [GET FAVORITE] Favorite is empty (404)');
        return [];
      } else if (response.statusCode == 401) {
        print('❌ [GET FAVORITE] UNAUTHORIZED');
        onTokenExpired?.call();
        throw ServerException('Unauthorized');
      } else {
        final data = jsonDecode(response.body);
        print('❌ [GET FAVORITE] ERROR: ${data['message']}');
        throw ServerException(data['message'] ?? 'Failed to get favorite');
      }
    } catch (e) {
      print('💥 [GET FAVORITE] EXCEPTION: $e');
      if (e is ServerException) rethrow;
      throw ServerException('Network error: ${e.toString()}');
    }
  }

  @override
  Future<String> addToFavorite(String productId) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse(
        '${ApiConstant.baseUrl}/customer/add-favorite-item',
      );

      final body = jsonEncode({'product_id': productId});

      print('💝 [ADD TO FAVORITE] REQUEST:');
      print('   URL: $uri');
      print('   Headers: ${headers.keys.toList()}');
      print('   Body: $body');

      final response = await client.post(uri, headers: headers, body: body);

      print('💝 [ADD TO FAVORITE] RESPONSE:');
      print('   Status Code: ${response.statusCode}');
      print('   Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ [ADD TO FAVORITE] SUCCESS: ${data['message']}');
        return data['message'] ?? 'Add Product To My Favorite Success';
      } else if (response.statusCode == 401) {
        print('❌ [ADD TO FAVORITE] UNAUTHORIZED');
        onTokenExpired?.call();
        throw ServerException('Unauthorized');
      } else {
        final data = jsonDecode(response.body);
        print('❌ [ADD TO FAVORITE] ERROR: ${data['message']}');
        throw ServerException(data['message'] ?? 'Failed to add to favorite');
      }
    } catch (e) {
      print('💥 [ADD TO FAVORITE] EXCEPTION: $e');
      if (e is ServerException) rethrow;
      throw ServerException('Network error: ${e.toString()}');
    }
  }

  @override
  Future<String> removeFromFavorite(String productId) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse(
        '${ApiConstant.baseUrl}/customer/delete-favorite-item/$productId',
      );

      print('💝 [DELETE FAVORITE] REQUEST:');
      print('   URL: $uri');
      print('   Headers: ${headers.keys.toList()}');

      final response = await client.delete(uri, headers: headers);

      print('💝 [DELETE FAVORITE] RESPONSE:');
      print('   Status Code: ${response.statusCode}');
      print('   Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ [DELETE FAVORITE] SUCCESS: ${data['message']}');
        return data['message'] ?? 'Deleted Favorite Item Success';
      } else if (response.statusCode == 401) {
        print('❌ [DELETE FAVORITE] UNAUTHORIZED');
        onTokenExpired?.call();
        throw ServerException('Unauthorized');
      } else {
        final data = jsonDecode(response.body);
        print('❌ [DELETE FAVORITE] ERROR: ${data['message']}');
        throw ServerException(
          data['message'] ?? 'Failed to delete favorite item',
        );
      }
    } catch (e) {
      print('💥 [DELETE FAVORITE] EXCEPTION: $e');
      if (e is ServerException) rethrow;
      throw ServerException('Network error: ${e.toString()}');
    }
  }
}
