import 'package:flutter/material.dart';
import 'package:nusantara_mobile/features/shop/domain/entities/shop_entity.dart';
import 'package:nusantara_mobile/features/shop/presentation/widgets/shop_info_card.dart';

class ShopDetailHeader extends StatefulWidget {
  final ShopEntity shop;
  final ValueChanged<String> onSearchChanged;

  const ShopDetailHeader({
    super.key,
    required this.shop,
    required this.onSearchChanged,
  });

  @override
  State<ShopDetailHeader> createState() => _ShopDetailHeaderState();
}

class _ShopDetailHeaderState extends State<ShopDetailHeader> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        widget.onSearchChanged('');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive header height
    final headerHeight = screenHeight < 700 ? 200.0 : 230.0;

    // Responsive card top position
    final cardTopPosition = screenHeight < 700
        ? headerHeight * 0.65
        : headerHeight * 0.55;

    // Responsive title font size
    final titleFontSize = screenWidth < 360 ? 18.0 : 22.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Background merah
        Container(
          height: headerHeight,
          decoration: const BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(50)),
          ),
          padding: EdgeInsets.only(top: topPad + 12, left: 12, right: 12),
          child: _isSearching
              ? _buildSearchBar()
              : _buildTitleBar(titleFontSize),
        ),
        // Card info toko
        Positioned(
          top: cardTopPosition,
          left: 16,
          right: 16,
          child: ShopInfoCard(shop: widget.shop),
        ),
      ],
    );
  }

  Widget _buildTitleBar(double titleFontSize) {
    return Stack(
      children: [
        // Back button
        Positioned(
          top: 0,
          left: 0,
          child: IconButton(
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        // Search button
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            onPressed: _toggleSearch,
            icon: const Icon(Icons.search, color: Colors.white),
          ),
        ),
        // Judul toko
        Positioned(
          top: 4,
          left: 48,
          right: 48,
          child: Text(
            widget.shop.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: IconButton(
            onPressed: _toggleSearch,
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: widget.onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search your favorite menu',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey[400],
                  size: 20,
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.close, color: Colors.grey[400], size: 20),
                  onPressed: () {
                    _searchController.clear();
                    widget.onSearchChanged('');
                  },
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
