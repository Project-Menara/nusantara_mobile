import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:nusantara_mobile/features/home/data/models/address_model.dart';
import 'package:nusantara_mobile/features/home/presentation/services/address_service.dart';
import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nusantara_mobile/features/home/presentation/bloc/adress/address_bloc.dart';

class AddEditAddressPage extends StatefulWidget {
  final AddressModel? addressToEdit;

  const AddEditAddressPage({super.key, this.addressToEdit});

  @override
  State<AddEditAddressPage> createState() => _AddEditAddressPageState();
}

class _AddEditAddressPageState extends State<AddEditAddressPage> {
  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  String? _selectedLabelOption;
  bool _isCustomLabel = false;
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();
  final FocusNode _searchFocusNode = FocusNode();

  LatLng? _selectedLocation;
  LatLng? _initialPosition;
  final ValueNotifier<String> _currentAddress = ValueNotifier(
    "Klik pada peta untuk memilih lokasi...",
  );
  bool _isLoading = false;
  bool _isSearching = false;
  final ValueNotifier<bool> _isGettingAddress = ValueNotifier(false);
  List<dynamic> _searchResults = [];

  // Variabel untuk debounce
  Timer? _debounceTimer;
  final Duration _debounceDelay = const Duration(milliseconds: 500);

  // Cache untuk hasil pencarian
  final Map<String, List<dynamic>> _searchCache = {};

  static const LatLng _kFallbackPosition = LatLng(-6.2088, 106.8456);

  @override
  void initState() {
    super.initState();
    // If editing an existing address, prefill fields and try to center map
    if (widget.addressToEdit != null) {
      // Prefill label: if matches one of our known options, select it,
      // otherwise mark as custom and put it to the manual controller.
      final existingLabel = widget.addressToEdit!.label;
      const known = ['Rumah', 'Kantor', 'Kos'];
      if (known.contains(existingLabel)) {
        _selectedLabelOption = existingLabel;
        _isCustomLabel = false;
        _labelController.text = existingLabel;
      } else {
        _selectedLabelOption = 'Lainnya';
        _isCustomLabel = true;
        _labelController.text = existingLabel;
      }
      _alamatController.text = widget.addressToEdit!.alamat;
      // Try to geocode the stored alamat to center the map
      if (widget.addressToEdit!.alamat.isNotEmpty) {
        _geocodeAddress(widget.addressToEdit!.alamat);
      } else {
        _determinePosition();
      }
    } else {
      // default label option
      _selectedLabelOption = 'Rumah';
      _determinePosition();
    }
    _mapController.mapEventStream.listen((event) {
      if (event is MapEventMoveEnd) {
        _updateSelectedLocation(_mapController.camera.center);
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _labelController.dispose();
    _alamatController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _currentAddress.dispose();
    _isGettingAddress.dispose();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Aktifkan GPS untuk melanjutkan")),
      );
      setState(() {
        _initialPosition = _kFallbackPosition;
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _initialPosition = _kFallbackPosition;
        });
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _initialPosition = _kFallbackPosition;
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
      _selectedLocation = _initialPosition;
    });

    _mapController.move(_initialPosition!, 15.0);

    // Dapatkan alamat dari koordinat
    _getAddressFromLatLng(_initialPosition!);
  }

