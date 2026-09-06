import '../models/emi_plan.dart';
import '../models/product.dart';

/// Thrown by a [MarketplaceRepository] implementation when a data
/// operation fails.
class MarketplaceException implements Exception {
  const MarketplaceException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Abstract contract for all Marketplace data access.
///
/// This is the only boundary the UI and Riverpod state layers depend on —
/// see rules.md Section 1 and architecture.md Section 8. Consumers must
/// never depend on a concrete implementation directly.
abstract class MarketplaceRepository {
  Future<List<Product>> fetchProducts();

  Future<List<EmiPlan>> fetchEmiPlans({required int principal});

  /// The longest tenure (in months) that is currently offered at 0%
  /// interest, derived from the canonical tenure/rate source.
  int get maxNoCostTenureMonths;
}
