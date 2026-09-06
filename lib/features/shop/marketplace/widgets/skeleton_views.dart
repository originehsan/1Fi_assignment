import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';

/// A single pulsing-opacity placeholder block, the building block every
/// other skeleton in this file is made of.
///
/// This is a deliberately simple pulsing-opacity shimmer, not a diagonal
/// sweep gradient — a reasonable scoped simplification, not a claim of
/// pixel-perfect parity with the real app's shimmer animation (which
/// cannot be verified frame-by-frame from a static screenshot anyway).
class ShimmerBox extends StatefulWidget {
  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius,
    this.color,
  });

  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  final Color? color;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.4, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.color ?? AppColors.divider,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}

/// Placeholder matching [ProductListItem]'s layout shape, shown while the
/// product list is loading.
class ProductListItemSkeleton extends StatelessWidget {
  const ProductListItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            ShimmerBox(
              width: 72,
              height: 72,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(
                    width: 150,
                    height: 16,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  SizedBox(height: 6),
                  ShimmerBox(
                    width: 100,
                    height: 12,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder list shown while [filteredProductsProvider] is loading.
/// Mirrors [ProductList]'s `ListView.builder` configuration exactly so the
/// skeleton doesn't visibly reflow into the real list once data arrives.
class ProductListSkeleton extends StatelessWidget {
  const ProductListSkeleton({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) => const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: ProductListItemSkeleton(),
      ),
    );
  }
}

/// Placeholder matching an unselected [EmiPlanTile]'s container shape.
class EmiPlanTileSkeleton extends StatelessWidget {
  const EmiPlanTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: const Row(
        children: [
          ShimmerBox(
            width: 20,
            height: 20,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(
                  width: 140,
                  height: 14,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                SizedBox(height: 4),
                ShimmerBox(
                  width: 100,
                  height: 11,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Placeholder shown in place of the EMI plans list while
/// [emiPlansProvider] is loading, matching how [EmiPlanTile] instances are
/// spaced in `_EmiPlansSection`.
class EmiPlansSkeleton extends StatelessWidget {
  const EmiPlansSkeleton({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (index) => const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: EmiPlanTileSkeleton(),
        ),
      ),
    );
  }
}
