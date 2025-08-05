// lib/features/profile/presentation/bloc/verify_pin/verify_pin_state.dart

part of 'verify_pin_bloc.dart';

abstract class VerifyPinState extends Equatable {
  const VerifyPinState();

  @override
  List<Object> get props => [];
}

/// State awal, sebelum ada aksi apa pun.
class VerifyPinInitial extends VerifyPinState {}

/// State ketika proses verifikasi sedang dikirim ke server.
/// UI harus menampilkan loading indicator.
class VerifyPinLoading extends VerifyPinState {}

/// State ketika verifikasi PIN berhasil.
/// UI bisa melakukan navigasi atau menampilkan pesan sukses.
class VerifyPinSuccess extends VerifyPinState {}

/// State ketika verifikasi PIN gagal.
/// UI harus menampilkan pesan error yang dibawa oleh state ini.
class VerifyPinFailure extends VerifyPinState {
  final String message;

  const VerifyPinFailure(this.message);

  @override
  List<Object> get props => [message];
}