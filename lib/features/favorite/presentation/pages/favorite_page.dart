import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:nusantara_mobile/features/favorite/domain/entities/favorite_entity.dart';
import 'package:nusantara_mobile/features/favorite/presentation/bloc/favorite/favorite_bloc.dart';
import 'package:nusantara_mobile/features/cart/presentation/bloc/cart/cart_bloc.dart';
import 'package:nusantara_mobile/core/injection_container.dart';
import 'package:nusantara_mobile/routes/initial_routes.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Refresh saat page pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoriteBloc>().add(const GetMyFavoriteEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return const FavoriteView();
  }
}

class FavoriteView extends StatelessWidget {
  const FavoriteView({super.key});

  // AppBar bergaya sama seperti halaman Profile
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.orange,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: const Text(
        'Favorite',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp.', // 2. Sesuaikan format harga
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: _buildAppBar(),
      body: BlocBuilder<FavoriteBloc, FavoriteState>(
        builder: (context, state) {
          if (state is FavoriteLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is FavoriteEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 120,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Belum Ada Favorit',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tambahkan produk favorit Anda!',
                    style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.go(InitialRoutes.home);
                    },
                    icon: const Icon(Icons.shopping_bag),
                    label: const Text('Mulai Belanja'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is FavoriteError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<FavoriteBloc>().add(
                        const GetMyFavoriteEvent(),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba Lagi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          List<FavoriteEntity> items = [];
          if (state is FavoriteLoaded) {
            items = state.items;
          } else if (state is FavoriteActionLoading) {
            items = state.items;
          }

          if (items.isEmpty) {
            return const Center(child: Text('Favorit kosong'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<FavoriteBloc>().add(const GetMyFavoriteEvent());
              await Future.delayed(const Duration(seconds: 1));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _FavoriteItemTile(item: item, formatter: formatter);
              },
            ),
          );
        },
      ),
    );
  }
}

// 8. Desain ulang widget item (_FavoriteCard -> _FavoriteItemTile)
class _FavoriteItemTile extends StatelessWidget {
  final FavoriteEntity item;
  final NumberFormat formatter;

  const _FavoriteItemTile({required this.item, required this.formatter});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      shadowColor: Colors.grey.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge Category
          if (item.typeProduct.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  item.typeProduct,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange[700],
                  ),
                ),
              ),
            ),
          // Konten Utama (Gambar, Detail, Tombol Hati)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 8, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child:
                      item.productImage != null && item.productImage!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: item.productImage!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[200],
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[200],
                            child: Icon(Icons.image, color: Colors.grey[400]),
                          ),
                        )
                      : Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: Icon(Icons.image, color: Colors.grey[400]),
                        ),
                ),
                const SizedBox(width: 12),
                // Nama Produk dan Subtitel
                Expanded(
                  child: SizedBox(
                    height: 80, // Samakan tinggi dengan gambar
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.productName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.typeProduct, // "Bolu stim (600 gr)"
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                // Tombol Hapus Favorite
                IconButton(
                  onPressed: () {
                    context.read<FavoriteBloc>().add(
                      RemoveFromFavoriteEvent(item.productId),
                    );
                  },
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  tooltip: 'Hapus dari favorit',
                ),
              ],
            ),
          ),
          // Garis Pemisah
          const Divider(height: 1, indent: 16, endIndent: 16),
          // Baris Harga dan Link
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Harga
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Harga',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatter.format(item.price),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                // Link "Lihat Produk"
                InkWell(
                  onTap: () {
                    _showProductDetail(context, item);
                  },
                  child: const Text(
                    'Lihat Produk',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showProductDetail(BuildContext context, FavoriteEntity item) {
    // debug prints removed for performance

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<CartBloc>.value(value: sl<CartBloc>()),
            BlocProvider<FavoriteBloc>.value(value: sl<FavoriteBloc>()),
          ],
          child: ConstrainedBox(
            constraints: BoxConstraints(
              // Sedikit lebih pendek dari modal di halaman toko
              // supaya tidak terasa terlalu banyak ruang putih.
              maxHeight: MediaQuery.of(modalContext).size.height * 0.7,
            ),
            child: _ProductDetailModal(item: item, formatter: formatter),
          ),
        );
      },
    );
  }
}

// Widget Modal Detail Produk
class _ProductDetailModal extends StatelessWidget {
  final FavoriteEntity item;
  final NumberFormat formatter;

