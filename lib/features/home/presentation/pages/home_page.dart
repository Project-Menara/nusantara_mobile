import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nusantara_mobile/core/constant/color_constant.dart';
import 'package:nusantara_mobile/features/home/presentation/bloc/banner/banner_bloc.dart';
import 'package:nusantara_mobile/features/home/presentation/bloc/banner/banner_event.dart';
import 'package:nusantara_mobile/features/home/presentation/bloc/banner/banner_state.dart';
import '../bloc/home_bloc.dart';
import '../widgets/promo_banner.dart';
import '../widgets/category_icons.dart';
import '../widgets/event_list.dart';
import '../widgets/nearby_store_list.dart';

// PERUBAHAN 1: Ubah menjadi StatefulWidget
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // PERUBAHAN 2: Buat ScrollController untuk mendeteksi scroll
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    // Panggil data saat pertama kali halaman dibuat
    context.read<HomeBloc>().add(FetchHomeData());
    context.read<BannerBloc>().add(GetAllBannerEvent());

    // Tambahkan listener ke controller
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    // Jangan lupa hapus controller saat widget dihancurkan
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    context.read<BannerBloc>().add(GetAllBannerEvent());
  }

  // PERUBAHAN 3: Fungsi yang akan dipanggil setiap kali ada scroll
  void _scrollListener() {
    // kToolbarHeight adalah tinggi standar AppBar (sekitar 56.0)
    // Jika posisi scroll sudah melewati tinggi header yang besar dikurangi 2x tinggi AppBar,
    // maka kita anggap header sudah mengecil.
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
      // PERUBAHAN 4: Hubungkan controller ke CustomScrollView
      controller: _scrollController,
      slivers: [
        _buildSliverHeader(),
        BlocBuilder<BannerBloc, BannerState>(
          builder: (context, state) {
            if (state is BannerAllLoading) {
              return const SliverToBoxAdapter(
                child: Center(
                  child: CircularProgressIndicator(
                    color: ColorConstant.whiteColor,
                  ),
                ),
              );
            } else if (state is BannerAllLoaded) {
              return SliverToBoxAdapter(
                child: PromoBanner(banners: state.banners),
              );
            } else if (state is BannerAllError) {
              return Text(
                state.message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              );
            }
            return const SizedBox.shrink();
          },
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
    // PERUBAHAN 5: Tentukan warna berdasarkan status scroll
    final ColorTween colorTween = ColorTween(
      begin: Colors.orange,
      end: Colors.white,
    );
    final Color textColor = _isScrolled ? Colors.black87 : Colors.white;
    final Color iconColor = _isScrolled ? Colors.orange : Colors.white;

    return SliverAppBar(
      automaticallyImplyLeading: false,
      // Gunakan warna dinamis, defaultnya oranye
      backgroundColor: _isScrolled ? Colors.white : Colors.orange,
      elevation: _isScrolled ? 2 : 0, // Beri shadow saat sudah menjadi putih
      pinned: true,
      stretch: true,
      expandedHeight: 200.0,

      title: Row(
        children: [
          Icon(Icons.location_on, color: iconColor, size: 20),
          const SizedBox(width: 8),
          Text(
            "Pematang Siantar",
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_none, color: textColor),
          onPressed: () {},
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 5), // Jarak standard app bar
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
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
                    height: 130,
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
