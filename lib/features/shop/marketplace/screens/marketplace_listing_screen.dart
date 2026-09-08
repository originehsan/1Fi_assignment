import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/marketplace_provider.dart';
import '../widgets/async_state_views.dart';
import '../widgets/product_detail_sheet.dart';
import '../widgets/product_list.dart';
import '../widgets/skeleton_views.dart';

/// The Marketplace tab: category filter and the product list.
///
/// The search bar that used to live here is now owned by `ShopPage`
/// and shared across all three Shop tabs — this screen only reads
/// [marketplaceSearchQueryProvider], it doesn't own the `TextField` that
/// writes to it. With no controller left to own, this is a plain
/// `ConsumerWidget`.
class MarketplaceListingScreen extends ConsumerWidget {
  const MarketplaceListingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(availableCategoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Column(
      children: [
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
                loading: () => const ProductListSkeleton(),
                error: (error, stackTrace) => ErrorRetryView(
                  message: 'Something went wrong while loading products.',
                  onRetry: () => ref.invalidate(productListProvider),
                ),
                data: (products) {
                  if (products.isEmpty) {
                    final isFiltered = ref.watch(marketplaceSearchQueryProvider).isNotEmpty ||
                        selectedCategory != null;
                    return EmptyView(
                      message: isFiltered
                          ? 'No products match your search or filter.'
                          : 'No products in the marketplace yet.',
                    );
                  }
                  return ProductList(
                    products: products,
                    maxNoCostTenureMonths:
                        ref.watch(marketplaceRepositoryProvider).maxNoCostTenureMonths,
                    onProductTap: (product) => showProductDetailSheet(context, product),
                  );
                },
              ),
        ),
      ],
    );
  }
}
