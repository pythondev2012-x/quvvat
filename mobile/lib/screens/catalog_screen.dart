import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../models/category.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/product_feed.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<Category> _categories = [];

  Timer? _debounce;
  String _query = '';
  String _ordering = '-created_at';
  int? _categoryId;
  bool _loadingCategories = true;

  static const Map<String, String> _sortKeys = {
    '-created_at': 'newest',
    'price': 'priceLow',
    '-price': 'priceHigh',
    'name': 'nameAZ',
  };

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final data = await context.read<ApiClient>().get(
        '/categories/',
        query: {'active': 1},
      );
      final raw = data is Map && data['results'] != null
          ? data['results']
          : data;
      if (!mounted) {
        return;
      }
      setState(() {
        _categories
          ..clear()
          ..addAll(Category.listFrom(raw));
      });
    } on ApiException {
      // Kategoriyalar yuklanmasa ham "Barchasi" bilan ishlashda davom etamiz.
    } finally {
      if (mounted) {
        setState(() => _loadingCategories = false);
      }
    }
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted && value != _query) {
        setState(() => _query = value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      context.tr('catalog'),
                      style: AppText.display(size: 24),
                    ),
                  ),
                  PopupMenuButton<String>(
                    initialValue: _ordering,
                    onSelected: (value) =>
                        setState(() => _ordering = value),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    itemBuilder: (context) => [
                      for (final entry in _sortKeys.entries)
                        PopupMenuItem(
                          value: entry.key,
                          child: Row(
                            children: [
                              Icon(
                                _ordering == entry.key
                                    ? Icons.radio_button_checked_rounded
                                    : Icons.radio_button_off_rounded,
                                size: 16,
                                color: _ordering == entry.key
                                    ? AppColors.red
                                    : AppColors.muted,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                context.tr(entry.value),
                                style: AppText.body(size: 13),
                              ),
                            ],
                          ),
                        ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.soft,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.swap_vert_rounded, size: 17),
                          const SizedBox(width: 4),
                          Text(
                            context.tr(_sortKeys[_ordering] ?? 'newest'),
                            style: AppText.body(
                              size: 12,
                              weight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: TextField(
                controller: _searchController,
                onChanged: _onQueryChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: context.tr('searchHint'),
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchController.clear();
                            _onQueryChanged('');
                          },
                          icon: const Icon(Icons.close_rounded, size: 18),
                        ),
                ),
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _categoryChip(
                    label: context.tr('seeAll'),
                    selected: _categoryId == null,
                    onTap: () => setState(() => _categoryId = null),
                  ),
                  if (_loadingCategories)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Center(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.red,
                          ),
                        ),
                      ),
                    ),
                  for (final category in _categories)
                    _categoryChip(
                      label: category.displayName,
                      selected: _categoryId == category.id,
                      onTap: () =>
                          setState(() => _categoryId = category.id),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ProductFeed(
                categoryId: _categoryId,
                query: _query,
                ordering: _ordering,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? AppColors.black : AppColors.soft,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: AppText.body(
              size: 12,
              weight: FontWeight.w500,
              color: selected ? Colors.white : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}