  const _ProductDetailModal({required this.item, required this.formatter});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Drag handle (garis abu-abu di atas)
        Container(
          width: 48,
          height: 4,
          margin: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        // Konten yang bisa di-scroll
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar produk dengan carousel
                _buildModalImage(),
                // Info teks (nama, rating, deskripsi, harga, tombol favorite)
                _buildModalInfo(context),
              ],
            ),
          ),
        ),
        // Tombol "Tambah Pembelian" yang menempel di bawah
        _buildModalActionButton(context),
      ],
    );
  }

  /// Widget untuk gambar di dalam modal (dengan carousel jika ada multiple images)
  Widget _buildModalImage() {
    // debug prints removed for performance

    // Gunakan productImages jika ada, fallback ke productImage
    final List<String> images;
    if (item.productImages.isNotEmpty) {
      images = item.productImages;
    } else if (item.productImage != null && item.productImage!.isNotEmpty) {
      images = [item.productImage!];
    } else {
      images = [];
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: _ProductImageCarousel(images: images, height: 220),
    );
  }

  /// Widget untuk info teks di dalam modal
  Widget _buildModalInfo(BuildContext context) {
    const String productRating = '4.99';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge Category
          if (item.typeProduct.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                item.typeProduct,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange[700],
                ),
              ),
            ),
          if (item.typeProduct.isNotEmpty) const SizedBox(height: 6),

          // Nama produk + rating (ikuti layout di ShopDetail)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.productName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber[600], size: 18),
                  const SizedBox(width: 4),
                  const Text(
                    productRating,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Unit + deskripsi (menggantikan teks deskripsi statis)
          Text(
            item.unit,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
          if (item.description != null && item.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              item.description!,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
          ],

          const SizedBox(height: 8),

          // Harga dan Tombol Favorite dalam satu baris (disamakan dengan ShopDetail)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Harga
              Text(
                formatter.format(item.price),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              // Tombol Favorite
              BlocBuilder<FavoriteBloc, FavoriteState>(
                builder: (context, state) {
                  // Item dari favorite page sudah pasti favorite
                  bool isFavorite = true;

                  // Cek jika sudah dihapus
                  if (state is FavoriteLoaded) {
                    isFavorite = state.isFavorite(item.productId);
                  } else if (state is FavoriteActionSuccess) {
                    isFavorite = state.isFavorite(item.productId);
                  } else if (state is FavoriteActionLoading) {
                    isFavorite = state.isFavorite(item.productId);
                  }

                  return IconButton(
                    onPressed: () {
                      if (isFavorite) {
                        // Hapus dari favorite
                        context.read<FavoriteBloc>().add(
                          RemoveFromFavoriteEvent(item.productId),
                        );
                        // Tutup modal setelah hapus
                        Navigator.pop(context);
                      } else {
                        // Tambah ke favorite
                        context.read<FavoriteBloc>().add(
                          AddToFavoriteEvent(item.productId),
                        );
                      }
                    },
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.grey[700],
                      size: 28,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Widget untuk tombol aksi di bawah modal
  Widget _buildModalActionButton(BuildContext context) {
    return BlocConsumer<CartBloc, CartState>(
      listener: (context, state) {
        if (state is CartActionSuccess) {
          // Tutup modal
          Navigator.pop(context);

          // Tampilkan notifikasi sukses
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('${item.productName} ditambahkan ke keranjang'),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        } else if (state is CartError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text(state.message)),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is CartActionLoading;

        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            8,
            16,
            MediaQuery.of(context).padding.bottom + 12,
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      // Tambahkan produk ke cart dengan quantity default 1
                      context.read<CartBloc>().add(
                        AddToCartEvent(productId: item.productId, quantity: 1),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 5,
                shadowColor: Colors.orange.withOpacity(0.4),
                disabledBackgroundColor: Colors.grey,
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Tambah Pembelian',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}

// Widget untuk Image Carousel di modal
class _ProductImageCarousel extends StatefulWidget {
  final List<String> images;
  final double height;

  const _ProductImageCarousel({required this.images, this.height = 250});

  @override
  State<_ProductImageCarousel> createState() => _ProductImageCarouselState();
}

class _ProductImageCarouselState extends State<_ProductImageCarousel> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // debug prints removed for performance

    // Jika tidak ada gambar
    if (widget.images.isEmpty) {
      return Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.broken_image, size: 60, color: Colors.grey[400]),
      );
    }

    // Jika hanya ada 1 gambar, tampilkan tanpa carousel
    if (widget.images.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CachedNetworkImage(
          imageUrl: widget.images.first,
          width: double.infinity,
          height: widget.height,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            height: widget.height,
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.orange,
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            height: widget.height,
            color: Colors.grey[200],
            child: Icon(Icons.broken_image, color: Colors.grey[400]),
          ),
        ),
      );
    }

    // Jika ada multiple images, tampilkan carousel dengan dots indicator
    return Stack(
      children: [
        // PageView untuk swipe gambar
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            width: double.infinity,
            height: widget.height,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: widget.images.length,
              itemBuilder: (context, index) {
                return CachedNetworkImage(
                  imageUrl: widget.images[index],
                  width: double.infinity,
                  height: widget.height,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: widget.height,
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: widget.height,
                    color: Colors.grey[200],
                    child: Icon(Icons.broken_image, color: Colors.grey[400]),
                  ),
                );
              },
            ),
          ),
        ),

        // Dots indicator di bawah
        Positioned(
          bottom: 12,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.images.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: _currentPage == index
                      ? Colors.orange
                      : Colors.white.withOpacity(0.7),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
