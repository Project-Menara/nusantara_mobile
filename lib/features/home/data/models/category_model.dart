import 'package:nusantara_mobile/features/home/domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.image,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Factory constructor untuk membuat instance CategoryModel dari JSON map.
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      // Menggunakan null-coalescing operator (??) untuk keamanan
      id: json['id'] ?? '',
      name: json['name'] ?? 'Tanpa Nama',
      image: json['image'] ?? '',
      status: json['status'] ?? 0,

      // PERBAIKAN: Gunakan key "CreatedAt" dan "UpdatedAt" sesuai JSON
      // dan tambahkan null check sebelum parsing.
      createdAt: json['CreatedAt'] == null
          ? DateTime.now() // Nilai default jika data null
          : DateTime.parse(json['CreatedAt']),
          
      updatedAt: json['UpdatedAt'] == null
          ? DateTime.now() // Nilai default jika data null
          : DateTime.parse(json['UpdatedAt']),
    );
  }
}