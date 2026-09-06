/// A single EMI (equated monthly installment) option for a given principal.
class EmiPlan {
  const EmiPlan({
    required this.id,
    required this.tenureMonths,
    required this.interestRatePerAnnum,
    required this.monthlyAmount,
    required this.totalPayable,
    required this.isNoCost,
  });

  final String id;
  final int tenureMonths;
  final double interestRatePerAnnum;
  final int monthlyAmount;
  final int totalPayable;
  final bool isNoCost;

  /// Derives a full [EmiPlan] from a principal, tenure, and flat annual
  /// interest rate. This is a simplified flat-rate calculation, not a real
  /// bank's amortization method — see architecture.md Section 15.
  factory EmiPlan.calculate({
    required String id,
    required int principal,
    required int tenureMonths,
    required double interestRatePerAnnum,
  }) {
    final isNoCost = interestRatePerAnnum == 0;
    final totalInterest =
        (principal * interestRatePerAnnum / 100) * (tenureMonths / 12);
    final totalPayable = (principal + totalInterest).round();
    final monthlyAmount = (totalPayable / tenureMonths).round();

    return EmiPlan(
      id: id,
      tenureMonths: tenureMonths,
      interestRatePerAnnum: interestRatePerAnnum,
      monthlyAmount: monthlyAmount,
      totalPayable: totalPayable,
      isNoCost: isNoCost,
    );
  }
}
