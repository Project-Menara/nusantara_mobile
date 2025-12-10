class CategoryEntity {
  final String id;
  final String name;
  final String image;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.image,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  List<Object?> get props => [id, name, image, status];
}
