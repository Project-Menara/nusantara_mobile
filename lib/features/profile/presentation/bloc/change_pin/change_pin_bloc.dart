import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nusantara_mobile/features/authentication/domain/entities/user_entity.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_event.dart';
import 'package:nusantara_mobile/features/profile/domain/usecases/confirm_new_pin_usecase.dart';
import 'package:nusantara_mobile/features/profile/domain/usecases/create_new_pin_usecase.dart';

part 'change_pin_event.dart';
part 'change_pin_state.dart';

class ChangePinBloc extends Bloc<ChangePinEvent, ChangePinState> {
  final CreateNewPinUseCase createNewPinUseCase;
  final ConfirmNewPinUseCase confirmNewPinUseCase;
  final AuthBloc authBloc; // Untuk komunikasi antar BLoC

  ChangePinBloc({
    required this.createNewPinUseCase,
    required this.confirmNewPinUseCase,
    required this.authBloc,
  }) : super(ChangePinInitial()) {
    on<CreatePinSubmitted>(_onCreatePinSubmitted);
    on<ConfirmPinSubmitted>(_onConfirmPinSubmitted);
  }

  Future<void> _onCreatePinSubmitted(
    CreatePinSubmitted event,
    Emitter<ChangePinState> emit,
  ) async {
    emit(CreatePinLoading());
    final params = CreatePinParams(newPin: event.newPin);
    final result = await createNewPinUseCase(params);

    result.fold(
      (failure) => emit(CreatePinFailure(failure.message)),
      (_) => emit(CreatePinSuccess()),
    );
  }

  Future<void> _onConfirmPinSubmitted(
    ConfirmPinSubmitted event,
    Emitter<ChangePinState> emit,
  ) async {
    emit(ConfirmPinLoading());
    final params = ConfirmPinParams(confirmPin: event.confirmPin);
    final result = await confirmNewPinUseCase(params);

    result.fold(
      (failure) => emit(ConfirmPinFailure(failure.message)),
      (updatedUser) {
        // Jika sukses, emit state sukses
        emit(ConfirmPinSuccess(updatedUser));
        // Dan beri tahu AuthBloc bahwa data user telah diperbarui
        authBloc.add(AuthUserUpdated(updatedUser));
      },
    );
  }
}