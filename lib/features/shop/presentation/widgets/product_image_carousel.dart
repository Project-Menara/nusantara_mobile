import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductImageCarousel extends StatefulWidget {
  final List<String> images;
  final double width;
  final double height;
  final Widget? overlayWidget;

  const ProductImageCarousel({
    super.key,
    required this.images,
    this.width = 100,
    this.height = 100,
    this.overlayWidget,
  });

  @override
  State<ProductImageCarousel> createState() => _ProductImageCarouselState();
}

class _ProductImageCarouselState extends State<ProductImageCarousel> {
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
    if (widget.images.isEmpty || widget.images.length == 1) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: widget.images.isEmpty
                ? Container(
                    width: widget.width,
                    height: widget.height,
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey[400],
                    ),
                  )
                : CachedNetworkImage(
                    imageUrl: widget.images.first,
                    width: widget.width,
                    height: widget.height,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: widget.width,
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
                      width: widget.width,
                      height: widget.height,
                      color: Colors.grey[200],
                      child: Icon(Icons.broken_image, color: Colors.grey[400]),
                    ),
                  ),
          ),
          if (widget.overlayWidget != null) widget.overlayWidget!,
        ],
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: widget.width,
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
                  width: widget.width,
                  height: widget.height,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: widget.width,
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
                    width: widget.width,
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
          bottom: 6,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.images.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: _currentPage == index ? 16 : 6,
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: _currentPage == index
                      ? Colors.orange
                      : Colors.white.withOpacity(0.6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (widget.overlayWidget != null) widget.overlayWidget!,
      ],
    );
  }
}
