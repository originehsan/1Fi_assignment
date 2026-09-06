/// A purchasable variant of a [Product] (e.g. a color or storage option),
/// carrying a price delta relative to the product's base price.
class ProductVariant {
  const ProductVariant({
    required this.id,
    required this.label,
    required this.priceDelta,
  });

  final String id;
  final String label;
  final int priceDelta;

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'] as String,
      label: json['label'] as String,
      priceDelta: json['priceDelta'] as int,
    );
  }
}
