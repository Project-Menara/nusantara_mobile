import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nusantara_mobile/core/constant/api_constant.dart';
import 'package:nusantara_mobile/core/error/exceptions.dart';
import 'package:nusantara_mobile/core/utils/jwt_helper.dart';
import 'package:nusantara_mobile/features/voucher/data/models/voucher_model.dart';
import 'package:nusantara_mobile/features/voucher/data/models/claimed_voucher_model.dart';
import 'package:nusantara_mobile/features/authentication/data/datasources/local_dataSource.dart';

abstract class VoucherRemoteDataSource {
  Future<List<VoucherModel>> getVouchers();
  Future<VoucherModel> getVoucherById(String id);
  Future<ClaimedVoucherModel> claimVoucher(String voucherId);
  Future<List<ClaimedVoucherModel>> getClaimedVouchers();
}

class VoucherRemoteDataSourceImpl implements VoucherRemoteDataSource {
  final http.Client client;
  final LocalDatasource localDatasource;

  // Callback untuk menangani token expired
  final Function()? onTokenExpired;

  VoucherRemoteDataSourceImpl({
    required this.client,
    required this.localDatasource,
    this.onTokenExpired,
  });

  // Method untuk menangani response 401
  void _handleTokenExpired() {
    // print("🔐 VoucherRemoteDataSource: Token expired detected, triggering callback");
    if (onTokenExpired != null) {
      onTokenExpired!();
    }
  }

