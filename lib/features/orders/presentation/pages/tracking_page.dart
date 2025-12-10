import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class TrackingPage extends StatefulWidget {
  const TrackingPage({super.key});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  final MapController _mapController = MapController();

  // Koordinat Toko (Bolu Menara - Medan)
  static const LatLng _shopLocation = LatLng(3.585242, 98.675597);

  // Koordinat User (Contoh - Sekitar Centre Point Medan)
  static const LatLng _userLocation = LatLng(3.591324, 98.681000);

  List<LatLng> _routePoints = [];
  bool _isLoadingRoute = true;

  int _currentDriverIndex = 0;
  Timer? _movementTimer;
  LatLng _driverLocation = _shopLocation;

  @override
  void initState() {
    super.initState();
    _getRoute();
  }

  @override
  void dispose() {
    _movementTimer?.cancel();
    super.dispose();
  }

  Future<void> _getRoute() async {
    try {
      // Menggunakan OSRM (Open Source Routing Machine) untuk mendapatkan rute jalan nyata
      // Format: {lon},{lat};{lon},{lat}
      final url = Uri.parse(
        'http://router.project-osrm.org/route/v1/driving/${_shopLocation.longitude},${_shopLocation.latitude};${_userLocation.longitude},${_userLocation.latitude}?overview=full&geometries=geojson',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> coordinates =
            data['routes'][0]['geometry']['coordinates'];

        setState(() {
          _routePoints = coordinates
              .map((coord) => LatLng(coord[1].toDouble(), coord[0].toDouble()))
              .toList();
          _isLoadingRoute = false;
        });

        _startSimulation();
      } else {
        // Fallback jika gagal fetch
        _useFallbackRoute();
      }
    } catch (e) {
      debugPrint("Error fetching route: $e");
      _useFallbackRoute();
    }
  }

  void _useFallbackRoute() {
    setState(() {
      _routePoints = [_shopLocation, _userLocation];
      _isLoadingRoute = false;
    });
    _startSimulation();
  }

  void _startSimulation() {
    if (_routePoints.isEmpty) return;

    // Kecepatan simulasi (update setiap 500ms)
    _movementTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_currentDriverIndex < _routePoints.length - 1) {
        setState(() {
          _currentDriverIndex++;
          _driverLocation = _routePoints[_currentDriverIndex];
        });
      } else {
        // Loop simulasi atau stop
        // timer.cancel();
        // Reset untuk demo
        setState(() {
          _currentDriverIndex = 0;
          _driverLocation = _routePoints[0];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _shopLocation, // Mulai dari toko
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.nusantara_mobile',
              ),
              if (!_isLoadingRoute && _routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      color: Colors.blue, // Warna rute seperti Google Maps
                      strokeWidth: 5.0,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  // Shop Marker
                  Marker(
                    point: _shopLocation,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.store,
                      color: Colors.orange,
                      size: 40,
                    ),
                  ),
                  // User Marker
                  Marker(
                    point: _userLocation,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                  // Driver Marker
                  if (!_isLoadingRoute)
                    Marker(
                      point: _driverLocation,
                      width: 200,
                      height: 100,
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Tooltip
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Kurir akan segera tiba...',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  'Paketmu dalam antrean',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Icon
                          Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFF1E293B), // Dark blue/slate
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black26, blurRadius: 4),
                              ],
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(
                              Icons.motorcycle,
                              color: Colors.orange,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Back Button
          Positioned(
            top: 50,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.orange,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => context.pop(),
              ),
            ),
          ),

          // Bottom Sheet
          DraggableScrollableSheet(
            initialChildSize: 0.4,
            minChildSize: 0.2,
            maxChildSize: 0.6,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Banner
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Pengiriman sedang dalam perjalanan',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '15 mnt',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Stepper
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(Icons.receipt_long, color: Colors.orange),
                          Expanded(
                            child: Divider(
                              color: Colors.orange[300],
                              thickness: 2,
                              indent: 4,
                              endIndent: 4,
                            ),
                          ),
                          const Icon(Icons.soup_kitchen, color: Colors.orange),
                          Expanded(
                            child: Divider(
                              color: Colors.orange[300],
                              thickness: 2,
                              indent: 4,
                              endIndent: 4,
                            ),
                          ),
                          const Icon(
                            Icons.delivery_dining,
                            color: Colors.orange,
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.grey[300],
                              thickness: 2,
                              indent: 4,
                              endIndent: 4,
                            ),
                          ),
                          Icon(
                            Icons.check_circle_outline,
                            color: Colors.grey[400],
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Total Payment
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Pembayaran anda',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Text(
                            'Rp 180.000',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Product Preview
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 60,
                                height: 60,
                                color: Colors.blue[100],
                                child: Image.asset(
                                  'assets/images/bolu_menara.png', // Placeholder
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.image),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Double Cheese',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'Bolu stim Double Cheese Regular Pack (600 gr)',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    '+2 menu lainnya',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'Lihat detail',
                              style: TextStyle(
                                color: Colors.orange[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Driver Info
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 24,
                              backgroundImage: NetworkImage(
                                'https://i.pravatar.cc/150?img=11',
                              ), // Placeholder
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'Agus Wijaya',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '4.99',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.star,
                                        size: 14,
                                        color: Colors.amber,
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Yamaha Mio  •  BK 123456',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
