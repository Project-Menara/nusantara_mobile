import 'package:flutter/material.dart';
import 'package:nusantara_mobile/features/shop/domain/entities/shop_entity.dart';
import 'package:nusantara_mobile/features/shop/presentation/widgets/shop_image_carousel.dart';

class ShopInfoCard extends StatelessWidget {
  final ShopEntity shop;

  const ShopInfoCard({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    final List<String> imagesToShow = shop.shopImages.isNotEmpty
        ? shop.shopImages
        : (shop.cover.isNotEmpty ? [shop.cover] : []);

    final screenWidth = MediaQuery.of(context).size.width;
    final cardPadding = screenWidth < 360 ? 12.0 : 16.0;

    return Container(
      margin: EdgeInsets.fromLTRB(16, cardPadding, 16, 0),
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imagesToShow.isNotEmpty) ...[
            ShopImageCarousel(images: imagesToShow),
            const SizedBox(height: 16),
          ],
          Text(
            shop.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            shop.fullAddress,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
