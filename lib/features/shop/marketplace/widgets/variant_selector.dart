import 'package:flutter/material.dart';

import '../models/product_variant.dart';

/// Row of selectable chips, one per product variant.
class VariantSelector extends StatelessWidget {
  const VariantSelector({
    super.key,
    required this.variants,
    required this.selected,
    required this.onSelect,
  });

  final List<ProductVariant> variants;
  final ProductVariant? selected;
  final ValueChanged<ProductVariant> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: variants.map((variant) {
        final label = variant.priceDelta == 0
            ? variant.label
            : '${variant.label} (+₹${variant.priceDelta})';
        return ChoiceChip(
          label: Text(label),
          selected: selected?.id == variant.id,
          onSelected: (_) => onSelect(variant),
        );
      }).toList(),
    );
  }
}
