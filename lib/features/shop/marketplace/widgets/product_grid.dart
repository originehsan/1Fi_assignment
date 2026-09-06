import 'package:flutter/material.dart';

import '../models/product.dart';
import 'product_card.dart';

/// Responsive grid of [ProductCard]s.
class ProductGrid extends StatelessWidget {
  const ProductGrid({
    super.key,
    required this.products,
    required this.maxNoCostTenureMonths,
    required this.onProductTap,
  });

  final List<Product> products;
  final int maxNoCostTenureMonths;
  final ValueChanged<Product> onProductTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.62,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(
          product: product,
          maxNoCostTenureMonths: maxNoCostTenureMonths,
          onTap: () => onProductTap(product),
        );
      },
    );
  }
}
