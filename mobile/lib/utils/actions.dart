import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../models/product.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../screens/login_screen.dart';
import '../services/api_client.dart';
import 'ui.dart';

Future<bool> ensureLoggedIn(BuildContext context) async {
  final auth = context.read<AuthProvider>();
  if (auth.isLoggedIn) {
    return true;
  }
  final result = await Navigator.of(context).push<bool>(
    MaterialPageRoute(builder: (_) => const LoginScreen()),
  );
  if (!context.mounted) {
    return false;
  }
  return result == true || context.read<AuthProvider>().isLoggedIn;
}

Future<void> addProductToCart(
  BuildContext context,
  Product product, {
  int count = 1,
}) async {
  if (!product.inStock) {
    return;
  }
  if (!await ensureLoggedIn(context) || !context.mounted) {
    return;
  }
  try {
    await context.read<CartProvider>().add(product.code, count: count);
    if (context.mounted) {
      showAppSnack(context, context.tr('addedToCart'));
    }
  } on ApiException catch (error) {
    if (context.mounted) {
      showAppSnack(context, error.message, error: true);
    }
  }
}

Future<bool> toggleProductWishlist(
  BuildContext context,
  Product product,
) async {
  if (!await ensureLoggedIn(context) || !context.mounted) {
    return false;
  }
  final wishlist = context.read<WishlistProvider>();
  try {
    if (!wishlist.loaded) {
      await wishlist.refresh();
    }
    final added = await wishlist.toggle(product.code);
    if (context.mounted) {
      showAppSnack(
        context,
        context.tr(added ? 'saved' : 'removedFromWishlist'),
      );
    }
    return added;
  } on ApiException catch (error) {
    if (context.mounted) {
      showAppSnack(context, error.message, error: true);
    }
    return false;
  }
}
