import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:nusantara_mobile/features/home/presentation/bloc/adress/address_bloc.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_state.dart';
import 'package:nusantara_mobile/features/home/presentation/bloc/banner/banner_bloc.dart';
import 'package:nusantara_mobile/features/home/presentation/bloc/banner/banner_event.dart';
import 'package:nusantara_mobile/features/home/presentation/bloc/banner/banner_state.dart';
import 'package:nusantara_mobile/features/home/presentation/bloc/category/category_bloc.dart';
import 'package:nusantara_mobile/features/home/presentation/bloc/home_bloc.dart';
import 'package:nusantara_mobile/features/home/presentation/pages/location/select_address_page.dart';
import 'package:nusantara_mobile/features/cart/presentation/bloc/cart/cart_bloc.dart';
import 'package:nusantara_mobile/routes/initial_routes.dart';

import 'package:nusantara_mobile/features/home/presentation/widgets/category_icons.dart';
import 'package:nusantara_mobile/features/home/presentation/widgets/event_list.dart';
import 'package:nusantara_mobile/features/home/presentation/widgets/nearby_store_list.dart';
import 'package:nusantara_mobile/features/home/presentation/widgets/promo_banner.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  bool _isRequestingLocation = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _requestLocationPermission();
    _loadInitialData();
  }

  void _loadInitialData() {
    // Dispatch events jika data belum ada
    if (context.read<HomeBloc>().state is! HomeLoaded) {
      context.read<HomeBloc>().add(FetchHomeData());
    }
    if (context.read<BannerBloc>().state is! BannerAllLoaded) {
      context.read<BannerBloc>().add(GetAllBannerEvent());
    }
    if (context.read<CategoryBloc>().state is! CategoryAllLoaded) {
      context.read<CategoryBloc>().add(GetAllCategoryEvent());
    }
    // Only load saved addresses for authenticated users (avoid leaking previous user's addresses to guests)
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthUnauthenticated) {
      context.read<AddressBloc>().add(LoadAddresses());
    }
  }

  Future<void> _requestLocationPermission() async {
    if (_isRequestingLocation) return;

    setState(() => _isRequestingLocation = true);

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled, show dialog to enable
        _showLocationServiceDialog();
        return;
      }

      // Check permission status
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        // Request permission if denied
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          // Permission denied, show message
          _showPermissionDeniedMessage();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permission denied forever, show dialog to open settings
        _showPermissionPermanentlyDeniedDialog();
        return;
      }

      // Permission granted, get current location
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        _getCurrentLocation();
      }
    } catch (e) {
      // debug: Error requesting location permission: $e
    } finally {
      setState(() => _isRequestingLocation = false);
    }
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Layanan Lokasi Tidak Aktif'),
          content: const Text(
            'Aktifkan layanan lokasi untuk pengalaman yang lebih baik.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Nanti'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Geolocator.openLocationSettings();
              },
              child: const Text('Aktifkan'),
            ),
          ],
        );
      },
    );
  }

  void _showPermissionDeniedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Izin lokasi ditolak. Beberapa fitur mungkin tidak berfungsi optimal.',
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showPermissionPermanentlyDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Izin Lokasi Ditolak Permanen'),
          content: const Text('Buka pengaturan untuk memberikan izin lokasi.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Geolocator.openAppSettings();
              },
              child: const Text('Pengaturan'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      // debug: Current location retrieved
    } catch (e) {
      // debug: Error getting current location: $e
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    // Refresh data dengan BLoC
    context.read<BannerBloc>().add(GetAllBannerEvent());
    context.read<CategoryBloc>().add(GetAllCategoryEvent());
    context.read<AddressBloc>().add(LoadAddresses());

    // Request location permission again on refresh
    _requestLocationPermission();
  }

  void _scrollListener() {
    if (_scrollController.offset > 200 - (kToolbarHeight * 2)) {
      if (!_isScrolled) {
        if (mounted) setState(() => _isScrolled = true);
      }
    } else {
      if (_isScrolled) {
        if (mounted) setState(() => _isScrolled = false);
      }
    }
  }

  void _selectLocation() async {
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => const SelectAddressPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildSliverHeader(),
            SliverToBoxAdapter(
              child: BlocBuilder<BannerBloc, BannerState>(
                builder: (context, state) {
                  if (state is BannerAllLoaded) {
                    return PromoBanner(banners: state.banners);
                  }
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: AspectRatio(
                      aspectRatio: 16 / 7,
                      child: Card(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SliverToBoxAdapter(child: CategoryIcons()),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(
                  "Event",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: EventList()),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "TOKO TERDEKAT",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: NearbyStoreList()),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
      floatingActionButton: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          int itemCount = 0;
          if (state is CartLoaded) {
            itemCount = state.items.length;
          } else if (state is CartActionSuccess) {
            itemCount = state.items.length;
          }

          return Stack(
            clipBehavior: Clip.none,
            children: [
              FloatingActionButton(
                onPressed: () {
                  context.push(InitialRoutes.cart);
                },
                backgroundColor: Colors.orange,
                shape: const CircleBorder(),
                child: const Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.white,
                ),
              ),
              if (itemCount > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      itemCount > 99 ? '99+' : '$itemCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverHeader() {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.orange,
      elevation: _isScrolled ? 4.0 : 0.0,
      pinned: true,
      stretch: true,
      expandedHeight: 200.0,
      shape: _isScrolled
          ? const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            )
          : null,
      title: GestureDetector(
        onTap: _selectLocation,
        child: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            // Only show saved addresses when authenticated; guests see a generic prompt
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                if (authState is AuthUnauthenticated) {
                  return const Expanded(
                    child: Text(
                      'Pilih Lokasi',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }

                return BlocBuilder<AddressBloc, AddressState>(
                  builder: (context, state) {
                    String locationLabel = 'Pilih Lokasi';
                    if (state is AddressLoaded &&
                        state.selectedAddress != null) {
                      locationLabel = state.selectedAddress!.label;
                    }
                    return Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            locationLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          // Show the full address or street if available
                          if (state is AddressLoaded &&
                              state.selectedAddress != null &&
                              state.selectedAddress!.alamat.isNotEmpty)
                            Text(
                              state.selectedAddress!.alamat,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            if (_isRequestingLocation)
              const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.white),
          onPressed: () {},
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: kToolbarHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Expanded(
                    child: Text(
                      "Yuk beli oleh-oleh untuk kerabat lewat Nusantara App!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 110,
                    child: Image.asset(
                      'assets/images/character.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
