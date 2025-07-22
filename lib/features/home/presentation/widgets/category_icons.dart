import 'package:flutter/material.dart';

class CategoryIcons extends StatelessWidget {
  const CategoryIcons({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildCategoryItem('Bolu', 'assets/images/icon_bolu.png'),
          _buildCategoryItem('Pancake', 'assets/images/icon_pancake.png'),
          _buildCategoryItem('Minuman', 'assets/images/icon_minuman.png'),
          _buildCategoryItem('Snack', 'assets/images/icon_snack.png'),
          _buildCategoryItem('Lainnya', null, isOther: true),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String title, String? iconPath, {bool isOther = false}) {
    return Column(
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
              )
            ],
          ),
          child: isOther
              ? const Icon(Icons.more_horiz, color: Colors.orange)
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(iconPath!),
                ),
        ),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}