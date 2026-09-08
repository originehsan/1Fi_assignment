// Verifies the single most important correctness rule in this project's
// state layer (see rules.md Section 2, "Cross-state invariants", and
// architecture.md Section 7): selecting a new variant must clear any
// previously selected EMI plan, since that plan was calculated for the
// old price. A bare ProviderContainer is used — no widget pump — since
// this logic doesn't require a widget tree to exercise.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:onefi/features/shop/marketplace/models/emi_plan.dart';
import 'package:onefi/features/shop/marketplace/models/product_variant.dart';
import 'package:onefi/features/shop/marketplace/providers/product_selection_provider.dart';

void main() {
  test('selecting a new variant clears any previously selected EMI plan', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(productSelectionProvider('test-product').notifier);

    const variantA = ProductVariant(id: 'a', label: 'Variant A', priceDelta: 0);
    const variantB = ProductVariant(id: 'b', label: 'Variant B', priceDelta: 500);
    final plan = EmiPlan.calculate(
      id: 'emi-3',
      principal: 9000,
      tenureMonths: 3,
      interestRatePerAnnum: 0,
    );

    notifier.selectVariant(variantA);
    notifier.selectEmiPlan(plan);

    expect(
      container.read(productSelectionProvider('test-product')).selectedEmiPlan,
      plan,
    );

    // Switching variants changes the price, so the old EMI plan
    // (calculated for the old price) must not remain selected.
    notifier.selectVariant(variantB);

    final stateAfterSwitch = container.read(productSelectionProvider('test-product'));
    expect(stateAfterSwitch.selectedVariant, variantB);
    expect(stateAfterSwitch.selectedEmiPlan, isNull);
  });
}
