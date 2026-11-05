import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/ui.dart';
import '../widgets/app_image.dart';
import '../widgets/quantity_stepper.dart';
import '../widgets/states.dart';
import 'checkout_screen.dart';
import 'login_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key, this.onBrowse});

  final VoidCallback? onBrowse;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && context.read<AuthProvider>().isLoggedIn) {
        context.read<CartProvider>().refresh();
      }
    });
  }

  Future<void> _clearCart() async {
    final confirmed = await confirmDialog(
      context,
      title: context.tr('clearCart'),
      message: context.tr('clearCartConfirm'),
      confirmLabel: context.tr('clearCart'),
      cancelLabel: context.tr('cancel'),
      destructive: true,
    );
    if (!confirmed || !mounted) {
      return;
    }
    try {
      await context.read<CartProvider>().clear();
    } on ApiException catch (error) {
      if (mounted) {
        showAppSnack(context, error.message, error: true);
      }
    }
  }

  Future<void> _updateQuantity(String code, int count) async {
    try {
      await context.read<CartProvider>().updateQuantity(code, count);
    } on ApiException catch (error) {
      if (mounted) {
        showAppSnack(context, error.message, error: true);
      }
    }
  }

  Future<void> _remove(String code) async {
    try {
      await context.read<CartProvider>().remove(code);
      if (mounted) {
        showAppSnack(context, context.tr('removedFromCart'));
      }
    } on ApiException catch (error) {
      if (mounted) {
        showAppSnack(context, error.message, error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cartProvider = context.watch<CartProvider>();
    final cart = cartProvider.cart;
    final currency = context.tr('currency');

    if (!auth.isLoggedIn) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(context.tr('cart'), style: AppText.display(size: 18)),
        ),
        body: EmptyState(
          icon: Icons.lock_outline_rounded,
          title: context.tr('loginRequired'),
          message: context.tr('loginToContinue'),
          actionLabel: context.tr('login'),
          onAction: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(context.tr('cart'), style: AppText.display(size: 18)),
        actions: [
          if (!cart.isEmpty)
            IconButton(
              onPressed: _clearCart,
              tooltip: context.tr('clearCart'),
              icon: const Icon(Icons.delete_sweep_outlined, size: 21),
            ),
        ],
      ),
      body: _buildBody(context, cartProvider, currency),
      bottomNavigationBar: cart.isEmpty
          ? null
          : Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.line)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (cart.discountTotalPrice > 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Text(
                                context.tr('discountTotal'),
                                style: AppText.body(
                                  size: 12,
                                  color: AppColors.muted,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '-${formatPrice(cart.discountTotalPrice, currency)}',
                                style: AppText.body(
                                  size: 12,
                                  weight: FontWeight.w600,
                                  color: AppColors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                context.tr('total'),
                                style: AppText.body(
                                  size: 11,
                                  color: AppColors.muted,
                                ),
                              ),
                              Text(
                                formatPrice(cart.cartTotalPrice, currency),
                                style: AppText.display(size: 18),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: FilledButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const CheckoutScreen(),
                                  ),
                                );
                              },
                              child: Text(context.tr('orderNow')),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    CartProvider cartProvider,
    String currency,
  ) {
    final cart = cartProvider.cart;
    if (cartProvider.loading && cart.isEmpty) {
      return const AppLoader();
    }
    if (cartProvider.error != null && cart.isEmpty) {
      return ErrorView(
        message: cartProvider.error!,
        retryLabel: context.tr('retry'),
        onRetry: cartProvider.refresh,
      );
    }
    if (cart.isEmpty) {
      return EmptyState(
        icon: Icons.shopping_cart_outlined,
        title: context.tr('cartEmpty'),
        message: context.tr('cartEmptyHint'),
        actionLabel: context.tr('continueShopping'),
        onAction: widget.onBrowse,
      );
    }

    return RefreshIndicator(
      color: AppColors.red,
      onRefresh: cartProvider.refresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
        itemCount: cart.items.length,
        separatorBuilder: (_, __) => const Divider(height: 22),
        itemBuilder: (context, index) {
          final item = cart.items[index];
          final product = item.product;
          if (product == null) {
            return const SizedBox.shrink();
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AppImage(
                  path: product.image,
                  width: 78,
                  height: 78,
                  radius: 12,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            product.displayName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.body(
                              size: 14,
                              weight: FontWeight.w500,
                              height: 1.3,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _remove(item.code),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 30,
                            minHeight: 30,
                          ),
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 18,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatPrice(product.finalPrice, currency),
                      style: AppText.body(
                        size: 14,
                        weight: FontWeight.w700,
                        color: product.hasDiscount
                            ? AppColors.red
                            : AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        QuantityStepper(
                          value: item.count,
                          compact: true,
                          max: product.count > 0 ? product.count : 99,
                          onChanged: (value) =>
                              _updateQuantity(item.code, value),
                        ),
                        const Spacer(),
                        Text(
                          formatPrice(item.totalPrice, currency),
                          style: AppText.body(
                            size: 13,
                            weight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
