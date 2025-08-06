// File: features/home/presentation/bloc/category/_category_state.dart

part of 'category_bloc.dart';

abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object?> get props => [];
}

/// State awal sebelum ada event yang dieksekusi.
class CategoryInitial extends CategoryState {}

// --- States untuk 'GetAllCategories' ---

/// State ketika sedang mengambil semua kategori.
class CategoryAllLoading extends CategoryState {}

/// State ketika semua kategori berhasil didapatkan.
class CategoryAllLoaded extends CategoryState {
  final List<CategoryEntity> categories;

  const CategoryAllLoaded({required this.categories});

  @override
  List<Object?> get props => [categories];
}

/// State ketika terjadi kesalahan saat mengambil semua kategori.
class CategoryAllError extends CategoryState {
  final String message;

  const CategoryAllError(this.message);

  @override
  List<Object?> get props => [message];
}

// --- States untuk 'GetCategoryById' ---

/// State ketika sedang mengambil detail kategori.
class CategoryByIdLoading extends CategoryState {}

/// State ketika detail kategori berhasil didapatkan.
class CategoryByIdLoaded extends CategoryState {
  final CategoryEntity category;

  const CategoryByIdLoaded({required this.category});

  @override
  List<Object?> get props => [category];
}

/// State ketika terjadi kesalahan saat mengambil detail kategori.
class CategoryByIdError extends CategoryState {
  final String message;

  const CategoryByIdError(this.message);

  @override
  List<Object?> get props => [message];
}