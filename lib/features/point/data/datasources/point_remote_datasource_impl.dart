import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:nusantara_mobile/core/constant/api_constant.dart';
import 'package:nusantara_mobile/core/error/exceptions.dart';
import 'package:nusantara_mobile/features/authentication/data/datasources/local_dataSource.dart';
import 'package:nusantara_mobile/features/authentication/data/models/user_model.dart';
import 'package:nusantara_mobile/features/authentication/data/models/role_model.dart';
import 'package:nusantara_mobile/features/point/data/datasources/point_remote_datasource.dart';
import 'package:nusantara_mobile/features/point/data/models/point_history_model.dart';
import 'package:nusantara_mobile/features/point/data/models/point_model.dart';

class PointRemoteDatasourceImpl implements PointRemoteDatasource {
  final http.Client client;
  final LocalDatasource localDatasource;

  // Callback untuk menangani token expired
  final Function()? onTokenExpired;

  PointRemoteDatasourceImpl({
    required this.client,
    required this.localDatasource,
    this.onTokenExpired,
  });

  Map<String, String> _headers({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Method untuk menangani response 401
  void _handleTokenExpired() {
    print(
      "🔐 PointRemoteDataSource: Token expired detected, triggering callback",
    );
    if (onTokenExpired != null) {
      onTokenExpired!();
    }
  }

  dynamic _processResponse(http.Response response) {
    final jsonResponse = json.decode(response.body);
    print(
      "API Response (${response.request?.url}): ${response.statusCode} -> $jsonResponse",
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonResponse;
    } else if (response.statusCode == 401) {
      // Handle token expired
      _handleTokenExpired();
      throw const ServerException('Token expired. Please login again.');
    } else if (response.statusCode == 400) {
      throw ServerException(jsonResponse['message'] ?? 'Bad Request');
    } else {
      throw ServerException(jsonResponse['message'] ?? 'Internal Server Error');
    }
  }

  @override
  Future<PointModel> getCustomerPoint() async {
    print("🚀 === DATASOURCE: getCustomerPoint() CALLED ===");
    print("⏰ Timestamp: ${DateTime.now()}");

    final uri = Uri.parse('${ApiConstant.baseUrl}/customer/point');
    print("🔗 Requesting customer point from: $uri");

    try {
      // Ambil token autentikasi dari local storage
      final token = await localDatasource.getAuthToken();
      print("🔑 Token found: ${token != null ? 'Yes' : 'No'}");

      if (token == null) {
        throw const ServerException(
          'Token autentikasi tidak ditemukan. Silakan login kembali.',
        );
      }

      print("🌐 Making GET request for customer point...");
      final response = await client.get(uri, headers: _headers(token: token));

      print("📦 Response received: ${response.statusCode}");
      print("📋 Raw response body: ${response.body}");
      final jsonResponse = _processResponse(response);

      print("📋 Parsed JSON response: $jsonResponse");
      print("📋 Raw API response data: ${jsonResponse['data']}");

      // Handle null or empty data
      if (jsonResponse['data'] == null) {
        print("⚠️ API returned null data, creating default point model");
        // Return a default point model with 0 points if API doesn't return data
        return PointModel(
          id: '',
          user: UserModel(
            id: '',
            name: '',
            username: '',
            email: '',
            phone: '',
            gender: '',
            role: RoleModel(id: '', name: ''),
            status: 0,
            deletedAt: DateTime.now(),
          ),
          totalPoints: 0,
          totalExpired: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }

      // Extract the customer_point data from the nested structure
      final data = jsonResponse['data'];
      print("🔍 Data structure: $data");
      print("🔍 Data type: ${data.runtimeType}");
      print("🔍 All response keys: ${jsonResponse.keys.toList()}");

      if (data != null && data is Map<String, dynamic>) {
        print("🔍 Data keys: ${data.keys.toList()}");
        data.forEach((key, value) {
          print("  📋 $key: $value (${value.runtimeType})");
        });
      }

      if (data == null) {
        print("⚠️ data is null in API response");
        throw const ServerException('Data tidak ditemukan dalam response');
      }

      final customerPointData = data['customer_point'];
      print("🔍 Customer point data: $customerPointData");
      print("🔍 Customer point data type: ${customerPointData.runtimeType}");

      if (customerPointData == null) {
        print("⚠️ customer_point data not found in API response");
        print("🔍 Available data keys: ${data.keys.toList()}");
        throw const ServerException(
          'Data customer_point tidak ditemukan dalam response',
        );
      }

      // Ensure customerPointData is a Map<String, dynamic>
      if (customerPointData is! Map<String, dynamic>) {
        print(
          "⚠️ customer_point data is not a Map<String, dynamic>, it's ${customerPointData.runtimeType}",
        );
        throw const ServerException('Format data customer_point tidak valid');
      }

      print("🔍 Creating PointModel from customer_point data...");
      print(
        "📊 Customer point data fields: ${customerPointData.keys.toList()}",
      );

      // Log each field in customer point data
      customerPointData.forEach((key, value) {
        print("  🏷️ $key: $value (${value.runtimeType})");
      });

      // Extract expiry data from data level (not customer_point level)
      final expiredDates = data['expired_dates'];
      final totalExpired = data['total_expired'];

      print(
        "🔍 Expired dates from data level: $expiredDates (${expiredDates.runtimeType})",
      );
      print(
        "🔍 Total expired from data level: $totalExpired (${totalExpired.runtimeType})",
      );
      print("🔍 Full data keys: ${data.keys.toList()}");
      print("🔍 Full data: $data");

      // Create a combined JSON object with expiry data
      final combinedData = Map<String, dynamic>.from(customerPointData);
      combinedData['expired_dates'] = expiredDates;
      combinedData['total_expired'] = totalExpired;

      print("🔍 Combined data for PointModel: $combinedData");
      print("🔍 Combined data expired_dates: ${combinedData['expired_dates']}");
      print("🔍 Combined data total_expired: ${combinedData['total_expired']}");

      final pointModel = PointModel.fromJson(combinedData);
      print(
        "✅ PointModel created successfully with ${pointModel.totalPoints} points",
      );
      print("✅ ExpiredDates: ${pointModel.expiredDates}");
      print("✅ TotalExpired: ${pointModel.totalExpired}");

      return pointModel;
    } on SocketException {
      print("❌ Network error when fetching customer point");
      throw const ServerException('Koneksi internet bermasalah');
    } catch (e) {
      print("💥 Unexpected error in getCustomerPoint: $e");
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('Gagal mendapatkan data point: ${e.toString()}');
    }
  }

  @override
  Future<List<PointHistoryModel>> getCustomerPointHistory() async {
    final uri = Uri.parse('${ApiConstant.baseUrl}/customer/point/history');
    print("🔗 Requesting customer point history from: $uri");

    try {
      // Ambil token autentikasi dari local storage
      final token = await localDatasource.getAuthToken();
      print("🔑 Token found: ${token != null ? 'Yes' : 'No'}");

      if (token == null) {
        throw const ServerException(
          'Token autentikasi tidak ditemukan. Silakan login kembali.',
        );
      }

      print("🌐 Making GET request for customer point history...");
      final response = await client.get(uri, headers: _headers(token: token));

      print("📦 Response received: ${response.statusCode}");
      final jsonResponse = _processResponse(response);

      if (jsonResponse['data'] == null) {
        throw const ServerException(
          'Data point history tidak ditemukan dalam response',
        );
      }

      final List<dynamic> dataList = jsonResponse['data'] as List<dynamic>;
      final pointHistoryList = dataList
          .map(
            (item) => PointHistoryModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();

      print(
        "✅ Point history loaded successfully: ${pointHistoryList.length} entries",
      );

      return pointHistoryList;
    } on SocketException {
      print("❌ Network error when fetching customer point history");
      throw const ServerException('Koneksi internet bermasalah');
    } catch (e) {
      print("💥 Unexpected error in getCustomerPointHistory: $e");
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(
        'Gagal mendapatkan data riwayat point: ${e.toString()}',
      );
    }
  }
}
