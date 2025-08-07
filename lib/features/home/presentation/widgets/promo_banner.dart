// file: features/home/presentation/widgets/promo_banner.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // PERBAIKAN: Import GoRouter
import 'package:nusantara_mobile/features/home/domain/entities/banner_entity.dart';
import 'package:nusantara_mobile/routes/initial_routes.dart'; // PERBAIKAN: Import rute Anda

class PromoBanner extends StatefulWidget {
  final List<BannerEntity> banners;
  const PromoBanner({super.key, required this.banners});

  @override
  State<PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends State<PromoBanner> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.banners.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
        if (!mounted) return;
        int nextPage = _currentPage < widget.banners.length - 1 ? _currentPage + 1 : 0;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // PERBAIKAN: Ubah metode navigasi menggunakan GoRouter
  void _onBannerTap(BannerEntity banner) {
    // Cukup beri tahu router untuk pergi ke alamat detail dengan ID banner.
    // Tidak perlu mengirim bannerPhotoUrl lagi.
    context.push('${InitialRoutes.bannerDetail}/${banner.id}');
    
  }
  

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 6,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.banners.length,
              onPageChanged: (int page) => setState(() => _currentPage = page),
              itemBuilder: (context, index) {
                final banner = widget.banners[index];
                return GestureDetector(
                  onTap: () => _onBannerTap(banner),
                  child: Hero(
                    // Tag harus tetap ada untuk animasi yang mulus
                    tag: 'banner_image_${banner.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(banner.photo, fit: BoxFit.cover),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.banners.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 5),
                height: 8,
                width: _currentPage == index ? 24 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == index ? Colors.orange : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}