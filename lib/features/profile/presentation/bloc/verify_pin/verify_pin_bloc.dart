
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nusantara_mobile/core/error/failures.dart'; // Sesuaikan path jika perlu
import 'package:nusantara_mobile/features/profile/domain/usecases/verify_pin_usecase.dart';

// Gunakan 'part' untuk menghubungkan file event dan state
part 'verify_pin_event.dart';
part 'verify_pin_state.dart';

class VerifyPinBloc extends Bloc<VerifyPinEvent, VerifyPinState> {
  final VerifyPinUsecase verifyPinUsecase;

  VerifyPinBloc({required this.verifyPinUsecase}) : super(VerifyPinInitial()) {
    // Daftarkan event handler
    on<VerifyPinSubmitted>(_onVerifyPinSubmitted);
  }

  Future<void> _onVerifyPinSubmitted(
    VerifyPinSubmitted event,
    Emitter<VerifyPinState> emit,
  ) async {
    // 1. Emit state Loading
    emit(VerifyPinLoading());

    // 2. Panggil usecase
    final result = await verifyPinUsecase(VerifyPinParams(pin: event.pin));

    // 3. Tangani hasil dari usecase
    result.fold(
      // Jika gagal (kiri)
      (failure) {
        emit(VerifyPinFailure(_mapFailureToMessage(failure)));
      },
      // Jika sukses (kanan)
      (_) {
        emit(VerifyPinSuccess());
      },
    );
  }

  // Fungsi helper untuk memetakan object Failure menjadi String yang bisa dibaca user.
  // Ini mirip dengan MapFailureToMessage pada contoh Anda.
  String _mapFailureToMessage(Failures failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return failure.message;
      case NetworkFailure:
        return 'Tidak ada koneksi internet. Mohon periksa koneksi Anda.';
      default:
        return 'Terjadi kesalahan tak terduga. Silakan coba lagi.';
    }
  }
}
