// Lokasi File: lib/features/location/presentation/bloc/address_event.dart
part of 'address_bloc.dart';

abstract class AddressEvent extends Equatable {
  const AddressEvent();
  @override
  List<Object> get props => [];
}

// Event untuk memuat semua alamat yang tersimpan
class LoadAddresses extends AddressEvent {}

// Event untuk menambah alamat baru
class AddAddress extends AddressEvent {
  final AddressModel address;
  const AddAddress(this.address);
  @override
  List<Object> get props => [address];
}

// Event for selecting an address locally without creating it on backend.
class SelectLocalAddress extends AddressEvent {
  final AddressModel address;
  const SelectLocalAddress(this.address);
  @override
  List<Object> get props => [address];
}

// Event untuk menetapkan alamat yang dipilih
class SetSelectedAddress extends AddressEvent {
  final AddressModel address;
  const SetSelectedAddress(this.address);
  @override
  List<Object> get props => [address];
}
