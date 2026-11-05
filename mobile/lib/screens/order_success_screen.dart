import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../models/cart.dart';
import '../providers/shell_controller.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/status_chip.dart';
import 'orders_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key, required this.order});

  final Cart order;

  @override
  Widget build(BuildContext context) {
    final currency = context.tr('currency');
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 52,
                  color: AppColors.red,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                context.tr('orderSuccess'),
                textAlign: TextAlign.center,
                style: AppText.display(size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr('orderSuccessMessage'),
                textAlign: TextAlign.center,
                style: AppText.body(size: 14, color: AppColors.muted),
              ),
              const SizedBox(height: 26),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.soft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      context.tr('orderNumber'),
                      style: AppText.body(
                        size: 12,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SelectableText(
                      shortCode(order.code).toUpperCase(),
                      style: AppText.display(size: 20, letterSpacing: 1),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        StatusChip(
                          status: order.status,
                          label: context
                              .tr('status${order.status == 0 ? 1 : order.status}'),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          formatPrice(order.cartTotalPrice, currency),
                          style: AppText.body(
                            size: 14,
                            weight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () {
                  context.read<ShellController>().select(0);
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Text(context.tr('backToHome')),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const OrdersScreen()),
                  );
                },
                child: Text(context.tr('myOrders')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
