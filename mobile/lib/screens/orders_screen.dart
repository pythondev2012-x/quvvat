import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../models/cart.dart';
import '../models/paginated.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/states.dart';
import '../widgets/status_chip.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<Cart> _orders = [];

  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = false;
  int _page = 1;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _load(reset: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < 240) {
      _loadMore();
    }
  }

  Future<void> _load({required bool reset}) async {
    if (!reset && (_loadingMore || !_hasMore)) {
      return;
    }
    final page = reset ? 1 : _page;
    setState(() {
      if (reset) {
        _loading = true;
        _error = null;
      } else {
        _loadingMore = true;
      }
    });
    try {
      final data = await context.read<ApiClient>().get(
        '/orders/',
        query: {'page': page},
      );
      final parsed = Paginated<Cart>.fromJson(
        data,
        (json) => Cart.fromJson(json),
      );
      if (!mounted) {
        return;
      }
      setState(() {
        if (reset) {
          _orders
            ..clear()
            ..addAll(parsed.results);
        } else {
          _orders.addAll(parsed.results);
        }
        _hasMore = parsed.hasMore && parsed.results.isNotEmpty;
        _page = page + 1;
      });
    } on ApiException catch (error) {
      if (mounted) {
        setState(() => _error = error.message);
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadingMore = false;
        });
      }
    }
  }

  void _loadMore() {
    if (_hasMore && !_loadingMore && !_loading) {
      _load(reset: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = context.tr('currency');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(context.tr('myOrders'), style: AppText.display(size: 18)),
      ),
      body: _buildBody(context, currency),
    );
  }

  Widget _buildBody(BuildContext context, String currency) {
    if (_loading && _orders.isEmpty) {
      return const AppLoader();
    }
    if (_error != null && _orders.isEmpty) {
      return ErrorView(
        message: _error!,
        retryLabel: context.tr('retry'),
        onRetry: () => _load(reset: true),
      );
    }
    if (_orders.isEmpty) {
      return EmptyState(
        icon: Icons.receipt_long_outlined,
        title: context.tr('noOrders'),
      );
    }

    return RefreshIndicator(
      color: AppColors.red,
      onRefresh: () => _load(reset: true),
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        itemCount: _orders.length + (_loadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index >= _orders.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: AppLoader(size: 22),
            );
          }
          final order = _orders[index];
          return Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => OrderDetailScreen(order: order),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(14),
              child: Ink(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.line),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${context.tr('orderCode')} #${shortCode(order.code).toUpperCase()}',
                          style: AppText.body(
                            size: 13,
                            weight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        StatusChip(
                          status: order.status,
                          label: context.tr(
                            'status${order.status == 0 ? 1 : order.status}',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      formatDate(order.date),
                      style: AppText.body(
                        size: 11,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          '${order.countProduct} ${context.tr('itemCount')}',
                          style: AppText.body(
                            size: 12,
                            color: AppColors.muted,
                          ),
                        ),
                        const Spacer(),
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
            ),
          );
        },
      ),
    );
  }
}
