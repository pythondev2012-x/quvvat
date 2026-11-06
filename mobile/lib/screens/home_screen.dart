import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../models/banner_item.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../models/product_section.dart';
import '../providers/settings_provider.dart';
import '../providers/wishlist_provider.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../utils/actions.dart';
import '../utils/formatters.dart';
import '../widgets/app_image.dart';
import '../widgets/app_logo.dart';
import '../widgets/language_sheet.dart';
import '../widgets/product_card.dart';
import '../widgets/section_header.dart';
import '../widgets/states.dart';
import 'product_detail_screen.dart';
import 'product_list_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  final List<BannerItem> _banners = [];
  final List<Category> _categories = [];
  final List<ProductSection> _sections = [];

  bool _loading = true;
  String? _error;
  int _bannerIndex = 0;
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  /// Bannerlar avtomatik aylanishi (5 soniya).
  void _restartBannerTimer() {
    _bannerTimer?.cancel();
    if (_banners.length < 2) {
      return;
    }
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_pageController.hasClients) {
        return;
      }
      final nextIndex = (_bannerIndex + 1) % _banners.length;
      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        context.read<ApiClient>().get('/banners/'),
        context.read<ApiClient>().get(
          '/categories/',
          query: {'active': 1},
        ),
        context.read<ApiClient>().get('/product-sections/'),
      ]);
      if (!mounted) {
        return;
      }
      final bannersData = results[0];
      final categoriesData = results[1];
      final sectionsData = results[2];

      final bannersRaw =
          bannersData is Map && bannersData['results'] != null
              ? bannersData['results']
              : bannersData;
      final categoriesRaw =
          categoriesData is Map && categoriesData['results'] != null
              ? categoriesData['results']
              : categoriesData;
      final sectionsRaw =
          sectionsData is Map && sectionsData['results'] != null
              ? sectionsData['results']
              : sectionsData;

      setState(() {
        _banners
          ..clear()
          ..addAll(BannerItem.listFrom(bannersRaw));
        _categories
          ..clear()
          ..addAll(Category.listFrom(categoriesRaw));
        _sections
          ..clear()
          ..addAll(ProductSection.listFrom(sectionsRaw));
      });
      _restartBannerTimer();
    } on ApiException catch (error) {
      if (mounted) {
        setState(() => _error = error.message);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _error = error.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _openProduct(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(product: product),
      ),
    );
  }

  void _openSearch() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductListScreen(
          title: context.tr('search'),
          searchable: true,
        ),
      ),
    );
  }

  void _openCategory(Category category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductListScreen(
          title: category.displayName,
          categoryId: category.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<WishlistProvider>();
    final hasContent =
        _banners.isNotEmpty || _categories.isNotEmpty || _sections.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        color: AppColors.red,
        onRefresh: _load,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _header(context)),
            SliverToBoxAdapter(child: _searchBar(context)),
            if (_loading && !hasContent)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 80),
                  child: AppLoader(),
                ),
              )
            else if (_error != null && !hasContent)
              SliverFillRemaining(
                hasScrollBody: false,
                child: ErrorView(
                  message: _error!,
                  retryLabel: context.tr('retry'),
                  onRetry: _load,
                ),
              )
            else ...[
              if (_banners.isNotEmpty)
                SliverToBoxAdapter(child: _bannersSection()),
              if (_categories.isNotEmpty)
                SliverToBoxAdapter(child: _categoriesSection()),
              for (final section in _sections) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                    child: SectionHeader(
                      title: section.category.displayName,
                      actionLabel: context.tr('seeAll'),
                      onAction: () => _openCategory(section.category),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 256,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: section.products.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final product = section.products[index];
                        return SizedBox(
                          width: 158,
                          child: ProductCard(
                            product: product,
                            onTap: () => _openProduct(product),
                            onAdd: () => addProductToCart(context, product),
                            isFavorite: wishlist.contains(product.code),
                            onFavorite: () =>
                                toggleProductWishlist(context, product),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
              if (_sections.isEmpty && _error == null && !_loading)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.inventory_2_outlined,
                    title: context.tr('noProducts'),
                    actionLabel: context.tr('retry'),
                    onAction: _load,
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    context.tr('deliveryNote'),
                    textAlign: TextAlign.center,
                    style: AppText.body(size: 11, color: AppColors.muted),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
        child: Row(
          children: [
            const AppLogo(size: 30),
            const Spacer(),
            InkWell(
              onTap: () => showLanguageSheet(context),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.soft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.language_rounded, size: 16),
                    const SizedBox(width: 5),
                    Text(
                      context
                          .watch<SettingsProvider>()
                          .language
                          .toUpperCase(),
                      style: AppText.body(
                        size: 12,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
              icon: const Icon(Icons.settings_outlined, size: 21),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Material(
        color: AppColors.soft,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: _openSearch,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, size: 19, color: AppColors.muted),
                const SizedBox(width: 9),
                Text(
                  context.tr('searchHint'),
                  style: AppText.body(size: 13, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bannersSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        children: [
          SizedBox(
            height: 146,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _banners.length,
              onPageChanged: (index) {
                setState(() => _bannerIndex = index);
                _restartBannerTimer();
              },
              itemBuilder: (context, index) {
                final banner = _banners[index];
                return Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 16 : 5,
                    right: index == _banners.length - 1 ? 16 : 5,
                  ),
                  child: GestureDetector(
                    onTap: banner.product == null
                        ? null
                        : () => _openProduct(banner.product!),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          AppImage(path: banner.image),
                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black87],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 16,
                            right: 16,
                            bottom: 14,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  banner.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppText.display(
                                    size: 15.5,
                                    color: Colors.white,
                                  ),
                                ),
                                if (banner.product != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    formatPrice(
                                      banner.product!.finalPrice,
                                      context.tr('currency'),
                                    ),
                                    style: AppText.body(
                                      size: 12,
                                      weight: FontWeight.w600,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_banners.length > 1) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _banners.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _bannerIndex ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == _bannerIndex
                          ? AppColors.red
                          : AppColors.line,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _categoriesSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SectionHeader(title: context.tr('categories')),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 88,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final category = _categories[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProductListScreen(
                          title: category.displayName,
                          categoryId: category.id,
                        ),
                      ),
                    );
                  },
                  child: SizedBox(
                    width: 70,
                    child: Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.soft,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.line),
                          ),
                          child: ClipOval(
                            child: AppImage(path: category.logo),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          category.displayName,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.body(
                            size: 10,
                            weight: FontWeight.w500,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
