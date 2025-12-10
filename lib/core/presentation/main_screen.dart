// Salin dan ganti seluruh isi file main_screen.dart dengan kode ini

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScreen({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final int activeIndex = navigationShell.currentIndex;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, -2),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              context: context,
              index: 0,
              activeIndex: activeIndex,
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              label: "Beranda",
              onTap: () => _onItemTapped(0),
            ),
            _buildNavItem(
              context: context,
              index: 1,
              activeIndex: activeIndex,
              icon: Icons.list_alt_outlined,
              activeIcon: Icons.list_alt,
              label: "Pesanan",
              onTap: () => _onItemTapped(1),
            ),
            _buildNavItem(
              context: context,
              index: 2,
              activeIndex: activeIndex,
              icon: Icons.favorite_border,
              activeIcon: Icons.favorite,
              label: "Favorit",
              onTap: () => _onItemTapped(2),
            ),
            _buildNavItem(
              context: context,
              index: 3,
              activeIndex: activeIndex,
              icon: Icons.card_giftcard_outlined,
              activeIcon: Icons.card_giftcard,
              label: "Reward",
              onTap: () => _onItemTapped(3),
            ),
            _buildNavItem(
              context: context,
              index: 4,
              activeIndex: activeIndex,
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: "Profil",
              onTap: () => _onItemTapped(4),
            ),
          ],
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required int activeIndex,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required VoidCallback onTap,
  }) {
    final bool isActive = activeIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
          decoration: BoxDecoration(
            color:
                isActive ? Colors.orange.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                color: isActive ? Colors.orange : Colors.grey[500],
                size: 26,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? Colors.orange : Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}