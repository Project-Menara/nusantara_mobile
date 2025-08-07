import 'dart:convert';

import 'package:nusantara_mobile/core/constant/api_constant.dart';
import 'package:nusantara_mobile/core/error/exceptions.dart';
import 'package:nusantara_mobile/features/home/data/models/banner_model.dart';
import 'package:http/http.dart' as http;

abstract class BannerRemoteDatasource {
  Future<List<BannerModel>> getBanners();
  Future<BannerModel> getBannerById(String id);
}

class BannerRemoteDatasourceImpl implements BannerRemoteDatasource {
  final http.Client client;

  BannerRemoteDatasourceImpl({required this.client});

  @override
  Future<List<BannerModel>> getBanners() async {
    final uri = Uri.parse('${ApiConstant.baseUrl}/banner/customer');
    try {
      final response = await client.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      // print("data banners: $jsonResponse");

      if (response.statusCode == 200) {
        try {
          final List<dynamic> data = jsonResponse['data'];
          return data.map((json) => BannerModel.fromJson(json)).toList();
        } catch (e) {
          throw ServerException(e.toString());
        }
      } else {
        throw const ServerException('Failed to get banners');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<BannerModel> getBannerById(String id) async {
    final uri = Uri.parse('${ApiConstant.baseUrl}/banner/$id/customer');
    try {
      final response = await client.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      // print("data banners by id: $jsonResponse");

      if (response.statusCode == 200) {
        try {
          final data = BannerModel.fromJson(jsonResponse['data']);
          return data;
        } catch (e) {
          throw ServerException(e.toString());
        }
      } else {
        throw const ServerException('Failed to get banner detail');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
