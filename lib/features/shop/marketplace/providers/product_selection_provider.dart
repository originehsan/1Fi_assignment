import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/emi_plan.dart';
import '../models/product_variant.dart';

/// A user's in-progress selection for a single product's detail screen:
/// which variant and which EMI plan they've chosen, if any.
class ProductSelectionState {
  const ProductSelectionState({
    this.selectedVariant,
    this.selectedEmiPlan,
  });

  final ProductVariant? selectedVariant;
  final EmiPlan? selectedEmiPlan;

  /// [clearEmiPlan] explicitly nulls out [selectedEmiPlan], distinct from
  /// simply not passing [selectedEmiPlan] (which keeps the current value).
  ProductSelectionState copyWith({
    ProductVariant? selectedVariant,
    EmiPlan? selectedEmiPlan,
    bool clearEmiPlan = false,
  }) {
    return ProductSelectionState(
      selectedVariant: selectedVariant ?? this.selectedVariant,
      selectedEmiPlan: clearEmiPlan ? null : (selectedEmiPlan ?? this.selectedEmiPlan),
    );
  }
}

/// Owns a single product's variant/EMI-plan selection, and enforces the one
/// cross-state invariant in this layer: changing the variant clears any
/// previously selected EMI plan, since it was priced against the old
/// variant's effective price. See rules.md Section 2 ("Cross-state
/// invariants").
class ProductSelectionNotifier
    extends AutoDisposeFamilyNotifier<ProductSelectionState, String> {
  @override
  ProductSelectionState build(String arg) => const ProductSelectionState();

  void selectVariant(ProductVariant variant) {
    state = state.copyWith(selectedVariant: variant, clearEmiPlan: true);
  }

  void selectEmiPlan(EmiPlan plan) {
    state = state.copyWith(selectedEmiPlan: plan);
  }
}

/// Per-product selection state, keyed by product id.
final productSelectionProvider = NotifierProvider.autoDispose
    .family<ProductSelectionNotifier, ProductSelectionState, String>(
  ProductSelectionNotifier.new,
);
