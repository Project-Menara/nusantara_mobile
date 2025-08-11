import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nusantara_mobile/core/constant/api_constant.dart';
import 'package:nusantara_mobile/core/error/exceptions.dart';
import 'package:nusantara_mobile/features/voucher/data/models/voucher_model.dart';

abstract class VoucherRemoteDataSource {
  Future<List<VoucherModel>> getVouchers();
  Future<VoucherModel> getVoucherById(String id);
}

class VoucherRemoteDataSourceImpl implements VoucherRemoteDataSource {
  final http.Client client;

  VoucherRemoteDataSourceImpl({required this.client});

  @override
  Future<List<VoucherModel>> getVouchers() async {
    final uri = Uri.parse('${ApiConstant.baseUrl}/voucher/customer');
    try {
      final response = await client.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        print("Get All Vouchers Response: $jsonResponse"); // Log yang lebih jelas
        
        // Pastikan 'data' ada dan merupakan sebuah List
        if (jsonResponse['data'] is List) {
          final List<dynamic> data = jsonResponse['data'];
          return data.map((json) => VoucherModel.fromJson(json)).toList();
        } else {
          // Jika API mengembalikan data kosong bukan sebagai list kosong
          return [];
        }
      } else {
        throw ServerException('Gagal mengambil daftar voucher. Kode: ${response.statusCode}');
      }
    } catch (e) {
      // Menangkap error parsing atau koneksi
      throw ServerException(e.toString());
    }
  }

  @override
  Future<VoucherModel> getVoucherById(String id) async {
    final uri = Uri.parse('${ApiConstant.baseUrl}/voucher/$id/customer');
    try {
      final response = await client.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        
        // Asumsi data detail juga ada di dalam key 'data'
        if (jsonResponse['data'] is Map<String, dynamic>) {
           final data = VoucherModel.fromJson(jsonResponse['data']);
           return data;
        } else {
          throw const ServerException('Format data detail voucher tidak valid.');
        }
      } else {
        throw ServerException('Gagal mengambil detail voucher. Kode: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}