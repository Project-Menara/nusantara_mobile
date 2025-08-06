// File: features/home/presentation/bloc/category/category_bloc.dart

library category_bloc;

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nusantara_mobile/core/error/map_failure_toMessage.dart';
import 'package:nusantara_mobile/core/usecase/usecase.dart';
import 'package:nusantara_mobile/features/home/domain/entities/category_entity.dart';
// Import yang tidak terpakai dihapus
import 'package:nusantara_mobile/features/home/domain/usecases/category/get_all_category_usecase.dart';
import 'package:nusantara_mobile/features/home/domain/usecases/category/get_category_by_id_usecase.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetAllCategoryUsecase getAllCategoryUsecase;
  final GetCategoryByIdUsecase getCategoryByIdUsecase;

  CategoryBloc({
    required this.getAllCategoryUsecase,
    required this.getCategoryByIdUsecase,
  }) : super(CategoryInitial()) {
    on<GetAllCategoryEvent>(_onGetAllCategory);
    on<GetByIdCategoryEvent>(_onGetByIdCategory);
  }

  Future<void> _onGetAllCategory(
    GetAllCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryAllLoading());
    final result = await getAllCategoryUsecase(NoParams());

    result.fold(
      (failure) => emit(CategoryAllError(MapFailureToMessage.map(failure))),
      (categories) => emit(CategoryAllLoaded(categories: categories)),
    );
  }

  Future<void> _onGetByIdCategory(
    GetByIdCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryByIdLoading());
    // PERBAIKAN: Menghapus 'as Params'. UseCase seharusnya sudah
    // didefinisikan untuk menerima DetailParams secara spesifik.
    final result = await getCategoryByIdUsecase(Params(id: event.id));

    result.fold(
      (failure) => emit(CategoryByIdError(MapFailureToMessage.map(failure))),
      (category) => emit(CategoryByIdLoaded(category: category)),
    );
  }
}