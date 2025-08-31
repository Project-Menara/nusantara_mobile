import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nusantara_mobile/features/home/presentation/bloc/banner/banner_bloc.dart';
import 'package:nusantara_mobile/features/home/presentation/bloc/banner/banner_event.dart';
import 'package:nusantara_mobile/features/home/presentation/bloc/banner/banner_state.dart';
import 'package:nusantara_mobile/features/home/presentation/bloc/category/category_bloc.dart';
import 'package:nusantara_mobile/features/home/presentation/bloc/home_bloc.dart';
import 'package:nusantara_mobile/features/home/presentation/pages/location/location_page.dart';
import 'package:nusantara_mobile/features/home/presentation/widgets/category_icons.dart';
import 'package:nusantara_mobile/features/home/presentation/widgets/event_list.dart';
import 'package:nusantara_mobile/features/home/presentation/widgets/nearby_store_list.dart';
import 'package:nusantara_mobile/features/home/presentation/widgets/promo_banner.dart';
import 'package:nusantara_mobile/features/home/presentation/widgets/recent_orders.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  
  // Tambahkan state untuk menyimpan nama lokasi
  String _currentLocation = "Pematang Siantar";

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(FetchHomeData());
    context.read<BannerBloc>().add(GetAllBannerEvent());
    context.read<CategoryBloc>().add(GetAllCategoryEvent());

    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    context.read<BannerBloc>().add(GetAllBannerEvent());
    context.read<CategoryBloc>().add(GetAllCategoryEvent());
    // context.read<HomeBloc>().add(FetchHomeData());
  }

  void _scrollListener() {
    if (_scrollController.offset > 200 - (kToolbarHeight * 2)) {
      if (!_isScrolled) {
        setState(() {
          _isScrolled = true;
        });
      }
    } else {
      if (_isScrolled) {
        setState(() {
          _isScrolled = false;
        });
      }
    }
  }

  // Fungsi baru untuk menangani pemilihan lokasi
  void _selectLocation() async {
    final newLocation = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LocationPage()),
    );

    // Jika user memilih lokasi baru, update state
    if (newLocation != null && newLocation is String) {
      setState(() {
        _currentLocation = newLocation;
      });
      // Opsional: muat ulang data berdasarkan lokasi baru
      _onRefresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading || state is HomeInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is HomeLoaded) {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: _buildContentWithSlivers(context, state),
            );
          }
          if (state is HomeError) {
            return Center(child: Text('Gagal memuat data: ${state.message}'));
          }
          return const Center(child: Text("Terjadi sesuatu yang salah."));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.orange,
        shape: const CircleBorder(),
        child: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
      ),
    );
  }

  Widget _buildContentWithSlivers(BuildContext context, HomeLoaded state) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        _buildSliverHeader(),
        BlocBuilder<BannerBloc, BannerState>(
          builder: (context, state) {
            if (state is BannerAllLoading) {
              return const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              );
            } else if (state is BannerAllLoaded) {
              return SliverToBoxAdapter(
                child: PromoBanner(banners: state.banners),
              );
            } else if (state is BannerAllError) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(state.message, textAlign: TextAlign.center),
                ),
              );
            }
            return const SliverToBoxAdapter(child: SizedBox.shrink());
          },
        ),
        const SliverToBoxAdapter(child: CategoryIcons()),
        const SliverToBoxAdapter(child: RecentOrders()),
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
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: NearbyStoreList()),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
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
        onTap: _selectLocation, // Aksi ketika teks lokasi diklik
        child: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              _currentLocation, // Menggunakan state dinamis
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
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