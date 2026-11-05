import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../models/product.dart';
import '../providers/wishlist_provider.dart';
import '../theme/app_theme.dart';
import '../utils/actions.dart';
import '../utils/formatters.dart';
import '../widgets/app_image.dart';
import '../widgets/quantity_stepper.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final currency = context.tr('currency');
    final wishlist = context.watch<WishlistProvider>();
    final isFavorite = wishlist.contains(product.code);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.black,
                ),
                icon: const Icon(Icons.arrow_back_rounded, size: 20),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  onPressed: () => toggleProductWishlist(context, product),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: isFavorite
                        ? AppColors.red
                        : AppColors.black,
                  ),
                  icon: Icon(
                    isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: 20,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  AppImage(path: product.image),
                  if (product.hasDiscount)
                    Positioned(
                      left: 16,
                      bottom: 18,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '-${product.discountPercent}%',
                          style: AppText.body(
                            size: 13,
                            weight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.category != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.soft,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        product.category!.displayName,
                        style: AppText.body(
                          size: 11,
                          weight: FontWeight.w500,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Text(
                    product.displayName,
                    style: AppText.display(size: 22, height: 1.25),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatPrice(product.finalPrice, currency),
                        style: AppText.display(
                          size: 24,
                          color: product.hasDiscount
                              ? AppColors.red
                              : AppColors.black,
                        ),
                      ),
                      if (product.hasDiscount) ...[
                        const SizedBox(width: 10),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Text(
                            formatPrice(product.price, currency),
                            style: AppText.body(
                              size: 14,
                              color: AppColors.muted,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: product.inStock
                              ? AppColors.green
                              : AppColors.muted,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        product.inStock
                            ? '${context.tr('inStock')} · ${product.count}'
                            : context.tr('outOfStock'),
                        style: AppText.body(
                          size: 12,
                          weight: FontWeight.w500,
                          color: product.inStock
                              ? AppColors.green
                              : AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        context.tr('quantity'),
                        style: AppText.body(
                          size: 14,
                          weight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      QuantityStepper(
                        value: _quantity,
                        max: product.count > 0 ? product.count : 1,
                        onChanged: (value) => setState(() => _quantity = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text(
                    context.tr('description'),
                    style: AppText.display(size: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.displayDescription.trim().isEmpty
                        ? '—'
                        : product.displayDescription,
                    style: AppText.body(
                      size: 14,
                      color: AppColors.muted,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.line)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
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
                      formatPrice(product.finalPrice * _quantity, currency),
                      style: AppText.display(size: 17),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: product.inStock
                        ? () => addProductToCart(
                              context,
                              product,
                              count: _quantity,
                            )
                        : null,
                    icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                    label: Text(
                      product.inStock
                          ? context.tr('addToCart')
                          : context.tr('outOfStock'),
                    ),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      disabledBackgroundColor: AppColors.line,
                      disabledForegroundColor: AppColors.muted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
