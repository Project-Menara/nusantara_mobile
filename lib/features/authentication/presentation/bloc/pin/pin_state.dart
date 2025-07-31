part of 'pin_bloc.dart';

// Import UserModel karena akan digunakan di state sukses

abstract class PinState extends Equatable {
  const PinState();

  @override
  List<Object> get props => [];
}

class PinInitial extends PinState {}

class PinLoading  extends PinState {}

class PinCreationSuccess extends PinState {} // Jadikan class kosong


class PinCreationError extends PinState {
  final String message;

  const PinCreationError(this.message);

  @override
  List<Object> get props => [message];
}

// === TAMBAHAN STATE UNTUK HASIL KONFIRMASI PIN ===
class PinConfirmationSuccess extends PinState {
  final UserModel user; // Membawa data user setelah login berhasil

  const PinConfirmationSuccess(this.user);

  @override
  List<Object> get props => [user];
}

class PinConfirmationError extends PinState {
  final String message;

  const PinConfirmationError(this.message);

  @override
  List<Object> get props => [message];
}

