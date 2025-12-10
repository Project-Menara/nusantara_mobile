// Lokasi File: lib/features/location/presentation/bloc/address_state.dart
part of 'address_bloc.dart';

abstract class AddressState extends Equatable {
  const AddressState();
  @override
  List<Object> get props => [];
}

class AddressInitial extends AddressState {}
class AddressLoading extends AddressState {}

class AddressLoaded extends AddressState {
  final List<AddressModel> addresses;
  final AddressModel? selectedAddress;

  const AddressLoaded({required this.addresses, this.selectedAddress});

  @override
  List<Object> get props => [addresses, selectedAddress ?? ''];
}

class AddressError extends AddressState {
  final String message;
  const AddressError(this.message);
  @override
  List<Object> get props => [message];
}