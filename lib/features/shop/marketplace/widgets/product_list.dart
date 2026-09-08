import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../models/product.dart';
import 'product_list_item.dart';

/// Vertical list of [ProductListItem]s, matching the real 1Fi Top Brands
/// listing pattern.
class ProductList extends StatelessWidget {
  const ProductList({
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
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.listContentPadding),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ProductListItem(
            product: product,
            maxNoCostTenureMonths: maxNoCostTenureMonths,
            onTap: () => onProductTap(product),
          ),
        );
      },
    );
  }
}
