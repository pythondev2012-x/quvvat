import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'app_image.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onAdd,
    this.isFavorite = false,
    this.onFavorite,
  });

  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final bool isFavorite;
  final VoidCallback? onFavorite;

  @override
  Widget build(BuildContext context) {
    final currency = context.tr('currency');
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: AppImage(
                        path: product.image,
                        radius: 13,
                        fit: BoxFit.cover,
                      ),
                    ),
                    if (product.hasDiscount)
                      Positioned(
                        left: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.red,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            '-${product.discountPercent}%',
                            style: AppText.body(
                              size: 11,
                              weight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    if (onFavorite != null)
                      Positioned(
                        right: 4,
                        top: 4,
                        child: IconButton(
                          onPressed: onFavorite,
                          visualDensity: VisualDensity.compact,
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.92),
                            minimumSize: const Size(34, 34),
                            padding: EdgeInsets.zero,
                          ),
                          icon: Icon(
                            isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 18,
                            color: isFavorite ? AppColors.red : AppColors.ink,
                          ),
                        ),
                      ),
                    if (!product.inStock)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.66),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.black,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              context.tr('outOfStock'),
                              style: AppText.body(
                                size: 11,
                                weight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(9, 8, 9, 9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.body(
                        size: 12.5,
                        weight: FontWeight.w500,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (product.hasDiscount)
                                Text(
                                  formatPrice(product.price, currency),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppText.body(
                                    size: 10,
                                    color: AppColors.muted,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              Text(
                                formatPrice(product.finalPrice, currency),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppText.body(
                                  size: 13,
                                  weight: FontWeight.w700,
                                  color: product.hasDiscount
                                      ? AppColors.red
                                      : AppColors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: IconButton(
                            onPressed: product.inStock ? onAdd : null,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            visualDensity: VisualDensity.compact,
                            style: IconButton.styleFrom(
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              backgroundColor: product.inStock
                                  ? AppColors.black
                                  : AppColors.line,
                              foregroundColor: Colors.white,
                              disabledForegroundColor: AppColors.muted,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(9),
                              ),
                            ),
                            icon: const Icon(
                              Icons.add_shopping_cart_rounded,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
