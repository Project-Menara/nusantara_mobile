import 'package:flutter/material.dart';
import 'package:nusantara_mobile/features/home/presentation/pages/location/location_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nusantara_mobile/features/home/presentation/bloc/adress/address_bloc.dart';
import 'package:nusantara_mobile/features/home/data/models/address_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'dart:convert';
import 'package:http/http.dart' as http;

class SelectAddressPage extends StatefulWidget {
  const SelectAddressPage({super.key});

  @override
  State<SelectAddressPage> createState() => _SelectAddressPageState();
}

class _SelectAddressPageState extends State<SelectAddressPage> {
  // State untuk mengelola loading indicator
  bool _isDetectingLocation = false;

  void _openSavedAddresses() async {
    // Navigasi ke halaman untuk memilih dari alamat yang tersimpan
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const LocationPage(),
      ),
    );
  }

  Future<void> _useCurrentLocation() async {
    // Mencegah klik ganda saat sedang proses
    if (_isDetectingLocation) return;

    final scaffold = ScaffoldMessenger.of(context);
    setState(() {
      _isDetectingLocation = true;
    });

    try {
      // 1. Cek & Minta Izin Lokasi
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        scaffold.showSnackBar(
          const SnackBar(
            content: Text('Izin lokasi ditolak untuk mengakses fitur ini.'),
          ),
        );
        return;
      }

      // 2. Dapatkan Posisi Saat Ini
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 3. Konversi Koordinat menjadi Alamat (Reverse Geocoding)
      // Use higher precision for the coordinate fallback display so user sees
      // the most accurate position available. The stored numeric values are
      // still the full double precision (we only format the string here).
      String addressText =
          'Koordinat: ${pos.latitude.toStringAsFixed(7)}, ${pos.longitude.toStringAsFixed(7)}';
      try {
        final placemarks = await geocoding.placemarkFromCoordinates(
          pos.latitude,
          pos.longitude,
        );
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          // Sertakan nama tempat/POI jika tersedia (mis. nama gedung atau area)
          String? name;
          if (p.name != null && p.name!.trim().isNotEmpty) {
            name = p.name!.trim();
          }

          // Prioritaskan menampilkan jalan (street) dan beri prefix 'Jalan' jika perlu
          String? street;
          if (p.street != null && p.street!.trim().isNotEmpty) {
            final s = p.street!.trim();
            // Jika nama tempat sama dengan nama jalan, jangan duplikasi
            if (name != null && name == s) {
              street = s;
            } else {
              street = s.toLowerCase().startsWith('jalan') ? s : 'Jalan $s';
            }
          }

          // Menggabungkan bagian alamat yang relevan menjadi satu string yang rapi
          final composed = [
            name,
            street,
            p.subLocality,
            p.locality,
            p.subAdministrativeArea,
            p.administrativeArea,
            p.postalCode,
          ].where((s) => s != null && s.isNotEmpty).join(', ');

          if (composed.isNotEmpty) {
            addressText = composed;
          }
        }
      } catch (_) {
        // Jika gagal, we'll try an HTTP reverse-geocode fallback below
      }

      // If addressText still looks like coordinates, try Nominatim reverse as a fallback
      if (addressText.startsWith('Koordinat:')) {
        try {
          final url =
              'https://nominatim.openstreetmap.org/reverse?format=json&lat=${pos.latitude}&lon=${pos.longitude}&zoom=18&addressdetails=1';
          final resp = await http.get(
            Uri.parse(url),
            headers: {
              'User-Agent':
                  'nusantara_mobile/1.0 (contact: support@example.com)',
              'Accept-Language': 'id',
            },
          );
          if (resp.statusCode == 200) {
            final data = jsonDecode(resp.body);
            final display = data is Map && data['display_name'] != null
                ? data['display_name'].toString()
                : null;
            if (display != null && display.trim().isNotEmpty) {
              addressText = display;
            } else if (data is Map && data['address'] is Map) {
              final addr = Map<String, dynamic>.from(data['address']);
              final parts = <String>[];
              void addIf(String? v) {
                if (v != null && v.trim().isNotEmpty) parts.add(v.trim());
              }

              addIf(addr['road']?.toString());
              addIf(addr['suburb']?.toString());
              addIf(
                addr['city']?.toString() ??
                    addr['town']?.toString() ??
                    addr['village']?.toString(),
              );
              addIf(addr['state']?.toString());
              addIf(addr['postcode']?.toString());
              if (parts.isNotEmpty) addressText = parts.join(', ');
            }
          }
        } catch (_) {
          // ignore
        }
      }

      // 4. Buat Model Alamat Lokal
      final localAddress = AddressModel(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        label: 'Lokasi Saat Ini',
        alamat: addressText,
        lat: pos.latitude,
        lang: pos.longitude,
        isLocal: true,
        isSelected: true,
      );

      // 5. Kirim event ke BLoC dan tutup halaman
      if (!mounted) return;
      context.read<AddressBloc>().add(SelectLocalAddress(localAddress));
      Navigator.of(context).pop();
    } catch (e) {
      scaffold.showSnackBar(
        SnackBar(content: Text('Gagal mendapatkan lokasi: ${e.toString()}')),
      );
    } finally {
      // Pastikan state loading selalu kembali ke false
      if (mounted) {
        setState(() {
          _isDetectingLocation = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Definisikan warna tema agar konsisten
    const Color primaryColor = Colors.orange;
    // final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.grey[100], // Latar belakang sedikit abu-abu
      appBar: AppBar(
        title: const Text(
          'Pilih Alamat Pengiriman',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<AddressBloc, AddressState>(
          builder: (context, state) {
            AddressModel? selectedAddress;
            if (state is AddressLoaded) {
              selectedAddress = state.selectedAddress;
            }

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min, // Membuat Column hanya setinggi kontennya
                children: [
                  // Opsi 1: Pilih dari Alamat Tersimpan
                  _buildAddressOption(
                    icon: Icons.place_outlined,
                    title: 'Pilih dari Alamat Tersimpan',
                    subtitle:
                        (selectedAddress != null && !selectedAddress.isLocal)
                        ? 'Terpilih: ${selectedAddress.label}'
                        : 'Lihat semua alamat Anda',
                    onTap: _openSavedAddresses,
                    isSelected:
                        selectedAddress != null && !selectedAddress.isLocal,
                    color: primaryColor,
                  ),

                  // Garis pemisah
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Divider(height: 1, color: Colors.grey[200]),
                  ),

                  // Opsi 2: Gunakan Lokasi Saat Ini
                  _buildAddressOption(
                    icon: Icons.my_location,
                    title: 'Gunakan Lokasi Saat Ini',
                    subtitle:
                        (selectedAddress != null &&
                            selectedAddress.isLocal &&
                            selectedAddress.alamat.isNotEmpty)
                        ? selectedAddress.alamat
                        : 'Deteksi otomatis via GPS',
                    onTap: _useCurrentLocation,
                    isSelected:
                        selectedAddress != null && selectedAddress.isLocal,
                    isLoading: _isDetectingLocation,
                    color: Colors.blueAccent, // Warna berbeda untuk membedakan
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Widget helper untuk membangun setiap baris opsi alamat
  Widget _buildAddressOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isSelected = false,
    bool isLoading = false,
    Color color = Colors.orange,
  }) {
    return InkWell(
      onTap: isLoading ? null : onTap, // Nonaktifkan tap saat loading
      borderRadius: BorderRadius.circular(12.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Row(
          children: [
            // Icon di sebelah kiri
            isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  )
                : Icon(icon, color: color, size: 28),
            const SizedBox(width: 16),
            // Teks Title dan Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Indikator terpilih (check circle)
            if (isSelected)
              Icon(Icons.check_circle, color: color)
            else
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }
}
