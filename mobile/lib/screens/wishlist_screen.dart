import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../providers/wishlist_provider.dart';
import '../theme/app_theme.dart';
import '../utils/actions.dart';
import '../utils/ui.dart';
import '../widgets/product_card.dart';
import '../widgets/states.dart';
import 'product_detail_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<WishlistProvider>().refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<WishlistProvider>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(context.tr('wishlist'), style: AppText.display(size: 18)),
      ),
      body: _buildBody(context, wishlist),
    );
  }

  Widget _buildBody(BuildContext context, WishlistProvider wishlist) {
    if (wishlist.loading && wishlist.items.isEmpty) {
      return const AppLoader();
    }
    if (wishlist.error != null && wishlist.items.isEmpty) {
      return ErrorView(
        message: wishlist.error!,
        retryLabel: context.tr('retry'),
        onRetry: wishlist.refresh,
      );
    }
    if (wishlist.items.isEmpty) {
      return EmptyState(
        icon: Icons.favorite_border_rounded,
        title: context.tr('wishlistEmpty'),
      );
    }

    return RefreshIndicator(
      color: AppColors.red,
      onRefresh: wishlist.refresh,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.63,
        ),
        itemCount: wishlist.items.length,
        itemBuilder: (context, index) {
          final product = wishlist.items[index].product;
          if (product == null) {
            return const SizedBox.shrink();
          }
          return ProductCard(
            product: product,
            isFavorite: true,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProductDetailScreen(product: product),
                ),
              );
            },
            onAdd: () => addProductToCart(context, product),
            onFavorite: () async {
              try {
                await wishlist.remove(product.code);
                if (context.mounted) {
                  showAppSnack(context, context.tr('removedFromWishlist'));
                }
              } catch (error) {
                if (context.mounted) {
                  showAppSnack(context, error.toString(), error: true);
                }
              }
            },
          );
        },
      ),
    );
  }
}
