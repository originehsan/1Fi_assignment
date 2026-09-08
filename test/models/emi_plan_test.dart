// Pure-logic unit tests for EmiPlan.calculate() — no Flutter or Riverpod
// dependency, so plain `test()`s are sufficient (no widget pump needed).
// See rules.md Section 9 and architecture.md Section 13: tests here are
// chosen by engineering signal (a non-trivial calculation), not coverage.

import 'package:flutter_test/flutter_test.dart';

import 'package:onefi/features/shop/marketplace/models/emi_plan.dart';

void main() {
  group('EmiPlan.calculate', () {
    test('no-cost plan splits principal evenly across tenure', () {
      // 6 months at 0% is one of this project's real no-cost tenures
      // (see MockMarketplaceRepository._tenureLadder).
      final plan = EmiPlan.calculate(
        id: 'emi-6',
        principal: 6000,
        tenureMonths: 6,
        interestRatePerAnnum: 0,
      );

      expect(plan.isNoCost, isTrue);
      expect(plan.totalPayable, 6000);
      expect(plan.monthlyAmount, 1000);
    });

    test('interest-bearing plan adds interest to total payable', () {
      // 12 months at 12% p.a. is one of this project's real
      // interest-bearing tenures (see
      // MockMarketplaceRepository._tenureLadder). Principal chosen so
      // totalPayable divides evenly by tenureMonths, so the equality
      // below isn't fragile to rounding.
      final plan = EmiPlan.calculate(
        id: 'emi-12',
        principal: 12000,
        tenureMonths: 12,
        interestRatePerAnnum: 12,
      );

      expect(plan.isNoCost, isFalse);
      expect(plan.totalPayable, greaterThan(12000));
      expect(plan.monthlyAmount * plan.tenureMonths, plan.totalPayable);
    });
  });
}
