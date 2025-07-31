import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nusantara_mobile/features/authentication/data/models/user_model.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/confirm_pin_use_case.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/create_pin_use_case.dart';

part 'pin_event.dart';
part 'pin_state.dart';

class PinBloc extends Bloc<PinEvent, PinState> {
  // === PERUBAHAN: Simpan kedua use case ===
  final CreatePinUseCase _createPinUseCase;
  final ConfirmPinUseCase _confirmPinUseCase;

  PinBloc({
    required CreatePinUseCase createPinUseCase,
    required ConfirmPinUseCase confirmPinUseCase,
  }) : _createPinUseCase = createPinUseCase, // Inisialisasi
       _confirmPinUseCase = confirmPinUseCase, // Inisialisasi
       super(PinInitial()) {
    on<CreatePinSubmitted>(_onCreatePinSubmitted);
    on<ConfirmPinSubmitted>(
      _onConfirmPinSubmitted,
    ); // === TAMBAHAN: Daftarkan handler baru ===
  }

  Future<void> _onCreatePinSubmitted(
    CreatePinSubmitted event,
    Emitter<PinState> emit,
  ) async {
    emit(PinLoading ());
    final result = await _createPinUseCase(
      phoneNumber: event.phoneNumber,
      pin: event.pin,
    );

    result.fold(
      (failure) => emit(PinCreationError(failure.message)),
      (_) => emit( PinCreationSuccess()), // Hapus '(user)' dan 'as UserModel'
    );
  }

  Future<void> _onConfirmPinSubmitted(
    ConfirmPinSubmitted event,
    Emitter<PinState> emit,
  ) async {
    emit(PinLoading ()); // Bisa pakai state loading yang sama

    // PERBAIKAN DI SINI: Panggil use case dengan argumen bernama langsung
    final result = await _confirmPinUseCase(
      phone: event.phoneNumber,
      confirmPin: event.pin,
    );

    result.fold(
      (failure) => emit(PinConfirmationError(failure.message)),
      (user) => emit(
        PinConfirmationSuccess(user as UserModel),
      ), // Keluarkan state sukses dengan data user
    );
  }
}
