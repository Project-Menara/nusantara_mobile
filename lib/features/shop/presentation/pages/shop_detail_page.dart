import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nusantara_mobile/features/shop/domain/entities/shop_entity.dart';
import 'package:nusantara_mobile/features/cart/presentation/bloc/cart/cart_bloc.dart';
import 'package:nusantara_mobile/features/favorite/presentation/bloc/favorite/favorite_bloc.dart';
import 'package:nusantara_mobile/features/favorite/domain/entities/favorite_entity.dart';
import 'package:nusantara_mobile/features/home/presentation/bloc/category/category_bloc.dart';
import 'package:nusantara_mobile/routes/initial_routes.dart';
import 'package:nusantara_mobile/features/shop/presentation/widgets/shop_detail_header.dart';
import 'package:nusantara_mobile/features/shop/presentation/widgets/category_chip_item.dart';
import 'package:nusantara_mobile/features/shop/presentation/widgets/product_image_carousel_large.dart';

class ShopDetailPage extends StatelessWidget {
  final ShopEntity shop;

  const ShopDetailPage({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    return _ShopDetailView(shop: shop);
  }
}

class _ShopDetailView extends StatefulWidget {
  final ShopEntity shop;

  const _ShopDetailView({required this.shop});

  @override
  State<_ShopDetailView> createState() => _ShopDetailViewState();
}

class _ShopDetailViewState extends State<_ShopDetailView> {
  String? _selectedCategoryName;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  Future<void> _handleRefresh() async {
    context.read<FavoriteBloc>().add(const GetMyFavoriteEvent());
    context.read<CartBloc>().add(const GetMyCartEvent());
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final spacerHeight = screenHeight < 700 ? 250.0 : 270.0;

    return BlocListener<FavoriteBloc, FavoriteState>(
      listener: (context, state) {},
      child: Scaffold(
        appBar: null,
        body: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: Colors.red,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: ShopDetailHeader(
                  shop: widget.shop,
                  onSearchChanged: (query) {
                    setState(() {
                      _searchQuery = query;
                    });
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: spacerHeight),
                    _buildCategoryChips(),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
                      child: Text(
                        'Menu',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final all = widget.shop.shopProduct.toList();
                    final filtered = all.where((p) {
                      final matchesQuery = _searchQuery.isEmpty
                          ? true
                          : p.name.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            );
                      final matchesCategory = _selectedCategoryName == null
                          ? true
                          : p.typeProduct.toLowerCase() ==
                                _selectedCategoryName!.toLowerCase();
                      return matchesQuery && matchesCategory;
                    }).toList();

                    if (filtered.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 40, 16, 80),
                        child: Center(
                          child: Text(
                            'Tidak ada produk yang sesuai',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      );
                    }

                    final product = filtered[index];
                    return _buildProductListItem(product);
                  },
                  childCount: (() {
                    final all = widget.shop.shopProduct.toList();
                    final count = all.where((p) {
                      final matchesQuery = _searchQuery.isEmpty
                          ? true
                          : p.name.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            );
                      final matchesCategory = _selectedCategoryName == null
                          ? true
                          : p.typeProduct.toLowerCase() ==
                                _selectedCategoryName!.toLowerCase();
                      return matchesQuery && matchesCategory;
                    }).length;
                    return count == 0 ? 1 : count;
                  })(),
                ),
              ),
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
      ),
    );
  }

  Widget _buildCategoryChips() {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is CategoryAllLoading || state is CategoryInitial) {
          return const SizedBox(
            height: 45,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is CategoryAllLoaded) {
          final categories = state.categories;
          final itemCount = categories.length + 1;

          return SizedBox(
            height: 45,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: itemCount,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                if (index == 0) {
                  final bool isSelected = _selectedCategoryName == null;
                  return CategoryChipItem(
                    label: 'Semua',
                    isSelected: isSelected,
                    onTap: () => setState(() => _selectedCategoryName = null),
                  );
                }

                final category = categories[index - 1];
                final key = category.name.trim().toLowerCase();
                final bool isSelected =
                    (_selectedCategoryName != null &&
                    _selectedCategoryName!.trim().toLowerCase() == key);

                return CategoryChipItem(
                  label: _capitalize(category.name),
                  isSelected: isSelected,
                  onTap: () => setState(() => _selectedCategoryName = key),
                );
              },
            ),
          );
        }

        return SizedBox(
          height: 45,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 1,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final bool isSelected = _selectedCategoryName == null;
              return CategoryChipItem(
                label: 'Semua',
                isSelected: isSelected,
                onTap: () => setState(() => _selectedCategoryName = null),
              );
            },
          ),
        );
      },
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  Widget _buildProductListItem(ProductEntity product) {
    const String productDescription =
        'Bolu stim Double Cheese Regular Pack (600 gr)';
    const String productRating = '4.99';

    return InkWell(
      onTap: () {
        _showProductDetail(context, product);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!, width: 1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.typeProduct.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        product.typeProduct,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange[700],
                        ),
                      ),
                    ),
                  if (product.typeProduct.isNotEmpty) const SizedBox(height: 6),
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    productDescription,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    formatter.format(product.price),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber[600], size: 18),
                      const SizedBox(width: 4),
                      Text(
                        productRating,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: product.image,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[200],
                      child: const Icon(Icons.error),
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: BlocBuilder<FavoriteBloc, FavoriteState>(
                    builder: (context, state) {
                      bool isFavorite = false;

                      if (state is FavoriteLoaded) {
                        isFavorite = state.isFavorite(product.id);
                      } else if (state is FavoriteActionSuccess) {
                        isFavorite = state.isFavorite(product.id);
                      }

                      return GestureDetector(
                        onTap: () {
                          context.read<FavoriteBloc>().add(
                            ToggleFavoriteEvent(
                              productId: product.id,
                              isCurrentlyFavorite: isFavorite,
                            ),
                          );
                        },
                        child: AnimatedScale(
                          scale: isFavorite ? 1.1 : 1.0,
                          duration: const Duration(milliseconds: 150),
                          curve: Curves.easeOutBack,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: isFavorite
                                  ? Colors.red.withOpacity(0.15)
                                  : Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: isFavorite
                                      ? Colors.red.withOpacity(0.3)
                                      : Colors.black.withOpacity(0.1),
                                  blurRadius: isFavorite ? 6 : 4,
                                ),
                              ],
                            ),
                            child: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 16,
                              color: isFavorite ? Colors.red : Colors.grey[700],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Tambah',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessAnimation(BuildContext context, ProductEntity product) {
    HapticFeedback.mediumImpact();
    final navigationContext = context;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 600),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Berhasil!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Produk ditambahkan ke keranjang',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: product.image,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.image),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formatter.format(product.price),
                              style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'x1',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          side: const BorderSide(color: Colors.orange),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Lanjut Belanja',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.of(dialogContext).pop();
                          await Future.delayed(
                            const Duration(milliseconds: 100),
                          );
                          if (navigationContext.mounted) {
                            navigationContext.push(InitialRoutes.cart);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Lihat Keranjang',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showProductDetail(BuildContext context, ProductEntity product) {
    final cartBloc = context.read<CartBloc>();
    final favoriteBloc = context.read<FavoriteBloc>();

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
            BlocProvider.value(value: cartBloc),
            BlocProvider.value(value: favoriteBloc),
          ],
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(modalContext).size.height * 0.9,
            ),
            child: _buildProductDetailSheet(product),
          ),
        );
      },
    );
  }

  Widget _buildProductDetailSheet(ProductEntity product) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 4,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildModalImage(product),
                _buildModalInfo(product),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        _buildModalActionButton(product),
      ],
    );
  }

  Widget _buildModalImage(ProductEntity product) {
    List<String> images = [];

    if (product.productImages.isNotEmpty) {
      images = product.productImages;
    } else {
      final favState = context.read<FavoriteBloc>().state;
      List<String> favoriteImages = [];

      if (favState is FavoriteLoaded) {
        final fav = favState.items.firstWhere(
          (e) => e.productId == product.id,
          orElse: () => FavoriteEntity(
            id: '',
            productId: '',
            productName: '',
            productImage: null,
            price: 0,
            unit: '',
            description: null,
            typeProduct: '',
            productImages: const [],
            selected: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        favoriteImages = fav.productImages;
      } else if (favState is FavoriteActionSuccess) {
        final fav = favState.items.firstWhere(
          (e) => e.productId == product.id,
          orElse: () => FavoriteEntity(
            id: '',
            productId: '',
            productName: '',
            productImage: null,
            price: 0,
            unit: '',
            description: null,
            typeProduct: '',
            productImages: const [],
            selected: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        favoriteImages = fav.productImages;
      }

      if (favoriteImages.isNotEmpty) {
        images = favoriteImages;
      } else if (product.image.isNotEmpty) {
        images = [product.image];
      } else {
        images = [];
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: images.isNotEmpty
          ? ProductImageCarouselLarge(images: images, height: 210)
          : Container(
              height: 210,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.image, size: 56, color: Colors.grey[400]),
            ),
    );
  }

  Widget _buildModalInfo(ProductEntity product) {
    const String productDescription =
        'Bolu stim Double Cheese Regular Pack (600 gr)';
    const String productRating = '4.99';

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (product.typeProduct.isNotEmpty)
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
                product.typeProduct,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange[700],
                ),
              ),
            ),
          if (product.typeProduct.isNotEmpty) const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  product.name,
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
          Text(
            productDescription,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                formatter.format(product.price),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              BlocBuilder<FavoriteBloc, FavoriteState>(
                builder: (context, state) {
                  bool isFavorite = false;

                  if (state is FavoriteLoaded) {
                    isFavorite = state.isFavorite(product.id);
                  } else if (state is FavoriteActionLoading) {
                    isFavorite = state.isFavorite(product.id);
                  } else if (state is FavoriteActionSuccess) {
                    isFavorite = state.isFavorite(product.id);
                  }

                  return IconButton(
                    onPressed: () {
                      if (isFavorite) {
                        context.read<FavoriteBloc>().add(
                          RemoveFromFavoriteEvent(product.id),
                        );
                      } else {
                        context.read<FavoriteBloc>().add(
                          AddToFavoriteEvent(product.id),
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

  Widget _buildModalActionButton(ProductEntity product) {
    return BlocConsumer<CartBloc, CartState>(
      listener: (context, state) {
        if (state is CartActionSuccess) {
          Navigator.pop(context);
          _showSuccessAnimation(context, product);
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
                      context.read<CartBloc>().add(
                        AddToCartEvent(productId: product.id, quantity: 1),
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
                        fontSize: 16,
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
