import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nusantara_mobile/routes/initial_routes.dart';

class MainScreen extends StatelessWidget {
  final Widget child;
  const MainScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final int activeIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: child,
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
              onTap: () => _onItemTapped(0, context),
            ),
            _buildNavItem(
              context: context,
              index: 1,
              activeIndex: activeIndex,
              icon: Icons.list_alt_outlined,
              activeIcon: Icons.list_alt,
              label: "Pesanan",
              onTap: () => _onItemTapped(1, context),
            ),
            _buildNavItem(
              context: context,
              index: 2,
              activeIndex: activeIndex,
              icon: Icons.favorite_border,
              activeIcon: Icons.favorite,
              label: "Favorit",
              onTap: () => _onItemTapped(2, context),
            ),
            _buildNavItem(
              context: context,
              index: 3,
              activeIndex: activeIndex,
              icon: Icons.card_giftcard_outlined,
              activeIcon: Icons.card_giftcard,
              label: "Reward",
              onTap: () => _onItemTapped(3, context),
            ),
            _buildNavItem(
              context: context,
              index: 4,
              activeIndex: activeIndex,
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: "Profil",
              onTap: () => _onItemTapped(4, context),
            ),
          ],
        ),
      ),
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
            color: isActive ? Colors.orange.withOpacity(0.12) : Colors.transparent,
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

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location == InitialRoutes.home) return 0;
    if (location == InitialRoutes.orders) return 1;
    if (location == InitialRoutes.favorites) return 2;
    if (location == InitialRoutes.vouchers) return 3;
    if (location == InitialRoutes.profile) return 4;
    return 0; // Default ke home
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(InitialRoutes.home);
        break;
      case 1:
        context.go(InitialRoutes.orders);
        break;
      case 2:
        context.go(InitialRoutes.favorites);
        break;
      case 3:
        context.go(InitialRoutes.vouchers);
        break;
      case 4:
        context.go(InitialRoutes.profile);
        break;
    }
  }
}