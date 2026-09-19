class CashFlowProjection {
  const CashFlowProjection({
    required this.month,
    required this.incomeCents,
    required this.expenseCents,
    required this.endingBalanceCents,
  });

  final DateTime month;
  final int incomeCents;
  final int expenseCents;
  final int endingBalanceCents;

  double get income => incomeCents / 100;
  double get expense => expenseCents / 100;
  double get endingBalance => endingBalanceCents / 100;
}
