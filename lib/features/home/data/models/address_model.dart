// Lokasi File: lib/features/location/domain/entities/address_model.dart
import 'dart:convert';

class AddressModel {
  final String id;
  final String label;
  // Single address string (jalan). Replaces previous fullAddress/street/lat storage.
  final String alamat;
  final double? lat;
  final double? lang;
  bool isSelected;
  // Marks an address that is saved locally as the device's "current location".
  // This field is for client-side UI only and is not sent to the backend.
  bool isLocal;

  AddressModel({
    required this.id,
    required this.label,
    required this.alamat,
    this.lat,
    this.lang,
    this.isSelected = false,
    this.isLocal = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'label': label,
    'alamat': alamat,
    // include API-friendly key for sending to backend
    'address_text': alamat,
    'lat': lat,
    'latitude': lat,
    // legacy/alternate names for longitude
    'lang': lang,
    'lng': lang,
    'longitude': lang,
    'isSelected': isSelected,
  };

  factory AddressModel.fromMap(Map<String, dynamic> map) => AddressModel(
    id: map['id'] ?? '',
    label: map['label'] ?? '',
    // Migration-friendly: prefer 'alamat', fall back to legacy keys.
    alamat:
        map['alamat'] ??
        map['address_text'] ??
        map['fullAddress'] ??
        map['street'] ??
        map['address'] ??
        '',
    // try to parse lat/lang from different possible keys
    lat: () {
      try {
        final v =
            map['lat'] ??
            map['latitude'] ??
            map['latitud'] ??
            map['latitude_value'];
        if (v == null) return null;
        if (v is num) return v.toDouble();
        return double.tryParse(v.toString());
      } catch (_) {
        return null;
      }
    }(),
    lang: () {
      try {
        final v = map['lang'] ?? map['longitude'] ?? map['long'] ?? map['lng'];
        if (v == null) return null;
        if (v is num) return v.toDouble();
        return double.tryParse(v.toString());
      } catch (_) {
        return null;
      }
    }(),
    // API may use is_default; legacy clients used isSelected
    isSelected: map['isSelected'] ?? map['is_default'] ?? false,
  );

  String toJson() => json.encode(toMap());

  factory AddressModel.fromJson(String source) =>
      AddressModel.fromMap(json.decode(source));
}
