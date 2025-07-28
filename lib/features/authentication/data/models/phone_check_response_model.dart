import 'package:nusantara_mobile/features/authentication/domain/entities/phone_check_entity.dart';

class PhoneCheckResponseModel {
  final int statusCode;
  final String message;
  final String action;

  PhoneCheckResponseModel({
    required this.statusCode,
    required this.message,
    required this.action,
  });

  // Factory constructor untuk membuat objek dari JSON
  factory PhoneCheckResponseModel.fromJson(Map<String, dynamic> json) {
    return PhoneCheckResponseModel(
      statusCode: json['status_code'],
      message: json['message'],
      action: json['data']['action'], // Mengambil 'action' dari dalam 'data'
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'status_code': statusCode,
      'message': message,
      'data': {'action': action},
    };
  }

  // Method untuk mengonversi Model (Data Layer) ke Entity (Domain Layer)
  PhoneCheckEntity toEntity() {
    return PhoneCheckEntity(action: action);
  }
}
