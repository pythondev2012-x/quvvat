import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../models/paginated.dart';
import '../models/product.dart';
import '../providers/wishlist_provider.dart';
import '../screens/product_detail_screen.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../utils/actions.dart';
import '../utils/ui.dart';
import 'product_card.dart';
import 'states.dart';

class ProductFeed extends StatefulWidget {
  const ProductFeed({
    super.key,
    this.categoryId,
    this.query = '',
    this.ordering = '-created_at',
    this.padding = const EdgeInsets.fromLTRB(16, 0, 16, 20),
  });

  final int? categoryId;
  final String query;
  final String ordering;
  final EdgeInsets padding;

  @override
  State<ProductFeed> createState() => _ProductFeedState();
}

class _ProductFeedState extends State<ProductFeed> {
  final ScrollController _scrollController = ScrollController();
  final List<Product> _items = [];

  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = false;
  int _page = 1;
  int _requestId = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _load(reset: true);
  }

  @override
  void didUpdateWidget(covariant ProductFeed oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categoryId != widget.categoryId ||
        oldWidget.query != widget.query ||
        oldWidget.ordering != widget.ordering) {
      _load(reset: true);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < 320) {
      _loadMore();
    }
  }

  Future<void> _load({required bool reset}) async {
    if (!reset && (_loadingMore || !_hasMore)) {
      return;
    }
    final requestId = ++_requestId;
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
        '/products/',
        query: {
          'page': page,
          'ordering': widget.ordering,
          if (widget.query.trim().isNotEmpty) 'q': widget.query.trim(),
          if (widget.categoryId != null) 'category': widget.categoryId,
        },
      );
      if (!mounted || requestId != _requestId) {
        return;
      }
      final parsed = Paginated<Product>.fromJson(
        data,
        (json) => Product.fromJson(json),
      );
      setState(() {
        if (reset) {
          _items
            ..clear()
            ..addAll(parsed.results);
        } else {
          _items.addAll(parsed.results);
        }
        _hasMore = parsed.hasMore && parsed.results.isNotEmpty;
        _page = page + 1;
        _error = null;
      });
    } on ApiException catch (error) {
      if (mounted && requestId == _requestId) {
        setState(() => _error = error.message);
        if (!reset) {
          showAppSnack(context, error.message, error: true);
        }
      }
    } finally {
      if (mounted && requestId == _requestId) {
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
    if (_loading && _items.isEmpty) {
      return const AppLoader();
    }
    if (_error != null && _items.isEmpty) {
      return ErrorView(
        message: _error!,
        retryLabel: context.tr('retry'),
        onRetry: () => _load(reset: true),
      );
    }
    if (_items.isEmpty) {
      return EmptyState(
        icon: Icons.search_off_rounded,
        title: context.tr('noProducts'),
      );
    }

    final wishlist = context.watch<WishlistProvider>();
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 900 ? 4 : (width >= 640 ? 3 : 2);

    return RefreshIndicator(
      color: AppColors.red,
      onRefresh: () => _load(reset: true),
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: widget.padding,
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.63,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final product = _items[index];
                  return ProductCard(
                    product: product,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(product: product),
                      ),
                    ),
                    onAdd: () => addProductToCart(context, product),
                    isFavorite: wishlist.contains(product.code),
                    onFavorite: () => toggleProductWishlist(context, product),
                  );
                },
                childCount: _items.length,
              ),
            ),
          ),
          if (_loadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(bottom: 22),
                child: AppLoader(size: 22),
              ),
            ),
        ],
      ),
    );
  }
}
