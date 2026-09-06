import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/emi_plan.dart';
import '../models/product.dart';
import 'marketplace_repository.dart';

/// One rung of the EMI tenure ladder: a tenure length and the flat annual
/// interest rate that applies to it.
class _TenureRule {
  const _TenureRule({required this.months, required this.ratePerAnnum});

  final int months;
  final double ratePerAnnum;
}

/// Mock [MarketplaceRepository] implementation backed by a bundled JSON
/// asset and a hardcoded EMI tenure ladder.
///
/// This is the only class in the project that knows product data comes
/// from a local asset — see architecture.md Section 8.
class MockMarketplaceRepository implements MarketplaceRepository {
  MockMarketplaceRepository({
    this.networkDelay = const Duration(milliseconds: 700),
    this.simulateError = false,
  });

  final Duration networkDelay;
  final bool simulateError;

  /// Canonical source for EMI tenure/rate rules. Both [fetchEmiPlans] and
  /// [maxNoCostTenureMonths] derive from this single list — see rules.md
  /// Section 4.
  static const List<_TenureRule> _tenureLadder = [
    _TenureRule(months: 3, ratePerAnnum: 0),
    _TenureRule(months: 6, ratePerAnnum: 0),
    _TenureRule(months: 9, ratePerAnnum: 12),
    _TenureRule(months: 12, ratePerAnnum: 12),
  ];

  @override
  int get maxNoCostTenureMonths {
    return _tenureLadder
        .where((rule) => rule.ratePerAnnum == 0)
        .map((rule) => rule.months)
        .reduce((a, b) => a > b ? a : b);
  }

  @override
  Future<List<Product>> fetchProducts() async {
    await Future.delayed(networkDelay);
    if (simulateError) {
      throw const MarketplaceException('Failed to load products.');
    }

    final raw = await rootBundle.loadString('assets/mock/products.json');
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((entry) => Product.fromJson(entry as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<EmiPlan>> fetchEmiPlans({required int principal}) async {
    await Future.delayed(networkDelay);
    if (simulateError) {
      throw const MarketplaceException('Failed to load EMI plans.');
    }

    return _tenureLadder
        .map(
          (rule) => EmiPlan.calculate(
            id: 'emi-${rule.months}',
            principal: principal,
            tenureMonths: rule.months,
            interestRatePerAnnum: rule.ratePerAnnum,
          ),
        )
        .toList();
  }
}