  // Fungsi untuk mendapatkan alamat dari koordinat (reverse geocoding)
  Future<void> _getAddressFromLatLng(LatLng position) async {
    _isGettingAddress.value = true;

    try {
      final url =
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&zoom=18&addressdetails=1';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'nusantara_mobile/1.0 (contact: support@example.com)',
          'Accept-Language': 'id',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String? displayName = (data is Map && data['display_name'] != null)
            ? data['display_name'].toString()
            : null;

        if ((displayName == null || displayName.trim().isEmpty) &&
            data is Map &&
            data['address'] is Map) {
          final addr = Map<String, dynamic>.from(data['address']);
          final parts = <String>[];
          void addIf(String? v) {
            if (v != null && v.trim().isNotEmpty) parts.add(v.trim());
          }

          addIf(addr['house_number']?.toString());
          addIf(addr['road']?.toString());
          addIf(addr['suburb']?.toString());
          addIf(
            addr['city']?.toString() ??
                addr['town']?.toString() ??
                addr['village']?.toString(),
          );
          addIf(addr['state']?.toString());
          addIf(addr['postcode']?.toString());
          addIf(addr['country']?.toString());
          if (parts.isNotEmpty) displayName = parts.join(', ');
        }

        if (displayName != null && displayName.trim().isNotEmpty) {
          _currentAddress.value = displayName;
          _alamatController.text = displayName;
        } else {
          // If we already have an editable alamat, keep it instead of showing an error.
          final existing = _alamatController.text.trim();
          if (existing.isNotEmpty) {
            _currentAddress.value = existing;
          } else {
            _currentAddress.value = 'Alamat tidak dapat diidentifikasi';
            if (mounted)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Alamat tidak ditemukan. Silakan isi manual atau pilih lokasi lain.',
                  ),
                ),
              );
          }
        }
      } else {
        final existing = _alamatController.text.trim();
        if (existing.isNotEmpty) {
          _currentAddress.value = existing;
        } else {
          _currentAddress.value = 'Alamat tidak dapat diidentifikasi';
          if (mounted)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Gagal mengambil alamat. Silakan isi manual atau coba lagi.',
                ),
              ),
            );
        }
      }
    } catch (e) {
      final existing = _alamatController.text.trim();
      if (existing.isNotEmpty) {
        _currentAddress.value = existing;
      } else {
        _currentAddress.value = 'Alamat tidak dapat diidentifikasi';
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Terjadi kesalahan saat mengambil alamat. Isi manual atau coba lagi.',
              ),
            ),
          );
      }
    } finally {
      _isGettingAddress.value = false;
    }
  }

  void _updateSelectedLocation(LatLng position) {
    setState(() {
      _selectedLocation = position;
    });
    _currentAddress.value = "Mendapatkan alamat...";

    // Dapatkan alamat dari koordinat yang dipilih
    _getAddressFromLatLng(position);
  }

  void _searchAddress(String query) {
    // Cancel timer sebelumnya jika ada
    _debounceTimer?.cancel();

    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    // Gunakan cache jika tersedia
    if (_searchCache.containsKey(query)) {
      setState(() {
        _searchResults = _searchCache[query]!;
        _isSearching = false;
      });
      return;
    }

    // Set state untuk menunjukkan loading
    setState(() => _isSearching = true);

    // Gunakan debounce untuk menghindari terlalu banyak request
    _debounceTimer = Timer(_debounceDelay, () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    try {
      final url =
          'https://nominatim.openstreetmap.org/search?format=json&q=$query&limit=5&addressdetails=1';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'nusantara_mobile/1.0 (contact: support@example.com)',
          'Accept-Language': 'id',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Simpan hasil ke cache
        _searchCache[query] = data;

        if (mounted) {
          setState(() {
            _searchResults = data;
            _isSearching = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearching = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error searching: ${e.toString()}")),
        );
      }
    }
  }

  void _selectSearchResult(dynamic result) {
    final lat = double.parse(result['lat']);
    final lon = double.parse(result['lon']);
    final location = LatLng(lat, lon);

    final displayName = result['display_name'] ?? 'Lokasi terpilih';
    setState(() {
      _selectedLocation = location;
      _searchResults = [];
      _searchController.clear();
    });
    // Set both the display value and the editable alamat controller so that
    // when user saves, the request contains the exact display name returned
    // by the geocoding service (improves specificity on backend).
    _currentAddress.value = displayName;
    _alamatController.text = displayName;

    _mapController.move(location, 15.0);
    _searchFocusNode.unfocus();
  }

  Future<void> _saveAddress() async {
    if (_selectedLocation == null || _labelController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Label alamat dan lokasi di peta wajib diisi."),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final chosenAlamat = _alamatController.text.trim().isNotEmpty
          ? _alamatController.text.trim()
          : _currentAddress.value;

      // Determine final label: prefer manual controller if custom, otherwise
      // use the selected option.
      final finalLabel =
          (_isCustomLabel
                  ? _labelController.text.trim()
                  : (_selectedLabelOption ?? _labelController.text.trim()))
              .trim();

      if (finalLabel.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Label alamat tidak boleh kosong.")),
        );
        setState(() => _isLoading = false);
        return;
      }

      if (widget.addressToEdit != null) {
        // Update existing address, preserve id
        final updated = AddressModel(
          id: widget.addressToEdit!.id,
          label: finalLabel,
          alamat: chosenAlamat,
          lat: _selectedLocation?.latitude,
          lang: _selectedLocation?.longitude,
          isSelected: widget.addressToEdit!.isSelected,
        );
        // DEBUG: print payload before update
        // ignore: avoid_print
        print(
          '[AddEditAddressPage] Updating address payload: ${updated.toJson()}',
        );
        await AddressService.updateAddress(updated);
        // DEBUG: indicate update completed
        // ignore: avoid_print
        print('[AddEditAddressPage] Update completed for id: ${updated.id}');
      } else {
        final newAddress = AddressModel(
          id: const Uuid().v4(),
          label: finalLabel,
          alamat: chosenAlamat,
          lat: _selectedLocation?.latitude,
          lang: _selectedLocation?.longitude,
          isSelected: false,
        );
        // DEBUG: print payload before create
        // ignore: avoid_print
        print(
          '[AddEditAddressPage] Creating address payload: ${newAddress.toJson()}',
        );

        await AddressService.addAddress(newAddress);
        // DEBUG: indicate create completed
        // ignore: avoid_print
        print('[AddEditAddressPage] Create completed for id: ${newAddress.id}');
      }

      if (mounted) {
        context.read<AddressBloc>().add(LoadAddresses());
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Alamat berhasil disimpan! 🎉")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menyimpan: ${e.toString()}")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Try to geocode a textual address and move the map to the first result.
  Future<void> _geocodeAddress(String query) async {
    if (query.trim().isEmpty) return;
    try {
      _isGettingAddress.value = true;
      final url =
          'https://nominatim.openstreetmap.org/search?format=json&q=${Uri.encodeQueryComponent(query)}&limit=1&addressdetails=1';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'nusantara_mobile/1.0 (contact: support@example.com)',
          'Accept-Language': 'id',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty) {
          final first = data.first;
          final lat = double.tryParse(first['lat']?.toString() ?? '');
          final lon = double.tryParse(first['lon']?.toString() ?? '');
          if (lat != null && lon != null) {
            final loc = LatLng(lat, lon);
            setState(() {
              _selectedLocation = loc;
              _initialPosition = loc;
            });
            _mapController.move(loc, 15.0);
            // Also update current address display from the returned display_name
            final displayName = first['display_name']?.toString();
            if (displayName != null && displayName.trim().isNotEmpty) {
              _currentAddress.value = displayName;
            }
          }
        }
      }
    } catch (_) {
      // Ignore geocode failure; user can adjust on map
    } finally {
      _isGettingAddress.value = false;
    }
  }

  void _clearSearch() {
    _debounceTimer?.cancel();
    setState(() {
      _searchResults = [];
      _searchController.clear();
    });
    _searchFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.addressToEdit != null ? "Edit Alamat" : "Tambah Alamat Baru",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _initialPosition ?? _kFallbackPosition,
                    initialZoom: 13.0,
                    onTap: (tapPosition, point) {
                      _updateSelectedLocation(point);
                      _mapController.move(point, _mapController.camera.zoom);
                      setState(() => _searchResults = []);
                      _searchFocusNode.unfocus();
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.nusantara_mobile',
                    ),
                    if (_selectedLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _selectedLocation!,
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_pin,
                              size: 40,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                if (_searchResults.isNotEmpty)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final result = _searchResults[index];
                          return ListTile(
                            leading: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.location_on,
                                color: Colors.orange,
                              ),
                            ),
                            title: Text(
                              result['display_name'] ?? 'Unknown location',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14),
                            ),
                            onTap: () => _selectSearchResult(result),
                          );
                        },
                      ),
                    ),
                  ),
                const Center(
                  child: Icon(Icons.location_pin, size: 40, color: Colors.red),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: _determinePosition,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.my_location, color: Colors.orange),
                    mini: true,
                  ),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: _isGettingAddress,
                  builder: (context, isGetting, _) {
                    if (!isGetting) return const SizedBox.shrink();
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.orange,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          _buildAddressDetailPanel(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: "Cari alamat...",
                hintStyle: TextStyle(color: Colors.grey[500]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey[500]),
                        onPressed: _clearSearch,
                      )
                    : _isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.orange,
                            ),
                          ),
                        ),
                      )
                    : null,
              ),
              onChanged: _searchAddress,
              onSubmitted: (value) {
                if (_searchResults.isNotEmpty) {
                  _selectSearchResult(_searchResults.first);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressDetailPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label selection: provide quick options and a manual fallback
          const Text(
            'Label Alamat',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                    color: Colors.white,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedLabelOption,
                      items: const [
                        DropdownMenuItem(value: 'Rumah', child: Text('Rumah')),
                        DropdownMenuItem(
                          value: 'Kantor',
                          child: Text('Kantor'),
                        ),
                        DropdownMenuItem(value: 'Kos', child: Text('Kos')),
                        DropdownMenuItem(
                          value: 'Lainnya',
                          child: Text('Lainnya'),
                        ),
                      ],
                      onChanged: (v) {
                        setState(() {
                          _selectedLabelOption = v;
                          if (v == 'Lainnya') {
                            _isCustomLabel = true;
                          } else {
                            _isCustomLabel = false;
                            _labelController.text = v ?? '';
                          }
                        });
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // If 'Lainnya' is selected show a manual input field
          if (_isCustomLabel)
            TextField(
              controller: _labelController,
              decoration: InputDecoration(
                labelText: 'Label Kustom',
                hintText: 'Masukkan label (mis. Rumah Nenek)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.orange),
                ),
                prefixIcon: Icon(Icons.edit_location, color: Colors.grey[500]),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          const SizedBox(height: 16),
          const Text(
            "Lokasi Terpilih:",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on, size: 18, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _isGettingAddress,
                    builder: (context, isGetting, _) {
                      if (isGetting) {
                        return const Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.orange,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Mendapatkan alamat...",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        );
                      }

                      return ValueListenableBuilder<String>(
                        valueListenable: _currentAddress,
                        builder: (context, addr, _) => Text(
                          addr,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isLoading ? null : _saveAddress,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    widget.addressToEdit != null
                        ? "Edit Alamat"
                        : "Simpan Alamat",
                  ),
          ),
        ],
      ),
    );
  }
}
