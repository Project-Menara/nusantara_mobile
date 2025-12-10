// Lokasi File: lib/features/location/presentation/bloc/address_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nusantara_mobile/features/home/data/models/address_model.dart';
import 'package:nusantara_mobile/features/home/domain/repositories/address_repository.dart';
import 'package:nusantara_mobile/features/home/presentation/services/address_service.dart';
part 'address_event.dart';
part 'address_state.dart';

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  final AddressRepository _addressRepository;

  AddressBloc({required AddressRepository addressRepository})
    : _addressRepository = addressRepository,
      super(AddressInitial()) {
    on<LoadAddresses>(_onLoadAddresses);
    on<AddAddress>(_onAddAddress);
    on<SetSelectedAddress>(_onSetSelectedAddress);
    on<SelectLocalAddress>(_onSelectLocalAddress);
  }

  void _logAddressLoaded(List<AddressModel> addresses, AddressModel? selected) {
    final labels = addresses.map((a) => a.label).toList();
    // ignore: avoid_print
    print(
      '[AddressBloc] AddressLoaded -> selected: ${selected?.label} (${selected?.id}), addresses: $labels',
    );
  }

  Future<void> _onLoadAddresses(
    LoadAddresses event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressLoading());
    try {
      final addresses = await _addressRepository.getAddresses();

      // Try to load a locally saved 'current location' address (selected via
      // the "Lokasi Saat Ini" flow). If present and not part of the server
      // list, insert it at the front so it's visible and selectable.
      final local = await AddressService.loadLocalCurrentAddress();
      // DEBUG: log persisted items to help diagnose selection flips
      // ignore: avoid_print
      print('[AddressBloc] Loaded local current: ${local?.toJson()}');

      // Normalize selection: server may already mark an address as selected.
      AddressModel? selected;

      // Prefer a persisted selected server id (client-side) if backend
      // doesn't persist selection. This ensures user choice survives
      // reloads.
      final persistedSelectedId = await AddressService.loadSelectedAddressId();
      // ignore: avoid_print
      print('[AddressBloc] Persisted selected id: $persistedSelectedId');

      if (addresses.isNotEmpty) {
        if (persistedSelectedId != null && persistedSelectedId.isNotEmpty) {
          selected = addresses.firstWhere(
            (a) => a.id == persistedSelectedId,
            orElse: () => addresses.first,
          );
        } else {
          selected = addresses.firstWhere(
            (a) => a.isSelected,
            orElse: () => addresses.first,
          );
        }
      }

      // If we have a local-only address, prefer it as selected when there is
      // no server-selected address. Otherwise insert it but keep server
      // selection authoritative.
      if (local != null) {
        final found = addresses.indexWhere((a) => a.id == local.id);
        // If we have a persisted server-selected id, prefer it over a local
        // saved current-location. Local selection should only override when
        // there is no persisted server selection.
        final persistedSelectedId =
            await AddressService.loadSelectedAddressId();

        if (found == -1) {
          // Local-only address (not in server list).
          // Only select it if it was explicitly selected and there's no
          // persisted server-selected id.
          final shouldSelectLocal =
              (local.isSelected == true) && (persistedSelectedId == null);
          local.isSelected = shouldSelectLocal;
          local.isLocal = true;
          if (shouldSelectLocal) selected = local;

          final merged = [
            local,
            ...addresses.map(
              (a) => a
                ..isLocal = false
                ..isSelected = false,
            ),
          ];
          _logAddressLoaded(merged, selected);
          emit(AddressLoaded(addresses: merged, selectedAddress: selected));
          return;
        } else {
          // local matches a server address (IDs equal). Prefer the server's
          // canonical record. Only let the persisted local.isSelected win if
          // there is no persisted server-selected id.
          final merged = addresses.map((a) => a..isLocal = false).toList();

          if ((local.isSelected == true) && (persistedSelectedId == null)) {
            // clear any other server selection and mark this one selected
            for (var a in merged) {
              a.isSelected = false;
            }
            merged[found].isSelected = true;
            selected = merged[found];
          } else {
            // If we previously determined a selected (via persistedSelectedId
            // or server flag), keep it; otherwise default to the found.
            if (selected == null) {
              selected = merged[found];
            }
          }

          _logAddressLoaded(merged, selected);
          emit(AddressLoaded(addresses: merged, selectedAddress: selected));
          return;
        }
      }

      _logAddressLoaded(addresses, selected);
      emit(AddressLoaded(addresses: addresses, selectedAddress: selected));
    } catch (e) {
      // Log error for debugging
      // ignore: avoid_print
      print('[AddressBloc] LoadAddresses failed: $e');
      emit(AddressError("Gagal memuat alamat: $e"));
    }
  }

  Future<void> _onAddAddress(
    AddAddress event,
    Emitter<AddressState> emit,
  ) async {
    await _addressRepository.addAddress(event.address);
    add(LoadAddresses()); // Muat ulang semua alamat setelah menambah
  }

  Future<void> _onSetSelectedAddress(
    SetSelectedAddress event,
    Emitter<AddressState> emit,
  ) async {
    // Check if this is a local address - if so, don't call API
    if (event.address.isLocal) {
      // For local addresses, just update local storage and emit state
      await AddressService.saveLocalCurrentAddress(event.address);
      add(LoadAddresses()); // Reload to update UI
    } else {
      // For server addresses, attempt to update the server selection and
      // immediately update the client state so the UI reflects the user's
      // choice. Also clear any persisted local 'current location' so it
      // won't re-assert as selected during the next load.
      try {
        await _addressRepository.setSelectedAddress(event.address.id);
        // Persisted local address should not override an explicit server
        // selection anymore.
        await AddressService.clearLocalCurrentAddress();
        // Persist the selected server id so choice survives reloads.
        await AddressService.saveSelectedAddressId(event.address.id);
        // DEBUG
        // ignore: avoid_print
        print(
          '[AddressBloc] Selected server address saved: ${event.address.id}',
        );

        // Fetch fresh server list and mark the chosen one selected so the
        // UI shows the change immediately.
        final addresses = await _addressRepository.getAddresses();
        final merged = addresses
            .map(
              (a) => a
                ..isLocal = false
                ..isSelected = (a.id == event.address.id),
            )
            .toList();

        final selected = merged.isNotEmpty
            ? merged.firstWhere((a) => a.isSelected, orElse: () => merged.first)
            : null;

        _logAddressLoaded(merged, selected);
        emit(AddressLoaded(addresses: merged, selectedAddress: selected));
        return;
      } catch (e) {
        // If server update failed, try to at least reflect user's selection
        // locally (optimistic fallback) so the UI doesn't remain stuck.
        // ignore: avoid_print
        print('[AddressBloc] SetSelectedAddress failed: $e');
        try {
          final addresses = await _addressRepository.getAddresses();
          final merged = addresses
              .map(
                (a) => a
                  ..isLocal = false
                  ..isSelected = (a.id == event.address.id),
              )
              .toList();

          final selected = merged.isNotEmpty
              ? merged.firstWhere(
                  (a) => a.isSelected,
                  orElse: () => merged.first,
                )
              : null;

          // Don't clear local since server failed, but emit the updated list
          // and persist selected id locally as an optimistic fallback.
          await AddressService.saveSelectedAddressId(event.address.id);
          // DEBUG
          // ignore: avoid_print
          print(
            '[AddressBloc] Fallback saved selected id locally: ${event.address.id}',
          );
          _logAddressLoaded(merged, selected);
          emit(AddressLoaded(addresses: merged, selectedAddress: selected));
          return;
        } catch (e2) {
          // ignore: avoid_print
          print('[AddressBloc] Fallback after SetSelectedAddress failed: $e2');
        }
      }
      // As a last resort, trigger a full reload which will apply existing
      // selection rules in _onLoadAddresses.
      add(LoadAddresses());
    }
  }

  Future<void> _onSelectLocalAddress(
    SelectLocalAddress event,
    Emitter<AddressState> emit,
  ) async {
    // SelectLocalAddress is PURELY local - never hits API
    // Just load server addresses to merge with local, but don't call any server endpoints
    try {
      final addresses = await _addressRepository.getAddresses();

      // Ensure the event address is marked as local and selected
      event.address.isLocal = true;
      event.address.isSelected = true;

      // Mark all server addresses as not selected and not local
      final serverAddresses = addresses
          .map(
            (a) => a
              ..isLocal = false
              ..isSelected = false,
          )
          .toList();

      // Create list with local address at front
      final newList = [event.address, ...serverAddresses];

      // Persist ONLY to local storage - NO API calls
      await AddressService.saveLocalCurrentAddress(event.address);
      // Clear any persisted server-selected id because user explicitly
      // chose a local current-location.
      await AddressService.clearSelectedAddressId();
      // DEBUG
      // ignore: avoid_print
      print(
        '[AddressBloc] SelectLocalAddress saved and cleared server-selected id',
      );

      _logAddressLoaded(newList, event.address);
      emit(AddressLoaded(addresses: newList, selectedAddress: event.address));
    } catch (e) {
      // fallback: emit error
      // ignore: avoid_print
      print('[AddressBloc] SelectLocalAddress failed: $e');
      emit(AddressError('Gagal memilih alamat: $e'));
    }
  }
}
