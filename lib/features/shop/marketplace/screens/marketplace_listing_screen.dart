import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme/app_theme.dart';
import '../providers/marketplace_provider.dart';
import '../widgets/async_state_views.dart';
import '../widgets/product_grid.dart';
import '../widgets/skeleton_views.dart';
import 'product_detail_screen.dart';

/// The Marketplace tab: search, category filter, and the product grid.
///
/// `ConsumerStatefulWidget` only because this screen owns a
/// `TextEditingController` — a lifecycle-owned UI object, not a business
/// state reason (see rules.md Section 2's `StatefulWidget` exception).
class MarketplaceListingScreen extends ConsumerStatefulWidget {
  const MarketplaceListingScreen({super.key});

  @override
  ConsumerState<MarketplaceListingScreen> createState() => _MarketplaceListingScreenState();
}

class _MarketplaceListingScreenState extends ConsumerState<MarketplaceListingScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(availableCategoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => ref.read(marketplaceSearchQueryProvider.notifier).state = value,
            decoration: InputDecoration(
              hintText: 'Search marketplace...',
              prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.cardBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
            ),
          ),
        ),
        if (categories.isNotEmpty)
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('All'),
                    selected: selectedCategory == null,
                    onSelected: (_) => ref.read(selectedCategoryProvider.notifier).state = null,
                  ),
                ),
                ...categories.map(
                  (category) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: selectedCategory == category,
                      onSelected: (_) =>
                          ref.read(selectedCategoryProvider.notifier).state = category,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 4),
        Expanded(
          child: ref.watch(filteredProductsProvider).when(
                loading: () => const ProductGridSkeleton(),
                error: (error, stackTrace) => ErrorRetryView(
                  message: 'Something went wrong while loading products.',
                  onRetry: () => ref.invalidate(productListProvider),
                ),
                data: (products) {
                  if (products.isEmpty) {
                    final isFiltered = _searchController.text.isNotEmpty || selectedCategory != null;
                    return EmptyView(
                      message: isFiltered
                          ? 'No products match your search or filter.'
                          : 'No products in the marketplace yet.',
                    );
                  }
                  return ProductGrid(
                    products: products,
                    maxNoCostTenureMonths:
                        ref.watch(marketplaceRepositoryProvider).maxNoCostTenureMonths,
                    onProductTap: (product) => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
                    ),
                  );
                },
              ),
        ),
      ],
    );
  }
}
