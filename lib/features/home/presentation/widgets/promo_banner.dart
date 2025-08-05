import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nusantara_mobile/features/home/domain/entities/banner_entity.dart';

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
    // Hanya mulai timer jika ada lebih dari 1 gambar
    if (widget.banners.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
        if (!mounted) return;
        int nextPage = _currentPage < widget.banners.length - 1
            ? _currentPage + 1
            : 0;
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

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          // --- PERUBAHAN DARI SIZEDBOX KE ASPECTRATIO ---
          AspectRatio(
            aspectRatio: 16 / 6,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.banners.length,
              onPageChanged: (int page) => setState(() => _currentPage = page),
              itemBuilder: (context, index) {
                final banner = widget.banners[index];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(banner.photo, fit: BoxFit.cover),
                );
              },
            ),
          ),
          // --- AKHIR PERUBAHAN ---
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
                  color: _currentPage == index
                      ? Colors.orange
                      : Colors.grey.shade400,
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
