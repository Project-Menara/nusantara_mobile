import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nusantara_mobile/features/shop/presentation/bloc/shop/shop_bloc.dart';
import 'package:nusantara_mobile/features/shop/presentation/bloc/shop/shop_event.dart';
import 'package:nusantara_mobile/features/shop/presentation/bloc/shop/shop_state.dart';
import 'package:nusantara_mobile/features/shop/presentation/widgets/nearby_shop_card.dart';

class NearbyShopsSection extends StatelessWidget {
  final double userLat;
  final double userLng;

  const NearbyShopsSection({
    super.key,
    required this.userLat,
    required this.userLng,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShopBloc, ShopState>(
      builder: (context, state) {
        if (state is ShopInitial) {
          // Trigger loading nearby shops when first initialized
          context.read<ShopBloc>().add(
            GetNearbyShopsEvent(lat: userLat, lng: userLng),
          );
          return _buildShimmerLoading();
        }

        if (state is ShopLoading) {
          return _buildShimmerLoading();
        }

        if (state is ShopLoaded) {
          if (state.shops.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Toko Terdekat',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (state.shops.length > 3)
                      TextButton(
                        onPressed: () {
                          // Navigate to full nearby shops page
                          // context.push(InitialRoutes.nearbyShops, extra: {
                          //   'lat': userLat,
                          //   'lng': userLng,
                          // });
                        },
                        child: const Text(
                          'Lihat Semua',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 280,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: state.shops.length > 5 ? 5 : state.shops.length,
                  itemBuilder: (context, index) {
                    final shop = state.shops[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        right: index < state.shops.length - 1 ? 12 : 0,
                      ),
                      child: NearbyShopCard(shop: shop),
                    );
                  },
                ),
              ),
            ],
          );
        }

        if (state is ShopError) {
          return _buildErrorState(context);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildShimmerLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            height: 24,
            width: 150,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: 3,
            itemBuilder: (context, index) {
              return Container(
                width: 200,
                margin: EdgeInsets.only(right: index < 2 ? 12 : 0),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            Icons.store_mall_directory_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'Tidak ada toko terdekat',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Belum ada toko di sekitar lokasi Anda',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          const Text(
            'Gagal memuat toko terdekat',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Terjadi kesalahan saat mengambil data toko',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<ShopBloc>().add(
                GetNearbyShopsEvent(lat: userLat, lng: userLng),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}
