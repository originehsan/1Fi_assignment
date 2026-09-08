import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../models/product.dart';
import 'skeleton_views.dart';

/// Full-width list row for a single product, matching the real 1Fi Top
/// Brands card pattern: a square image on the left, product name and
/// EMI caption on the right. Data comes in via constructor parameters
/// only — this widget does not know where the product or the no-cost
/// tenure figure came from.
class ProductListItem extends StatelessWidget {
  const ProductListItem({
    super.key,
    required this.product,
    required this.maxNoCostTenureMonths,
    required this.onTap,
  });

  final Product product;
  final int maxNoCostTenureMonths;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      // elevation/color/shape (cardBackground fill, divider border,
      // AppRadius.card radius, no shadow) come from AppTheme.light's
      // cardTheme — matches every other card in this project, per
      // rules.md Section 3 (don't duplicate a design value already
      // centralized). The InkWell below references the same
      // AppRadius.card constant (rather than its own literal) so its
      // ripple-clip radius can't drift from the Card's own shape.
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.tilePadding),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.thumbnail),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const ShimmerBox(
                      height: 72,
                      width: 72,
                      borderRadius: BorderRadius.all(Radius.circular(AppRadius.thumbnail)),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.divider,
                      child: const Icon(Icons.broken_image_outlined, color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'No-cost EMI upto $maxNoCostTenureMonths months',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
