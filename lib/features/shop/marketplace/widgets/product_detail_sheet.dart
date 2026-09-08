import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme/app_theme.dart';
import '../models/emi_plan.dart';
import '../models/product.dart';
import '../providers/marketplace_provider.dart';
import '../providers/product_selection_provider.dart';
import 'async_state_views.dart';
import 'emi_plan_tile.dart';
import 'skeleton_views.dart';
import 'variant_selector.dart';

/// Opens product detail as a full-height modal bottom sheet — not a
/// pushed screen. Confirmed by direct side-by-side comparison against a
/// real screenshot of the actual 1Fi app's equivalent sheet: full-height,
/// no drag handle, no peek of the product list behind it — except the
/// system status bar, which always stays visible in its own space (see
/// `_ProductDetailSheetContentState.build()`'s height calculation); the
/// app makes no attempt to draw over or style it, same principle already
/// applied to ShopPage. Tapping "Proceed" swaps this same sheet's content
/// to an order summary in place, never stacking a second sheet on top
/// (see architecture.md Section 9).
///
/// `enableDrag: false` and `isDismissible: false`: this sheet closes only
/// via the back-chevron or the system back button/gesture, matching the
/// real app's confirmed dismiss behavior — never by swiping/dragging the
/// content or tapping the scrim outside it. This also resolves the
/// swipe-vs-scroll gesture conflict that existed once `_SheetHeader`
/// became the first item inside the scrollable content (see below):
/// removing drag-to-dismiss entirely means there's no longer any
/// ambiguity for Flutter's gesture arena to resolve between "scroll the
/// list" and "drag to dismiss."
///
/// `_SheetHeader` (back-chevron + title) is the first item inside each
/// view's own scrollable content, not a fixed sibling — it scrolls away
/// with the rest of the content and reappears when scrolled back to the
/// top. This is an intentional, accepted UX consequence, not an
/// oversight: once scrolled down, the only way to close the sheet is
/// scrolling back up to reach the header's back-chevron (or using the
/// system back button/gesture, which works regardless of scroll
/// position).
Future<void> showProductDetailSheet(BuildContext context, Product product) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    enableDrag: false,
    isDismissible: false,
    builder: (sheetContext) => _ProductDetailSheetContent(product: product),
  );
}

class _ProductDetailSheetContent extends ConsumerStatefulWidget {
  const _ProductDetailSheetContent({required this.product});

  final Product product;

  @override
  ConsumerState<_ProductDetailSheetContent> createState() =>
      _ProductDetailSheetContentState();
}

class _ProductDetailSheetContentState extends ConsumerState<_ProductDetailSheetContent> {
  // UI-only view-toggle state — which of this one sheet's two internal
  // views is currently shown. Not business state: the data those views
  // display (selected variant, selected EMI plan) still lives entirely in
  // productSelectionProvider, completely unchanged by this widget. Same
  // category of exception rules.md already documents for bottom-nav tab
  // selection: local State is fine for "which view is shown," never for
  // "what was selected."
  bool _showingSummary = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: _showingSummary ? _buildSummaryView(context) : _buildProductView(context),
    );
  }

  Widget _buildProductView(BuildContext context) {
    final product = widget.product;
    final selection = ref.watch(productSelectionProvider(product.id));
    final notifier = ref.read(productSelectionProvider(product.id).notifier);
    final selectedVariant = selection.selectedVariant;
    final effectivePrice = product.basePrice + (selectedVariant?.priceDelta ?? 0);
    final canProceed = selectedVariant != null && selection.selectedEmiPlan != null;

    String proceedButtonLabel() {
      final hasVariant = selectedVariant != null;
      final hasPlan = selection.selectedEmiPlan != null;
      if (hasVariant && hasPlan) return 'Proceed';
      if (hasVariant && !hasPlan) return 'Select an EMI plan';
      return 'Select an option';
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              _SheetHeader(title: product.name),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.thumbnail),
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
                    const Text('Select an option', style: AppTextStyles.sectionLabel),
                    const SizedBox(height: 8),
                    VariantSelector(
                      variants: product.variants,
                      selected: selectedVariant,
                      onSelect: notifier.selectVariant,
                    ),
                    const SizedBox(height: 20),
                    const Text('EMI plans', style: AppTextStyles.sectionLabel),
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
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sheetActionPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selection.selectedEmiPlan != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      'You\'ll pay ₹${selection.selectedEmiPlan!.monthlyAmount}/mo for ${selection.selectedEmiPlan!.tenureMonths} months',
                      style: AppTextStyles.caption,
                    ),
                  ),
                ElevatedButton(
                  onPressed: canProceed ? () => setState(() => _showingSummary = true) : null,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(proceedButtonLabel()),
                      if (canProceed)
                        const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Icon(Icons.arrow_forward, size: 18),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryView(BuildContext context) {
    final product = widget.product;
    final selection = ref.watch(productSelectionProvider(product.id));
    final selectedVariant = selection.selectedVariant;
    final effectivePrice = product.basePrice + (selectedVariant?.priceDelta ?? 0);
    // Non-null: this view is only ever shown after Proceed was tapped,
    // which is only enabled once a plan is selected (see canProceed in
    // _buildProductView) — non-nullability here is guaranteed by that
    // earlier check, not assumed.
    final plan = selection.selectedEmiPlan!;

    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              const _SheetHeader(title: 'Order summary'),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SummaryRow(label: 'Product', value: product.name),
                    if (selectedVariant != null)
                      _SummaryRow(label: 'Option', value: selectedVariant.label),
                    _SummaryRow(label: 'Price', value: '₹$effectivePrice'),
                    _SummaryRow(
                      label: 'EMI plan',
                      value: '${plan.tenureMonths} months • ₹${plan.monthlyAmount}/mo',
                    ),
                    _SummaryRow(label: 'Total payable', value: '₹${plan.totalPayable}'),
                  ],
                ),
              ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sheetActionPadding),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Demo checkout for this assignment — no real order was placed.'),
                  ),
                );
              },
              child: const Text('Confirm'),
            ),
          ),
        ),
      ],
    );
  }
}

/// The sheet's header (back-chevron + title), scrolling away with the
/// rest of the content rather than staying pinned — used as the first
/// item inside both [_buildProductView]'s and [_buildSummaryView]'s
/// scrollable content (its one genuine use in each of the two views is
/// exactly the threshold rules.md's widget-reuse rule calls for
/// extracting a private helper rather than duplicating this Row twice).
class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 44, 16, 8),
      child: Row(
        children: [
          // padding: zero + constraints: BoxConstraints() strip
          // IconButton's own default inset/min-tap-target, which was the
          // biggest source of misalignment. That alone still leaves a
          // residual gap: CupertinoIcons.back's glyph carries its own
          // built-in left-side bearing within its 24dp box (verified by
          // on-device pixel measurement — the chevron's visible stroke
          // sat ~18dp inside its box, not flush against it), so
          // Transform.translate shifts the whole button (glyph and tap
          // target together — Transform moves hit-testing along with the
          // paint) left by that amount for true visual alignment with
          // the 16px content margin below.
          Transform.translate(
            offset: const Offset(-18, 0),
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(CupertinoIcons.back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
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

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
