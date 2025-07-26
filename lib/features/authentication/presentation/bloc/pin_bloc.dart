import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/confirm_pin_use_case.dart';
import 'package:nusantara_mobile/features/authentication/domain/usecases/create_pin_use_case.dart'; // Pastikan path ini benar

part 'pin_event.dart';
part 'pin_state.dart';

class PinBloc extends Bloc<PinEvent, PinState> {
  final CreatePinUseCase createPinUseCase;

  PinBloc({
    required this.createPinUseCase,
    required ConfirmPinUseCase confirmPinUseCase,
  }) : super(PinInitial()) {
    on<CreatePinSubmitted>(_onCreatePinSubmitted);
  }

  Future<void> _onCreatePinSubmitted(
    CreatePinSubmitted event,
    Emitter<PinState> emit,
  ) async {
    emit(PinCreationLoading());
    final result = await createPinUseCase(
      phoneNumber: event.phoneNumber,
      pin: event.pin,
    );

    result.fold(
      (failure) => emit(PinCreationFailure(failure.message)),
      (_) => emit(PinCreationSuccess()),
    );
  }
}

class ConfirmPinSubmitted extends PinEvent {
  final String phoneNumber;
  final String confirmPin;

  const ConfirmPinSubmitted({
    required this.phoneNumber,
    required this.confirmPin,
  });
}
