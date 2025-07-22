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
      // HAPUS: FloatingActionButton dan lokasinya tidak ada lagi di sini
      bottomNavigationBar: BottomAppBar(
        // HAPUS: Properti shape, notchMargin, dan clipBehavior untuk menghilangkan lekukan
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavItem(
              context: context,
              index: 0,
              activeIndex: activeIndex,
              icon: Icons.home,
              onTap: () => _onItemTapped(0, context),
            ),
            _buildNavItem(
              context: context,
              index: 1,
              activeIndex: activeIndex,
              icon: Icons.list_alt,
              onTap: () => _onItemTapped(1, context),
            ),
            // HAPUS: Placeholder SizedBox untuk FAB
            _buildNavItem(
              context: context,
              index: 3,
              activeIndex: activeIndex,
              icon: Icons.card_giftcard,
              onTap: () => _onItemTapped(3, context),
            ),
            _buildNavItem(
              context: context,
              index: 4,
              activeIndex: activeIndex,
              icon: Icons.person_outline,
              onTap: () => _onItemTapped(4, context),
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper dan fungsi lainnya tetap sama
  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required int activeIndex,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return IconButton(
      icon: Icon(icon),
      onPressed: onTap,
      color: activeIndex == index ? Colors.orange : Colors.grey,
      tooltip: null,
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location == InitialRoutes.home) return 0;
    if (location == InitialRoutes.orders) return 1;
    if (location == InitialRoutes.vouchers) return 3;
    if (location == InitialRoutes.profile) return 4;
    return 0;
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
        break; // Dulu untuk FAB, sekarang tidak digunakan
      case 3:
        context.go(InitialRoutes.vouchers);
        break;
      case 4:
        context.go(InitialRoutes.profile);
        break;
    }
  }
}