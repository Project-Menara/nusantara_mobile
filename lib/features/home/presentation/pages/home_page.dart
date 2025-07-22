import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/home_bloc.dart';

// Impor untuk semua widget yang telah dipisah
import '../widgets/promo_banner.dart';
import '../widgets/category_icons.dart';
import '../widgets/event_list.dart';
import '../widgets/nearby_store_list.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<HomeBloc>().add(FetchHomeData());

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(190.0),
        child: _buildOrangeHeader(),
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading || state is HomeInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is HomeLoaded) {
            return _buildContent(context, state);
          }
          if (state is HomeError) {
            return Center(child: Text('Gagal memuat data: ${state.message}'));
          }
          return const Center(child: Text("Terjadi sesuatu yang salah."));
        },
      ),
      // TAMBAHKAN: FloatingActionButton di sini
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Tambahkan logika aksi saat tombol keranjang diklik
          // contoh: context.go('/cart');
        },
        backgroundColor: Colors.orange,
        shape: const CircleBorder(), // Membuatnya bulat sempurna
        child: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
      ),
    );
  }

  /// Membangun konten utama halaman ketika data sudah berhasil dimuat.
  Widget _buildContent(BuildContext context, HomeLoaded state) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        PromoBanner(promoImages: state.promos.map((e) => e.imageUrl).toList()),
        const CategoryIcons(),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text("Event", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        const EventList(),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("TOKO TERDEKAT", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const NearbyStoreList(),
        // Padding ini penting agar item terakhir tidak tertutup oleh FAB
        const SizedBox(height: 80),
      ],
    );
  }

  // Widget _buildOrangeHeader tidak perlu diubah
  Widget _buildOrangeHeader() {
    // ... (kode header tetap sama)
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.orange,
      elevation: 0,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.white),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Location", style: TextStyle(color: Colors.white70, fontSize: 12)),
                          Text("Pematang Siantar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Expanded(
                    child: Text(
                      "Yuk beli oleh-oleh untuk kerabat lewat Nusantara App!",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 80,
                    child: Image.asset('assets/images/character.png', fit: BoxFit.contain),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
    );
  }
}