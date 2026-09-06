import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme/app_theme.dart';
import '../models/emi_plan.dart';
import '../models/product.dart';
import '../providers/marketplace_provider.dart';
import '../providers/product_selection_provider.dart';
import '../widgets/async_state_views.dart';
import '../widgets/confirmation_sheet.dart';
import '../widgets/emi_plan_tile.dart';
import '../widgets/skeleton_views.dart';
import '../widgets/variant_selector.dart';

/// Product detail: option/variant selection, EMI plan selection, and the
/// Proceed CTA. All business calculations (effective price, CTA validity)
/// are simple reads over already-owned state, per architecture.md Section 7.
class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(productSelectionProvider(product.id));
    final notifier = ref.read(productSelectionProvider(product.id).notifier);
    final selectedVariant = selection.selectedVariant;
    final effectivePrice = product.basePrice + (selectedVariant?.priceDelta ?? 0);
    final canProceed = selectedVariant != null && selection.selectedEmiPlan != null;

    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: ListView(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: CachedNetworkImage(
              imageUrl: product.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => const ShimmerBox(height: double.infinity),
              errorWidget: (context, url, error) => Container(
                color: AppColors.divider,
                child: const Icon(Icons.broken_image_outlined),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.brand, style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹$effectivePrice',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  product.description,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                const Text('Select an option', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                VariantSelector(
                  variants: product.variants,
                  selected: selectedVariant,
                  onSelect: notifier.selectVariant,
                ),
                const SizedBox(height: 20),
                const Text('EMI plans', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                if (selectedVariant == null)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Select an option above to see EMI plans.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                else
                  _EmiPlansSection(
                    productId: product.id,
                    effectivePrice: effectivePrice,
                    selectedPlan: selection.selectedEmiPlan,
                    onSelectPlan: notifier.selectEmiPlan,
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: canProceed
                ? () => showOrderSummarySheet(
                      context,
                      product: product,
                      variant: selectedVariant,
                      plan: selection.selectedEmiPlan!,
                      effectivePrice: effectivePrice,
                    )
                : null,
            child: Text(
              canProceed
                  ? 'Proceed – ₹${selection.selectedEmiPlan!.monthlyAmount}/mo'
                  : 'Select an option and EMI plan',
            ),
          ),
        ),
      ),
    );
  }
}

class _EmiPlansSection extends ConsumerWidget {
  const _EmiPlansSection({
    required this.productId,
    required this.effectivePrice,
    required this.selectedPlan,
    required this.onSelectPlan,
  });

  final String productId;
  final int effectivePrice;
  final EmiPlan? selectedPlan;
  final ValueChanged<EmiPlan> onSelectPlan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(emiPlansProvider(effectivePrice)).when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: EmiPlansSkeleton(),
          ),
          error: (error, stackTrace) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ErrorRetryView(
              message: 'Could not load EMI plans.',
              onRetry: () => ref.invalidate(emiPlansProvider(effectivePrice)),
            ),
          ),
          data: (plans) => Column(
            children: plans
                .map(
                  (plan) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: EmiPlanTile(
                      plan: plan,
                      selected: selectedPlan?.id == plan.id,
                      onTap: () => onSelectPlan(plan),
                    ),
                  ),
                )
                .toList(),
          ),
        );
  }
}
