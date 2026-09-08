import 'package:flutter/material.dart';

import '../models/product_variant.dart';

/// Horizontally-scrolling row of selectable chips, one per product
/// variant — follows the same pattern as the category filter row in
/// `marketplace_listing_screen.dart` (a fixed-height `ListView` of
/// `ChoiceChip`s, each trailed by an 8px gap), so this project doesn't
/// have two different chip-selection interaction patterns doing the same
/// kind of job.
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
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: variants.map((variant) {
          final label = variant.priceDelta == 0
              ? variant.label
              : '${variant.label} (+₹${variant.priceDelta})';
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(label),
              selected: selected?.id == variant.id,
              onSelected: (_) => onSelect(variant),
            ),
          );
        }).toList(),
      ),
    );
  }
}
