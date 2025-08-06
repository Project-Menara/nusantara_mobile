import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nusantara_mobile/features/home/domain/entities/category_entity.dart';
import 'package:nusantara_mobile/features/home/presentation/bloc/category/category_bloc.dart';
// Anda mungkin memerlukan package shimmer untuk efek loading yang lebih baik
// import 'package:shimmer/shimmer.dart';

class CategoryIcons extends StatelessWidget {
  const CategoryIcons({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        // **State: Loading**
        // Menampilkan placeholder/shimmer saat data sedang diambil.
        if (state is CategoryAllLoading || state is CategoryInitial) {
          return _buildLoadingShimmer();
        }

        // **State: Error**
        // Menampilkan pesan error jika terjadi kegagalan.
        if (state is CategoryAllError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'Gagal memuat kategori: ${state.message}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        // **State: Loaded**
        // Menampilkan daftar kategori jika data berhasil didapat.
        if (state is CategoryAllLoaded) {
          if (state.categories.isEmpty) {
            return const SizedBox.shrink(); // Tidak menampilkan apa-apa jika kosong
          }

          // Mengambil maksimal 4 kategori untuk ditampilkan + 1 tombol 'Lainnya'
          final displayedCategories = state.categories.take(4).toList();

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...displayedCategories.map((category) {
                  return _buildCategoryItem(
                    context: context,
                    category: category,
                  );
                }).toList(),
                _buildCategoryItem(context: context, isOther: true),
              ],
            ),
          );
        }

        // State default jika tidak ada yang cocok
        return const SizedBox.shrink();
      },
    );
  }

  /// Widget untuk membuat satu item kategori.
  Widget _buildCategoryItem({
    required BuildContext context,
    CategoryEntity? category,
    bool isOther = false,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () {
          if (isOther) {
            // TODO: Navigasi ke halaman 'Semua Kategori'
            print('Tombol Lainnya diklik');
          } else if (category != null) {
            // TODO: Navigasi ke halaman detail kategori
            print('Kategori ${category.name} diklik dengan ID: ${category.id}');
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: isOther
                  ? const Icon(Icons.more_horiz, color: Colors.orange)
                  // Menggunakan Image.network untuk memuat gambar dari URL
                  : ClipOval(
                      child: Image.network(
                        category!.image, // Menggunakan URL gambar dari entity
                        fit: BoxFit.cover,
                        // Menambahkan loading & error builder untuk user experience yang lebih baik
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          );
                        },
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              isOther ? 'Lainnya' : category!.name,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// Widget untuk menampilkan efek shimmer saat loading.
  Widget _buildLoadingShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(5, (index) {
          return Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[300], // Warna dasar shimmer
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 8),
              Container(width: 50, height: 10, color: Colors.grey[300]),
            ],
          );
        }),
      ),
    );
    // Untuk efek shimmer yang lebih bagus, uncomment kode ini dan tambahkan package shimmer
    // return Shimmer.fromColors(
    //   baseColor: Colors.grey[300]!,
    //   highlightColor: Colors.grey[100]!,
    //   child: _buildLoadingShimmerContent(),
    // );
  }
}
