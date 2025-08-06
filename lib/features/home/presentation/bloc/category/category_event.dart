
part of 'category_bloc.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

/// Event untuk memicu pengambilan semua data kategori.
class GetAllCategoryEvent extends CategoryEvent {}

/// Event untuk memicu pengambilan data kategori berdasarkan ID-nya.
class GetByIdCategoryEvent extends CategoryEvent {
  final String id;

  const GetByIdCategoryEvent(this.id);

  @override
  List<Object?> get props => [id];
}