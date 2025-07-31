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
      bottomNavigationBar: BottomAppBar(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavItem(
              context: context,
              index: 0,
              activeIndex: activeIndex,
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              onTap: () => _onItemTapped(0, context),
            ),
            _buildNavItem(
              context: context,
              index: 1,
              activeIndex: activeIndex,
              icon: Icons.list_alt_outlined,
              activeIcon: Icons.list_alt,
              onTap: () => _onItemTapped(1, context),
            ),
            _buildNavItem(
              context: context,
              index: 2,
              activeIndex: activeIndex,
              icon: Icons.favorite_border,
              activeIcon: Icons.favorite,
              onTap: () => _onItemTapped(2, context),
            ),
            _buildNavItem(
              context: context,
              index: 3,
              activeIndex: activeIndex,
              icon: Icons.card_giftcard_outlined,
              activeIcon: Icons.card_giftcard,
              onTap: () => _onItemTapped(3, context),
            ),
            _buildNavItem(
              context: context,
              index: 4,
              activeIndex: activeIndex,
              icon: Icons.person_outline,
              activeIcon: Icons.person,
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
    required VoidCallback onTap,
  }) {
    final bool isActive = activeIndex == index;
    return IconButton(
      icon: Icon(isActive ? activeIcon : icon),
      onPressed: onTap,
      color: isActive ? Colors.orange : Colors.grey,
      tooltip: null,
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