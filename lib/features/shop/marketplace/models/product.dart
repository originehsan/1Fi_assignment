import 'product_variant.dart';

/// A single Marketplace product, as returned by [MarketplaceRepository.fetchProducts].
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.imageUrl,
    required this.basePrice,
    required this.description,
    required this.category,
    required this.variants,
  });

  final String id;
  final String name;
  final String brand;
  final String imageUrl;
  final int basePrice;
  final String description;
  final String category;
  final List<ProductVariant> variants;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String,
      imageUrl: json['imageUrl'] as String,
      basePrice: json['basePrice'] as int,
      description: json['description'] as String,
      category: json['category'] as String,
      variants: (json['variants'] as List<dynamic>)
          .map((variant) => ProductVariant.fromJson(variant as Map<String, dynamic>))
          .toList(),
    );
  }
}
