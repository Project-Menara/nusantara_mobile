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
    // debug: 🔐 PointRemoteDataSource: Token expired detected, triggering callback
    if (onTokenExpired != null) {
      onTokenExpired!();
    }
  }

  dynamic _processResponse(http.Response response) {
    final jsonResponse = json.decode(response.body);
    // debug: API Response (${response.request?.url}): ${response.statusCode} -> $jsonResponse

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
    // debug: 🚀 === DATASOURCE: getCustomerPoint() CALLED ===
    // debug: ⏰ Timestamp: ${DateTime.now()}

    final uri = Uri.parse('${ApiConstant.baseUrl}/customer/point');
    // debug: 🔗 Requesting customer point from: $uri

    try {
      // Ambil token autentikasi dari local storage
      final token = await localDatasource.getAuthToken();
      // debug: 🔑 Token found: ${token != null ? 'Yes' : 'No'}

      if (token == null) {
        throw const ServerException(
          'Token autentikasi tidak ditemukan. Silakan login kembali.',
        );
      }

      // debug: 🌐 Making GET request for customer point...
      final response = await client.get(uri, headers: _headers(token: token));

      // debug: 📦 Response received: ${response.statusCode}
      // debug: 📋 Raw response body: ${response.body}
      final jsonResponse = _processResponse(response);

      // debug: 📋 Parsed JSON response: $jsonResponse
      // debug: 📋 Raw API response data: ${jsonResponse['data']}

      // Handle null or empty data
      if (jsonResponse['data'] == null) {
        // debug: ⚠️ API returned null data, creating default point model
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
      // debug: 🔍 Data structure: $data
      // debug: 🔍 Data type: ${data.runtimeType}
      // debug: 🔍 All response keys: ${jsonResponse.keys.toList()}

      if (data != null && data is Map<String, dynamic>) {
        // debug: 🔍 Data keys: ${data.keys.toList()}
        // debug: data.forEach((key, value) {
        //   // debug:  📋 $key: $value (${value.runtimeType})
        // debug: });
      }

      if (data == null) {
        // debug: ⚠️ data is null in API response
        throw const ServerException('Data tidak ditemukan dalam response');
      }

      final customerPointData = data['customer_point'];
      // debug: 🔍 Customer point data: $customerPointData
      // debug: 🔍 Customer point data type: ${customerPointData.runtimeType}

      if (customerPointData == null) {
        // debug: ⚠️ customer_point data not found in API response
        // debug: 🔍 Available data keys: ${data.keys.toList()}
        throw const ServerException(
          'Data customer_point tidak ditemukan dalam response',
        );
      }

      // Ensure customerPointData is a Map<String, dynamic>
      if (customerPointData is! Map<String, dynamic>) {
        // debug: ⚠️ customer_point data is not a Map<String, dynamic>, it's ${customerPointData.runtimeType}
        throw const ServerException('Format data customer_point tidak valid');
      }

      // debug: 🔍 Creating PointModel from customer_point data...
      // debug: 📊 Customer point data fields: ${customerPointData.keys.toList()}

      // Log each field in customer point data
      // debug: customerPointData.forEach((key, value) {
      // debug:   // debug: 🏷️ $key: $value (${value.runtimeType})
      // debug: });

      // Extract expiry data from data level (not customer_point level)
      final expiredDates = data['expired_dates'];
      final totalExpired = data['total_expired'];

      // debug: 🔍 Expired dates from data level: $expiredDates (${expiredDates.runtimeType})
      // debug: 🔍 Total expired from data level: $totalExpired (${totalExpired.runtimeType})
      // debug: 🔍 Full data keys: ${data.keys.toList()}
      // debug: 🔍 Full data: $data

      // Create a combined JSON object with expiry data
      final combinedData = Map<String, dynamic>.from(customerPointData);
      combinedData['expired_dates'] = expiredDates;
      combinedData['total_expired'] = totalExpired;

      // debug: 🔍 Combined data for PointModel: $combinedData
      // debug: 🔍 Combined data expired_dates: ${combinedData['expired_dates']}
      // debug: 🔍 Combined data total_expired: ${combinedData['total_expired']}

      final pointModel = PointModel.fromJson(combinedData);
      // debug: ✅ PointModel created successfully with ${pointModel.totalPoints} points
      // debug: ✅ ExpiredDates: ${pointModel.expiredDates}
      // debug: ✅ TotalExpired: ${pointModel.totalExpired}

      return pointModel;
    } on SocketException {
      // debug: ❌ Network error when fetching customer point
      throw const ServerException('Koneksi internet bermasalah');
    } catch (e) {
      // debug: 💥 Unexpected error in getCustomerPoint: $e
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('Gagal mendapatkan data point: ${e.toString()}');
    }
  }

  @override
  Future<List<PointHistoryModel>> getCustomerPointHistory() async {
    final uri = Uri.parse('${ApiConstant.baseUrl}/customer/point/history');
    // debug: 🔗 Requesting customer point history from: $uri

    try {
      // Ambil token autentikasi dari local storage
      final token = await localDatasource.getAuthToken();
      // debug: 🔑 Token found: ${token != null ? 'Yes' : 'No'}

      if (token == null) {
        throw const ServerException(
          'Token autentikasi tidak ditemukan. Silakan login kembali.',
        );
      }

      // debug: 🌐 Making GET request for customer point history...
      final response = await client.get(uri, headers: _headers(token: token));

      // debug: 📦 Response received: ${response.statusCode}
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

      // debug: ✅ Point history loaded successfully: ${pointHistoryList.length} entries

      return pointHistoryList;
    } on SocketException {
      // debug: ❌ Network error when fetching customer point history
      throw const ServerException('Koneksi internet bermasalah');
    } catch (e) {
      // debug: 💥 Unexpected error in getCustomerPointHistory: $e
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(
        'Gagal mendapatkan data riwayat point: ${e.toString()}',
      );
    }
  }
}
