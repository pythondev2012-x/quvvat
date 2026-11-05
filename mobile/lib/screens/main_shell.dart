import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../providers/cart_provider.dart';
import '../providers/shell_controller.dart';
import '../theme/app_theme.dart';
import 'cart_screen.dart';
import 'catalog_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ShellController>();
    final cart = context.watch<CartProvider>();
    final count = cart.totalQuantity;

    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: controller.index,
        children: [
          const HomeScreen(),
          const CatalogScreen(),
          CartScreen(onBrowse: () => controller.select(1)),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.line)),
        ),
        child: NavigationBar(
          selectedIndex: controller.index,
          onDestinationSelected: controller.select,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded),
              label: context.tr('home'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.grid_view_outlined),
              selectedIcon: const Icon(Icons.grid_view_rounded),
              label: context.tr('catalog'),
            ),
            NavigationDestination(
              icon: Badge.count(
                count: count,
                isLabelVisible: count > 0,
                backgroundColor: AppColors.red,
                child: const Icon(Icons.shopping_cart_outlined),
              ),
              selectedIcon: Badge.count(
                count: count,
                isLabelVisible: count > 0,
                backgroundColor: AppColors.red,
                child: const Icon(Icons.shopping_cart_rounded),
              ),
              label: context.tr('cart'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline_rounded),
              selectedIcon: const Icon(Icons.person_rounded),
              label: context.tr('profile'),
            ),
          ],
        ),
      ),
    );
  }
}
