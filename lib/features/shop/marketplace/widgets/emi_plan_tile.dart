import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../models/emi_plan.dart';

/// Selectable row for a single EMI plan option.
class EmiPlanTile extends StatelessWidget {
  const EmiPlanTile({
    super.key,
    required this.plan,
    required this.selected,
    required this.onTap,
  });

  final EmiPlan plan;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.tilePadding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
            width: selected ? 1.5 : 1,
          ),
          color: selected ? AppColors.primary.withValues(alpha: 0.06) : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.primary : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${plan.tenureMonths} months • ₹${plan.monthlyAmount}/mo',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    plan.isNoCost
                        ? 'No-cost EMI • Total ₹${plan.totalPayable}'
                        : '${plan.interestRatePerAnnum.toStringAsFixed(0)}% p.a. • Total ₹${plan.totalPayable}',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            if (plan.isNoCost)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'No-cost',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
