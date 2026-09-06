import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../models/emi_plan.dart';
import '../models/product.dart';
import '../models/product_variant.dart';

/// Shows the order-summary bottom sheet — the final confirmation step
/// before the (demo) checkout. Not a fourth screen; a modal, per
/// architecture.md Section 9.
Future<void> showOrderSummarySheet(
  BuildContext context, {
  required Product product,
  required ProductVariant? variant,
  required EmiPlan plan,
  required int effectivePrice,
}) {
  return showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _SummaryRow(label: 'Product', value: product.name),
            if (variant != null) _SummaryRow(label: 'Option', value: variant.label),
            _SummaryRow(label: 'Price', value: '₹$effectivePrice'),
            _SummaryRow(
              label: 'EMI plan',
              value: '${plan.tenureMonths} months • ₹${plan.monthlyAmount}/mo',
            ),
            _SummaryRow(label: 'Total payable', value: '₹${plan.totalPayable}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Demo checkout for this assignment — no real order was placed.'),
                  ),
                );
              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      );
    },
  );
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
