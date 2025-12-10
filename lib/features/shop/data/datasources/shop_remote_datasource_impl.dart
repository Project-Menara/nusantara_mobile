import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nusantara_mobile/core/constant/api_constant.dart';
import 'package:nusantara_mobile/core/error/exceptions.dart';
import 'package:nusantara_mobile/features/authentication/data/datasources/local_dataSource.dart';
import 'package:nusantara_mobile/features/shop/data/datasources/shop_remote_datasource.dart';
import 'package:nusantara_mobile/features/shop/data/models/shop_model.dart';

class ShopRemoteDataSourceImpl implements ShopRemoteDataSource {
  final http.Client client;
  final LocalDatasource localDatasource;
  final Function()? onTokenExpired;

  ShopRemoteDataSourceImpl({
    required this.client,
    required this.localDatasource,
    this.onTokenExpired,
  });

  @override
  Future<List<ShopModel>> getNearbyShops({
    required double lat,
    required double lng,
    bool public = false,
  }) async {
    try {
      // Decide endpoint depending on `public` flag
      final path = public
          ? '${ApiConstant.baseUrl}/customer/addresses/public-nearby-shops'
          : '${ApiConstant.baseUrl}/customer/addresses/nearby-shops';

      final uri = Uri.parse(path).replace(
        queryParameters: {'lat': lat.toString(), 'lng': lng.toString()},
      );

      // Prepare headers
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (!public) {
        final token = await localDatasource.getAuthToken();
        if (token == null) {
          throw const ServerException(
            'Token tidak ditemukan. Silakan login kembali.',
          );
        }
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await client.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'] ?? [];

        // 🔥 DEBUG: Print nearby shops response
        print('\n🔥🔥🔥 [NEARBY SHOPS API] RAW RESPONSE 🔥🔥🔥');
        print('Response Body Length: ${response.body.length}');
        print('📦 Total Shops: ${data.length}');

        if (data.isNotEmpty) {
          final firstShop = data[0];
          print('\n🏪 First Shop Data:');
          print('   Shop Name: ${firstShop['name']}');

          if (firstShop['shop_product'] != null &&
              firstShop['shop_product'] is List) {
            final products = firstShop['shop_product'] as List;
            print('   Total Products: ${products.length}');

            if (products.isNotEmpty) {
              final firstProduct = products[0];
              print('\n   🎯 First Product:');
              print('      Name: ${firstProduct['name']}');
              print(
                '      product_images exists: ${firstProduct.containsKey('product_images')}',
              );
              print(
                '      product_images type: ${firstProduct['product_images'].runtimeType}',
              );
              print(
                '      product_images raw: ${firstProduct['product_images']}',
              );
            }
          }
        }
        print('🔥🔥🔥 END NEARBY SHOPS RESPONSE 🔥🔥🔥\n');

        return data.map((shopJson) => ShopModel.fromJson(shopJson)).toList();
      } else if (response.statusCode == 401) {
        // Token expired
        onTokenExpired?.call();
        throw const ServerException('Token expired');
      } else {
        throw ServerException(
          'Failed to get nearby shops. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      } else {
        throw ServerException(e.toString());
      }
    }
  }

  @override
  Future<ShopModel> getShopDetail({required String shopId}) async {
    try {
      final path = '${ApiConstant.baseUrl}/customer/shops/$shopId';
      final uri = Uri.parse(path);

      // Prepare headers with auth token
      final token = await localDatasource.getAuthToken();
      if (token == null) {
        throw const ServerException(
          'Token tidak ditemukan. Silakan login kembali.',
        );
      }

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await client.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final Map<String, dynamic> data = jsonResponse['data'];

        // 🔥 DEBUG: Print RAW API response untuk shop detail
        print('\n🔥🔥🔥 [SHOP DETAIL API] RAW RESPONSE 🔥🔥🔥');
        print('Response Body Length: ${response.body.length}');

        // Print shop_product array
        if (data['shop_product'] != null && data['shop_product'] is List) {
          final products = data['shop_product'] as List;
          print('\n📦 Total Products: ${products.length}');

          if (products.isNotEmpty) {
            final firstProduct = products[0];
            print('\n🎯 First Product Data:');
            print('   Keys: ${firstProduct.keys.toList()}');
            print('   Name: ${firstProduct['name']}');
            print(
              '   product_images exists: ${firstProduct.containsKey('product_images')}',
            );
            print(
              '   product_images type: ${firstProduct['product_images'].runtimeType}',
            );
            print(
              '   product_images raw value: ${firstProduct['product_images']}',
            );
          }
        }
        print('🔥🔥🔥 END RAW RESPONSE 🔥🔥🔥\n');

        return ShopModel.fromJson(data);
      } else if (response.statusCode == 401) {
        // Token expired
        onTokenExpired?.call();
        throw const ServerException('Token expired');
      } else {
        throw ServerException(
          'Failed to get shop detail. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      } else {
        throw ServerException(e.toString());
      }
    }
  }
}