  @override
  Future<List<VoucherModel>> getVouchers() async {
    final uri = Uri.parse('${ApiConstant.baseUrl}/voucher/customer');
    // print("🔗 Requesting vouchers from: $uri");

    try {
      // Ambil token autentikasi dari local storage
      final token = await localDatasource.getAuthToken();
      // print("🔑 Token found: ${token != null ? 'Yes' : 'No'}");

      if (token == null) {
        throw const ServerException(
          'Token autentikasi tidak ditemukan. Silakan login kembali.',
        );
      }

      // Cek apakah token sudah expired atau akan expired dalam 5 menit
      if (JwtHelper.isTokenExpired(token) ||
          JwtHelper.isTokenNearExpiry(token, thresholdMinutes: 5)) {
        // debug: Token expired or near expiry
        _handleTokenExpired();
        throw const ServerException(
          'Token autentikasi sudah kedaluwarsa atau akan expired. Silakan login kembali.',
        );
      }

      // debug: Token is valid (remaining time available)

      final response = await client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // print("📡 Response Status Code: ${response.statusCode}");
      // print("📝 Raw Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        // print("✅ Parsed JSON Response: $jsonResponse");

        // Pastikan 'data' ada dan merupakan sebuah List
        if (jsonResponse['data'] is List) {
          final List<dynamic> data = jsonResponse['data'];
          // print("📋 Data count: ${data.length}");

          final vouchers = data.map((json) {
            // print("🎫 Processing voucher: $json");
            return VoucherModel.fromJson(json);
          }).toList();

          // print("✅ Successfully parsed ${vouchers.length} vouchers");
          return vouchers;
        } else {
          // print("⚠️ Response data is not a List, returning empty list");
          return [];
        }
      } else if (response.statusCode == 401) {
        // print("❌ Authentication error - Token mungkin expired");
        _handleTokenExpired();
        throw const ServerException(
          'Token autentikasi tidak valid atau sudah kedaluwarsa. Silakan login kembali.',
        );
      } else {
        // print("❌ Server error: ${response.statusCode} - ${response.body}");
        throw ServerException(
          'Gagal mengambil daftar voucher. Kode: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      // print("💥 Exception occurred: $e");
      // print("💥 Exception type: ${e.runtimeType}");
      if (e is ServerException) {
        rethrow;
      } else {
        throw ServerException(e.toString());
      }
    }
  }

  @override
  Future<VoucherModel> getVoucherById(String id) async {
    final uri = Uri.parse('${ApiConstant.baseUrl}/voucher/$id/customer');
    // print("🔗 Requesting voucher detail from: $uri");

    try {
      // Ambil token autentikasi dari local storage
      final token = await localDatasource.getAuthToken();
      // print("🔑 Token found: ${token != null ? 'Yes' : 'No'}");

      if (token == null) {
        throw const ServerException(
          'Token autentikasi tidak ditemukan. Silakan login kembali.',
        );
      }

      // Cek apakah token sudah expired atau akan expired dalam 5 menit
      if (JwtHelper.isTokenExpired(token) ||
          JwtHelper.isTokenNearExpiry(token, thresholdMinutes: 5)) {
        // debug: Token expired or near expiry
        _handleTokenExpired();
        throw const ServerException(
          'Token autentikasi sudah kedaluwarsa atau akan expired. Silakan login kembali.',
        );
      }

      // debug: Token is valid (remaining time available)

      final response = await client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // print("📡 Response Status Code: ${response.statusCode}");
      // print("📝 Raw Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        // print("✅ Parsed JSON Response: $jsonResponse");

        // Asumsi data detail juga ada di dalam key 'data'
        if (jsonResponse['data'] is Map<String, dynamic>) {
          final data = VoucherModel.fromJson(jsonResponse['data']);
          return data;
        } else {
          throw const ServerException(
            'Format data detail voucher tidak valid.',
          );
        }
      } else if (response.statusCode == 401) {
        // print("❌ Authentication error - Token mungkin expired");
        _handleTokenExpired();
        throw const ServerException(
          'Token autentikasi tidak valid atau sudah kedaluwarsa. Silakan login kembali.',
        );
      } else {
        throw ServerException(
          'Gagal mengambil detail voucher. Kode: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      // print("💥 Exception occurred: $e");
      // print("💥 Exception type: ${e.runtimeType}");
      if (e is ServerException) {
        rethrow;
      } else {
        throw ServerException(e.toString());
      }
    }
  }

  @override
  Future<ClaimedVoucherModel> claimVoucher(String voucherId) async {
    final uri = Uri.parse(
      '${ApiConstant.baseUrl}/customer/claim-voucher/$voucherId',
    );
    // print("🔗 Claiming voucher from: $uri");

    try {
      // Ambil token autentikasi dari local storage
      final token = await localDatasource.getAuthToken();
      // print("🔑 Token found: ${token != null ? 'Yes' : 'No'}");

      if (token == null) {
        throw const ServerException(
          'Token autentikasi tidak ditemukan. Silakan login kembali.',
        );
      }

      // Cek apakah token sudah expired atau akan expired dalam 5 menit
      if (JwtHelper.isTokenExpired(token) ||
          JwtHelper.isTokenNearExpiry(token, thresholdMinutes: 5)) {
        // debug: Token expired or near expiry
        _handleTokenExpired();
        throw const ServerException(
          'Token autentikasi sudah kedaluwarsa atau akan expired. Silakan login kembali.',
        );
      }

      // debug: Token is valid (remaining time available)

      final response = await client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // print("📡 Response Status Code: ${response.statusCode}");
      // print("📝 Raw Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        // print("✅ Parsed JSON Response: $jsonResponse");

        if (jsonResponse['data'] is Map<String, dynamic>) {
          final data = ClaimedVoucherModel.fromJson(jsonResponse['data']);
          return data;
        } else {
          throw const ServerException('Format data claim voucher tidak valid.');
        }
      } else if (response.statusCode == 401) {
        // print("❌ Authentication error - Token mungkin expired");
        _handleTokenExpired();
        throw const ServerException(
          'Token autentikasi tidak valid atau sudah kedaluwarsa. Silakan login kembali.',
        );
      } else {
        throw ServerException(
          'Gagal claim voucher. Kode: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      // print("💥 Exception occurred: $e");
      // print("💥 Exception type: ${e.runtimeType}");
      if (e is ServerException) {
        rethrow;
      } else {
        throw ServerException(e.toString());
      }
    }
  }

  @override
  Future<List<ClaimedVoucherModel>> getClaimedVouchers() async {
    final uri = Uri.parse('${ApiConstant.baseUrl}/customer/vouchers/claimed');
    // print("🔗 Requesting claimed vouchers from: $uri");

    try {
      // Ambil token autentikasi dari local storage
      final token = await localDatasource.getAuthToken();
      // print("🔑 Token found: ${token != null ? 'Yes' : 'No'}");

      if (token == null) {
        throw const ServerException(
          'Token autentikasi tidak ditemukan. Silakan login kembali.',
        );
      }

      // Cek apakah token sudah expired atau akan expired dalam 5 menit
      if (JwtHelper.isTokenExpired(token) ||
          JwtHelper.isTokenNearExpiry(token, thresholdMinutes: 5)) {
        // debug: Token expired or near expiry
        _handleTokenExpired();
        throw const ServerException(
          'Token autentikasi sudah kedaluwarsa atau akan expired. Silakan login kembali.',
        );
      }

      // debug: Token is valid (remaining time available)

      final response = await client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // print("📡 Response Status Code: ${response.statusCode}");
      // print("📝 Raw Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        // print("✅ Parsed JSON Response: $jsonResponse");

        // Pastikan 'data' ada dan merupakan sebuah List
        if (jsonResponse['data'] is List) {
          final List<dynamic> data = jsonResponse['data'];
          // print("📋 Claimed vouchers count: ${data.length}");

          final claimedVouchers = data.map((json) {
            // print("🎫 Processing claimed voucher: $json");
            return ClaimedVoucherModel.fromJson(json);
          }).toList();

          // print("✅ Successfully parsed ${claimedVouchers.length} claimed vouchers");
          return claimedVouchers;
        } else {
          // print("⚠️ Response data is not a List, returning empty list");
          return [];
        }
      } else if (response.statusCode == 401) {
        // print("❌ Authentication error - Token mungkin expired");
        _handleTokenExpired();
        throw const ServerException(
          'Token autentikasi tidak valid atau sudah kedaluwarsa. Silakan login kembali.',
        );
      } else {
        // print("❌ Server error: ${response.statusCode} - ${response.body}");
        throw ServerException(
          'Gagal mengambil daftar claimed vouchers. Kode: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      // print("💥 Exception occurred: $e");
      // print("💥 Exception type: ${e.runtimeType}");
      if (e is ServerException) {
        rethrow;
      } else {
        throw ServerException(e.toString());
      }
    }
  }
}
