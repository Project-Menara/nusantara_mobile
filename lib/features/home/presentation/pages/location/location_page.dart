import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  String _status = "Mencari lokasi...";

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  /// Menentukan posisi saat ini dari perangkat.
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Tes apakah layanan lokasi diaktifkan.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showError("Layanan lokasi tidak diaktifkan. Mohon aktifkan layanan lokasi.");
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showError("Izin lokasi ditolak. Silakan berikan izin di pengaturan.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showError("Izin lokasi ditolak selamanya. Anda tidak dapat menggunakan fitur ini.");
      return;
    }

    setState(() {
      _status = "Mengambil koordinat...";
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _status = "Mengubah koordinat menjadi alamat...";
      });

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      Placemark place = placemarks.first;
      String locationName = "${place.subAdministrativeArea}, ${place.administrativeArea}";
      
      // Mengembalikan nama lokasi ke halaman sebelumnya
      if (mounted) {
        Navigator.pop(context, locationName);
      }
    } catch (e) {
      _showError("Gagal mendapatkan lokasi. Coba lagi.");
    }
  }

  void _showError(String message) {
    if (mounted) {
      setState(() {
        _status = message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pilih Lokasi"),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(_status, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            // Tombol coba lagi jika terjadi error
            if (_status.contains("Gagal") || _status.contains("ditolak"))
              ElevatedButton(
                onPressed: _determinePosition,
                child: const Text("Coba Lagi"),
              ),
          ],
        ),
      ),
    );
  }
}