// Lokasi File: lib/features/location/data/repositories/address_repository.dart
import 'package:nusantara_mobile/features/home/data/models/address_model.dart';
import 'package:nusantara_mobile/features/home/presentation/services/address_service.dart';

class AddressRepository {
  Future<List<AddressModel>> getAddresses() async {
    return await AddressService.getAddresses();
  }

  Future<void> addAddress(AddressModel newAddress) async {
    return await AddressService.addAddress(newAddress);
  }

  Future<void> setSelectedAddress(String addressId) async {
    // Backend may not provide a dedicated endpoint for selecting the address.
    // Implement by fetching addresses and updating selection locally then
    // calling updateAddress for the affected addresses if needed. For now,
    // we'll rely on client-side selection via LoadAddresses and use the
    // updateAddress endpoint for updates where required.
    final addresses = await getAddresses();
    for (final addr in addresses) {
      if (addr.id == addressId) {
        addr.isSelected = true;
      } else {
        addr.isSelected = false;
      }
    }
    // Push updates for changed addresses (best-effort)
    for (final addr in addresses) {
      await AddressService.updateAddress(addr);
    }
  }

  Future<void> updateAddress(AddressModel updated) async {
    return await AddressService.updateAddress(updated);
  }

  Future<void> deleteAddress(String id) async {
    return await AddressService.deleteAddress(id);
  }

  Future<AddressModel?> getAddressById(String id) async {
    return await AddressService.getAddressById(id);
  }
}
