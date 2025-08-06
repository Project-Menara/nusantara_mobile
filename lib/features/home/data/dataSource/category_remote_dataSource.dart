import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nusantara_mobile/core/constant/api_constant.dart';
import 'package:nusantara_mobile/core/error/exceptions.dart';
import 'package:nusantara_mobile/features/home/data/models/category_model.dart';

abstract class CategoryRemoteDatasource {
  Future<List<CategoryModel>> getAllCategories();
  Future<CategoryModel> getCategoryById(String id);
}

class CategoryRemoteDatasourceImpl implements CategoryRemoteDatasource {
  final http.Client client;

  CategoryRemoteDatasourceImpl({required this.client});

  @override
  Future<List<CategoryModel>> getAllCategories() async {
    final uri = Uri.parse('${ApiConstant.baseUrl}/type-product/customer');
    try {
      final response = await client.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      print("data categories: $jsonResponse");

      if (response.statusCode == 200) {
        try {
          final List<dynamic> data = jsonResponse['data'];
          return data.map((json) => CategoryModel.fromJson(json)).toList();
        } catch (e) {
          throw ServerException(e.toString());
        }
      } else {
        throw const ServerException('Failed to get categories');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<CategoryModel> getCategoryById(String id) async {
    final uri = Uri.parse('${ApiConstant.baseUrl}/type-product/$id/customer');
    try {
      final response = await client.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      print("data categories by id: $jsonResponse");

      if (response.statusCode == 200) {
        try {
          final data = CategoryModel.fromJson(jsonResponse['data']);
          return data;
        } catch (e) {
          throw ServerException(e.toString());
        }
      } else {
        throw const ServerException('Failed to get category detail');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
