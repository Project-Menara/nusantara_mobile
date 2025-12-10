import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nusantara_mobile/features/home/data/datasources/nearby_shop_service.dart';
import 'package:nusantara_mobile/features/home/data/models/shop_model.dart';
import 'package:go_router/go_router.dart';
import 'package:nusantara_mobile/routes/initial_routes.dart';
import 'package:nusantara_mobile/features/shop/domain/entities/shop_entity.dart'
    as shop_entity;
import 'package:nusantara_mobile/features/shop/presentation/pages/shop_detail_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nusantara_mobile/features/home/presentation/bloc/adress/address_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NearbyStoreList extends StatelessWidget {
  const NearbyStoreList({super.key});

  Future<List<ShopModel>> _loadShops(BuildContext context) async {
    final service = NearbyShopService();

    double? lat;
    double? lng;

    try {
      final addressState = context.read<AddressBloc>().state;
      if (addressState is AddressLoaded &&
          addressState.selectedAddress != null) {
        final sel = addressState.selectedAddress!;
        if (sel.lat != null && sel.lang != null) {
          // Gunakan koordinat dari alamat yang dipilih
          lat = sel.lat;
          lng = sel.lang;
        }
      }
    } catch (_) {
      // Abaikan error bloc, lanjut coba ambil lokasi device
    }
    // Jika belum ada koordinat dari alamat, coba ambil dari lokasi device
    if (lat == null || lng == null) {
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
        );
        lat = position.latitude;
        lng = position.longitude;
      } catch (_) {
        // Jika gagal mendapatkan lokasi, biarkan lat/lng null
      }
    }

    // Jika tetap tidak ada koordinat, kembalikan list kosong agar UI menampilkan
    // pesan "Tidak ada toko terdekat" tanpa error 401 dari backend.
    if (lat == null || lng == null) {
      return [];
    }

    // Panggil endpoint public-nearby-shops dengan lat & lng
    return service.fetchNearbyShops(lat: lat, lng: lng);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: BlocBuilder<AddressBloc, AddressState>(
        builder: (context, addressState) {
          return FutureBuilder<List<ShopModel>>(
            future: _loadShops(context),
            builder: (context, snapshot) {
              // The FutureBuilder uses `_loadShops(context)` which already reads the
              // selected address from AddressBloc and passes lat/lang if available.
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 120,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                final err = snapshot.error?.toString() ?? 'Unknown error';
                return Column(
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      'Gagal memuat toko terdekat',
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        err,
                        style: TextStyle(
                          color: Colors.red.shade400,
                          fontSize: 12,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                );
              }

              final shops = snapshot.data ?? [];
              // Debug: print shops to console
              if (shops.isNotEmpty) {
                // ignore: avoid_print
                print('[NearbyStoreList] ${shops.length} shops loaded');
                for (final s in shops) {
                  // ignore: avoid_print
                  print(
                    '[NearbyStoreList] shop id=${s.id} name=${s.name} lat=${s.lat} lang=${s.lang} distance=${s.distance}',
                  );
                }
              }
              if (shops.isEmpty) {
                return const SizedBox(
                  height: 80,
                  child: Center(child: Text('Tidak ada toko terdekat')),
                );
              }

              return Column(
                children: shops
                    .map((s) => _buildStoreCard(context, s))
                    .toList(),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStoreCard(BuildContext context, ShopModel shop) {
    final distance = shop.distance ?? '-';
    final address = shop.fullAddress ?? '-';

    // convert Home ShopModel to ShopEntity used by new ShopDetailPage
    final shopEntity = shop_entity.ShopEntity(
      id: shop.id,
      name: shop.name,
      cover: shop.cover ?? '',
      description: shop.description ?? '',
      fullAddress: shop.fullAddress ?? '',
      lat: shop.lat ?? 0.0,
      lang: shop.lang ?? 0.0,
      status: 1,
      createdBy: '',
      createdAt: DateTime.now(),
      updateAt: DateTime.now(),
      deletedAt: null,
      shopImages: const [],
      shopProduct: (shop.products)
          .map(
            (p) => shop_entity.ProductEntity(
              id: p.id,
              name: p.name,
              image: p.image ?? '',
              code: '',
              price: p.price,
              unit: p.unit,
              description: '',
              status: 1,
              typeProduct: p.typeProduct, // pass through category/type
              productImages: const [],
              createdBy: '',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          )
          .toList(),
      shopCashier: const [],
      distance: distance,
    );

    return GestureDetector(
      onTap: () {
        // Navigate to shop detail - pass converted entity
        // Use go_router if available
        try {
          context.push(InitialRoutes.shopDetail, extra: shopEntity);
        } catch (_) {
          // fallback to Material push if go_router extension not available
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ShopDetailPage(shop: shopEntity)),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Store image (cover) if available
                if (shop.cover != null && shop.cover!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: shop.cover!,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 64,
                        height: 64,
                        color: Colors.grey.shade100,
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 64,
                        height: 64,
                        color: Colors.grey.shade100,
                        child: const Icon(Icons.storefront, color: Colors.grey),
                      ),
                    ),
                  )
                else
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.storefront, color: Colors.grey),
                  ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              shop.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            distance,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(address, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Buka',
                    style: TextStyle(
                      color: Colors.green.shade800,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Lihat Produk',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
