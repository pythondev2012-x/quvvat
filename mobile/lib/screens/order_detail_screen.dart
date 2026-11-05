import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../models/cart.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/app_image.dart';
import '../widgets/status_chip.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key, required this.order});

  final Cart order;

  @override
  Widget build(BuildContext context) {
    final currency = context.tr('currency');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          '${context.tr('orderNumber')} #${shortCode(order.code).toUpperCase()}',
          style: AppText.display(size: 16),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.soft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('orderStatus'),
                        style: AppText.body(
                          size: 11,
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      StatusChip(
                        status: order.status,
                        label: context.tr(
                          'status${order.status == 0 ? 1 : order.status}',
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        formatDate(order.date),
                        style: AppText.body(
                          size: 12,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      context.tr('total'),
                      style: AppText.body(
                        size: 11,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatPrice(order.cartTotalPrice, currency),
                      style: AppText.display(size: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '${order.countProduct} ${context.tr('itemCount')}',
            style: AppText.display(size: 16),
          ),
          const SizedBox(height: 10),
          for (final item in order.items)
            if (item.product != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    AppImage(
                      path: item.product!.image,
                      width: 58,
                      height: 58,
                      radius: 10,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product!.displayName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.body(
                              size: 13,
                              weight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${formatPrice(item.product!.finalPrice, currency)} × ${item.count}',
                            style: AppText.body(
                              size: 11,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formatPrice(item.totalPrice, currency),
                      style: AppText.body(
                        size: 13,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
          const Divider(height: 26),
          if (order.discountTotalPrice > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(
                    context.tr('discountTotal'),
                    style: AppText.body(
                      size: 13,
                      color: AppColors.muted,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '-${formatPrice(order.discountTotalPrice, currency)}',
                    style: AppText.body(
                      size: 13,
                      weight: FontWeight.w600,
                      color: AppColors.red,
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Text(
                context.tr('total'),
                style: AppText.body(size: 14, weight: FontWeight.w700),
              ),
              const Spacer(),
              Text(
                formatPrice(order.cartTotalPrice, currency),
                style: AppText.display(size: 19),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
