import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nusantara_mobile/routes/initial_routes.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_state.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:nusantara_mobile/features/home/data/models/address_model.dart';
import 'package:nusantara_mobile/features/home/presentation/bloc/adress/address_bloc.dart';
import 'package:nusantara_mobile/features/home/presentation/pages/location/add_edit_address_page.dart';
import 'package:nusantara_mobile/features/home/presentation/services/address_service.dart';
// geolocator/http/convert imports removed because current-location UI was removed

class LocationPage extends StatelessWidget {
  const LocationPage({super.key});

  Future<bool?> _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String label,
    required String alamat,
    required String confirmText,
    required Color confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text(
                alamat,
                style: TextStyle(color: Colors.grey[700]),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmColor,
                    ),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text(
                      confirmText,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If user is not authenticated, redirect to login
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthUnauthenticated) {
      // navigate to login and close this page
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(InitialRoutes.loginScreen);
      });
      return const SizedBox.shrink();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pilih Lokasi",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: BlocBuilder<AddressBloc, AddressState>(
        builder: (context, state) {
          if (state is AddressLoading || state is AddressInitial) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
            );
          }

          if (state is AddressError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<AddressBloc>().add(LoadAddresses()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Coba Lagi"),
                  ),
                ],
              ),
            );
          }

          if (state is AddressLoaded) {
            // Only show server-backed addresses on this page. Local-only
            // 'Lokasi Saat Ini' entries are handled from the SelectAddress
            // page and should not appear here to avoid redundancy.
            final serverAddresses = state.addresses
                .where((a) => !a.isLocal)
                .toList();
            if (serverAddresses.isEmpty) return _buildEmptyState(context);

            return RefreshIndicator(
              onRefresh: () async {
                context.read<AddressBloc>().add(LoadAddresses());
              },
              color: Colors.orange,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: serverAddresses.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final address = serverAddresses[index];
                  return _buildAddressCard(
                    context,
                    address,
                    state.selectedAddress?.id == address.id,
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => AddEditAddressPage(),
          ),
        ),
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildAddressCard(
    BuildContext context,
    AddressModel address,
    bool isSelected,
  ) {
    // Different colors for local vs server addresses
    final isLocalAddress = address.isLocal;
    final primaryColor = isLocalAddress ? Colors.blue : Colors.orange;
    final backgroundColor = isLocalAddress
        ? Colors.blue.withOpacity(0.1)
        : Colors.orange.withOpacity(0.1);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: primaryColor, width: 2.0)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final confirmed = await _showConfirmDialog(
            context,
            title: 'Pilih Lokasi',
            label: address.label,
            alamat: address.alamat,
            confirmText: 'Pilih',
            confirmColor: primaryColor,
          );

          if (confirmed == true) {
            // Use different events based on address type
            if (address.isLocal) {
              context.read<AddressBloc>().add(SelectLocalAddress(address));
            } else {
              context.read<AddressBloc>().add(SetSelectedAddress(address));
            }
            context.pop();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? backgroundColor
                      : Colors.grey.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  // Different icons for local vs server addresses
                  isLocalAddress ? Icons.my_location : Icons.location_on,
                  color: isSelected ? primaryColor : Colors.grey,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            address.label,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: isSelected ? primaryColor : Colors.black,
                            ),
                          ),
                        ),
                        if (isSelected && isLocalAddress)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'AKTIF',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        else if (isSelected)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'AKTIF',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (address.isLocal)
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.blue.withOpacity(0.3),
                              ),
                            ),
                            child: const Text(
                              'Lokasi Saat Ini',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.orange.withOpacity(0.3),
                              ),
                            ),
                            child: const Text(
                              'Alamat Tersimpan',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    const SizedBox(height: 4),
                    Text(
                      address.alamat,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: primaryColor, size: 24),
              // Edit button - disabled for local addresses
              if (!address.isLocal)
                IconButton(
                  icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                  onPressed: () async {
                    // Open edit page with existing address as a fullscreen dialog on root navigator
                    await Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (context) =>
                            AddEditAddressPage(addressToEdit: address),
                      ),
                    );
                    // After returning, refresh addresses
                    context.read<AddressBloc>().add(LoadAddresses());
                  },
                ),
              // Delete button - different behavior for local vs server addresses
              IconButton(
                icon: Icon(
                  address.isLocal ? Icons.clear : Icons.delete_outline,
                  size: 20,
                  color: Colors.redAccent,
                ),
                onPressed: () async {
                  final title = address.isLocal
                      ? 'Hapus Lokasi Saat Ini'
                      : 'Hapus Alamat';
                  final confirmed = await _showConfirmDialog(
                    context,
                    title: title,
                    label: address.label,
                    alamat: address.alamat,
                    confirmText: 'Hapus',
                    confirmColor: Colors.redAccent,
                  );

                  if (confirmed == true) {
                    try {
                      if (address.isLocal) {
                        // For local addresses, just clear from SharedPreferences
                        await AddressService.clearLocalCurrentAddress();
                        context.read<AddressBloc>().add(LoadAddresses());
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Lokasi saat ini dihapus'),
                          ),
                        );
                      } else {
                        // For server addresses, delete via API
                        await AddressService.deleteAddress(address.id);
                        context.read<AddressBloc>().add(LoadAddresses());
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Alamat dihapus')),
                        );
                      }
                    } catch (e, st) {
                      // Log error and show a friendly message instead of
                      // letting the exception crash the app.
                      // ignore: avoid_print
                      print('[LocationPage] delete error: $e');
                      // ignore: avoid_print
                      print(st);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal menghapus alamat: $e')),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/empty_location.png', // Ganti dengan asset Anda
              width: 150,
              height: 150,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            const Text(
              "Belum Ada Alamat",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Anda belum menambahkan alamat apapun. Yuk, tambahkan alamat pertama Anda!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (context) => AddEditAddressPage(),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Tambah Alamat Pertama"),
            ),
          ],
        ),
      ),
    );
  }
}

// Note: Current-location tile removed per UX decision to avoid redundancy.
