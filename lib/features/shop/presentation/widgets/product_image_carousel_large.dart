import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductImageCarouselLarge extends StatefulWidget {
  final List<String> images;
  final double height;

  const ProductImageCarouselLarge({
    super.key,
    required this.images,
    this.height = 250,
  });

  @override
  State<ProductImageCarouselLarge> createState() =>
      _ProductImageCarouselLargeState();
}

class _ProductImageCarouselLargeState extends State<ProductImageCarouselLarge> {
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

    return Stack(
      children: [
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
