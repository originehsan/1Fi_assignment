import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/marketplace_repository.dart';
import '../data/mock_marketplace_repository.dart';
import '../models/emi_plan.dart';
import '../models/product.dart';

/// The Marketplace's data source. Consumers depend on [MarketplaceRepository]
/// (the abstract contract), never on [MockMarketplaceRepository] directly —
/// swapping in a real backend later is a one-line change here.
final marketplaceRepositoryProvider = Provider<MarketplaceRepository>((ref) {
  return MockMarketplaceRepository();
});

/// The full, unfiltered product catalog.
final productListProvider = FutureProvider<List<Product>>((ref) {
  return ref.watch(marketplaceRepositoryProvider).fetchProducts();
});

/// EMI plans for a given effective price, keyed by that price.
final emiPlansProvider =
    FutureProvider.autoDispose.family<List<EmiPlan>, int>((ref, effectivePrice) {
  return ref
      .watch(marketplaceRepositoryProvider)
      .fetchEmiPlans(principal: effectivePrice);
});

/// Current Marketplace search text.
final marketplaceSearchQueryProvider = StateProvider.autoDispose<String>((ref) {
  return '';
});

/// Currently selected category filter. `null` means "All".
final selectedCategoryProvider = StateProvider.autoDispose<String?>((ref) {
  return null;
});

/// The sorted, distinct set of categories present in the current product
/// list. Empty while loading or on error.
final availableCategoriesProvider = Provider.autoDispose<List<String>>((ref) {
  final products = ref.watch(productListProvider).valueOrNull;
  if (products == null) {
    return const [];
  }
  final categories = products.map((product) => product.category).toSet().toList();
  categories.sort();
  return categories;
});

/// The product list filtered by [selectedCategoryProvider] and
/// [marketplaceSearchQueryProvider].
final filteredProductsProvider = Provider.autoDispose<AsyncValue<List<Product>>>((ref) {
  final category = ref.watch(selectedCategoryProvider);
  final query = ref.watch(marketplaceSearchQueryProvider).trim().toLowerCase();

  return ref.watch(productListProvider).whenData((products) {
    return products.where((product) {
      final matchesCategory = category == null || product.category == category;
      final matchesQuery = query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.brand.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
  });
});
