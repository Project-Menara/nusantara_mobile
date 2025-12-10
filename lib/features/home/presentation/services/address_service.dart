// Lokasi File: lib/features/location/presentation/services/address_service.dart
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:nusantara_mobile/core/constant/api_constant.dart';
import 'package:nusantara_mobile/core/injection_container.dart' as di;
import 'package:nusantara_mobile/features/authentication/data/datasources/local_dataSource.dart';
import 'package:nusantara_mobile/features/home/data/models/address_model.dart';

class AddressService {
  static Future<Map<String, String>> _headers() async {
    final local = di.sl<LocalDatasource>();
    final token = await local.getAuthToken();
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Fetch saved addresses from backend
  static Future<List<AddressModel>> getAddresses() async {
    final client = di.sl<http.Client>();
    final uri = Uri.parse('${ApiConstant.baseUrl}/customer/addresses');
    // DEBUG: log the requested URI
    // ignore: avoid_print
    print('[AddressService] GET $uri');
    final resp = await client.get(uri, headers: await _headers());
    // DEBUG: log status code and body for troubleshooting
    // ignore: avoid_print
    print('[AddressService] Response ${resp.statusCode}: ${resp.body}');

    if (resp.statusCode == 200) {
      final jsonBody = json.decode(resp.body) as Map<String, dynamic>;
      final data = jsonBody['data'];
      if (data is List) {
        return data
            .map((e) => AddressModel.fromMap(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } else {
      // DEBUG: throw with body included to aid debugging
      throw Exception(
        'Failed to load addresses: ${resp.statusCode} - ${resp.body}',
      );
    }
  }

  /// Create a new address on backend
  static Future<void> addAddress(AddressModel newAddress) async {
    final client = di.sl<http.Client>();
    final uri = Uri.parse('${ApiConstant.baseUrl}/customer/addresses/create');
    final payload = <String, dynamic>{
      'label': newAddress.label,
      'address_text': newAddress.alamat,
    };
    if (newAddress.lat != null) {
      payload['lat'] = newAddress.lat;
      payload['latitude'] = newAddress.lat;
    }
    if (newAddress.lang != null) {
      payload['lang'] = newAddress.lang;
      payload['lng'] = newAddress.lang;
      payload['longitude'] = newAddress.lang;
    }

    final body = json.encode(payload);
    // DEBUG: log request details for troubleshooting
    // ignore: avoid_print
    print('[AddressService] POST $uri');
    // ignore: avoid_print
    print('[AddressService] Body: $body');
    final resp = await client.post(uri, headers: await _headers(), body: body);
    // DEBUG: log response
    // ignore: avoid_print
    print('[AddressService] Response ${resp.statusCode}: ${resp.body}');
    if (resp.statusCode == 200 || resp.statusCode == 201) {
      return;
    } else {
      // include body to help debugging
      throw Exception(
        'Failed to create address: ${resp.statusCode} - ${resp.body}',
      );
    }
  }

  /// Update existing address on backend
  static Future<void> updateAddress(AddressModel updatedAddress) async {
    final client = di.sl<http.Client>();
    final uri = Uri.parse(
      '${ApiConstant.baseUrl}/customer/addresses/${updatedAddress.id}/edit',
    );
    final payload = <String, dynamic>{
      'label': updatedAddress.label,
      'address_text': updatedAddress.alamat,
    };
    if (updatedAddress.lat != null) {
      payload['lat'] = updatedAddress.lat;
      payload['latitude'] = updatedAddress.lat;
    }
    if (updatedAddress.lang != null) {
      payload['lang'] = updatedAddress.lang;
      payload['lng'] = updatedAddress.lang;
      payload['longitude'] = updatedAddress.lang;
    }

    final body = json.encode(payload);
    // DEBUG: log request
    // ignore: avoid_print
    print('[AddressService] PUT $uri');
    // ignore: avoid_print
    print('[AddressService] Body: $body');
    final resp = await client.put(uri, headers: await _headers(), body: body);
    // DEBUG: log response
    // ignore: avoid_print
    print('[AddressService] Response ${resp.statusCode}: ${resp.body}');
    if (resp.statusCode == 200) {
      return;
    } else {
      throw Exception(
        'Failed to update address: ${resp.statusCode} - ${resp.body}',
      );
    }
  }

  /// Delete address on backend
  static Future<void> deleteAddress(String id) async {
    final client = di.sl<http.Client>();

    // Try the most likely endpoints in turn. Some backends expect a
    // DELETE on /customer/addresses/{id}, others use a /delete suffix.
    final candidates = [
      Uri.parse('${ApiConstant.baseUrl}/customer/addresses/$id'),
      Uri.parse('${ApiConstant.baseUrl}/customer/addresses/$id/delete'),
    ];

    // Attempt DELETE on each candidate. If we get a non-405 failure, stop
    // and report the response body to help debugging.
    for (final uri in candidates) {
      // DEBUG: log attempt
      // ignore: avoid_print
      print('[AddressService] DELETE $uri');
      final resp = await client.delete(uri, headers: await _headers());
      // DEBUG: log response
      // ignore: avoid_print
      print('[AddressService] Response ${resp.statusCode}: ${resp.body}');

      if (resp.statusCode == 200 || resp.statusCode == 204) {
        return;
      }

      // If server responded with 405 Method Not Allowed, try next candidate.
      if (resp.statusCode == 405) continue;

      // For other errors, include body for easier debugging.
      throw Exception(
        'Failed to delete address: ${resp.statusCode} - ${resp.body}',
      );
    }

    // As a last resort some APIs require POST to a /delete path. Try that
    // to maximize compatibility.
    final postUri = Uri.parse(
      '${ApiConstant.baseUrl}/customer/addresses/$id/delete',
    );
    // ignore: avoid_print
    print('[AddressService] POST $postUri (fallback)');
    final postResp = await client.post(postUri, headers: await _headers());
    // ignore: avoid_print
    print('[AddressService] Response ${postResp.statusCode}: ${postResp.body}');
    if (postResp.statusCode == 200 || postResp.statusCode == 204) return;

    throw Exception(
      'Failed to delete address (all attempts): ${postResp.statusCode} - ${postResp.body}',
    );
  }

  /// Get single address by id
  static Future<AddressModel?> getAddressById(String id) async {
    final client = di.sl<http.Client>();
    final uri = Uri.parse('${ApiConstant.baseUrl}/customer/addresses/$id');
    final resp = await client.get(uri, headers: await _headers());
    if (resp.statusCode == 200) {
      final jsonBody = json.decode(resp.body) as Map<String, dynamic>;
      final data = jsonBody['data'];
      if (data is Map<String, dynamic>) {
        return AddressModel.fromMap(data);
      }
      return null;
    } else {
      throw Exception('Failed to get address: ${resp.statusCode}');
    }
  }

  /// Persist a local-only address (e.g., current location) into SharedPreferences
  static const String _localCurrentKey = 'local_current_address';

  /// Persist the id of the server-selected address so client selection can
  /// survive reloads even if the backend does not store selection state.
  static const String _selectedAddressKey = 'selected_address_id';

  static Future<void> saveLocalCurrentAddress(AddressModel addr) async {
    final local = di.sl<LocalDatasource>();
    final jsonStr = json.encode(addr.toMap());
    await local.saveLocalData(_localCurrentKey, jsonStr);
  }

  static Future<void> saveSelectedAddressId(String id) async {
    final local = di.sl<LocalDatasource>();
    await local.saveLocalData(_selectedAddressKey, id);
  }

  static Future<String?> loadSelectedAddressId() async {
    final local = di.sl<LocalDatasource>();
    final s = await local.getLocalData(_selectedAddressKey);
    if (s == null || s.isEmpty) return null;
    return s;
  }

  static Future<void> clearSelectedAddressId() async {
    final local = di.sl<LocalDatasource>();
    await local.saveLocalData(_selectedAddressKey, '');
  }

  static Future<AddressModel?> loadLocalCurrentAddress() async {
    final local = di.sl<LocalDatasource>();
    final jsonStr = await local.getLocalData(_localCurrentKey);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final map = json.decode(jsonStr) as Map<String, dynamic>;
      return AddressModel.fromMap(map);
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearLocalCurrentAddress() async {
    final local = di.sl<LocalDatasource>();
    await local.saveLocalData(_localCurrentKey, '');
  }
}
