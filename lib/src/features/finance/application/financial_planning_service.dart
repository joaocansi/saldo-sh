import '../domain/models.dart';

/// Budget planning by due month, consistent with the financial screens.
/// Card purchases count once; their settlement and own-account transfers do not.
class FinancialPlanningService {
  const FinancialPlanningService();

  /// Projects the consolidated cash position without double-counting credit
  /// card payments or transfers between the user's own accounts.
  List<CashFlowProjection> cashFlowProjection({
    required Iterable<FinanceAccount> accounts,
    required Iterable<FinanceTransaction> transactions,
    required DateTime fromMonth,
    int months = 3,
  }) {
    if (months <= 0) return const [];
    final openingBalanceCents = accounts
        .where((account) => !account.isCard)
        .fold<int>(
          0,
          (sum, account) => sum + _moneyToCents(account.openingBalance),
        );
    final result = <CashFlowProjection>[];

    for (var offset = 0; offset < months; offset++) {
      final target = DateTime(fromMonth.year, fromMonth.month + offset);
      final monthItems = transactions.where(
        (transaction) => sameMonth(transaction.dueDate, target),
      );
      final incomeCents = _sum(monthItems.where((item) => item.isIncome));
      final expenseCents = _sum(monthItems.where((item) => item.isExpense));
      var endingBalanceCents = openingBalanceCents;
      for (final transaction in transactions) {
        if (_isAfterMonth(transaction.dueDate, target)) continue;
        final amount = _moneyToCents(transaction.amount);
        if (transaction.isIncome) endingBalanceCents += amount;
        if (transaction.isExpense) endingBalanceCents -= amount;
      }
      result.add(
        CashFlowProjection(
          month: target,
          incomeCents: incomeCents,
          expenseCents: expenseCents,
          endingBalanceCents: endingBalanceCents,
        ),
      );
    }
    return List.unmodifiable(result);
  }

  Map<String, dynamic> monthSummary(
    Iterable<FinanceTransaction> transactions,
    DateTime month,
  ) {
    final items = transactions.where((t) => sameMonth(t.dueDate, month));
    final income = items.where((t) => t.isIncome).toList();
    final expenses = items.where((t) => t.isExpense).toList();
    return {
      'month': monthKey(month),
      'income_cents': _sum(income),
      'received_income_cents': _sum(income.where((t) => t.status == 'paid')),
      'expected_income_cents': _sum(income.where((t) => t.isPlanned)),
      'expense_cents': _sum(expenses),
      'planned_expense_cents': _sum(expenses.where((t) => t.isPlanned)),
      'installment_expense_cents': _sum(expenses.where((t) => t.isInstallment)),
      'result_cents': _sum(income) - _sum(expenses),
      'income_count': income.length,
      'expense_count': expenses.length,
      'basis': 'due_date; registered paid/pending/planned; excludes transfers and card payments',
    };
  }

  Map<String, dynamic> savingsPlan({
    required Iterable<FinanceTransaction> transactions,
    required DateTime month,
    required DateTime today,
    required int savingsTargetCents,
    int? monthlyIncomeCents,
  }) {
    final summary = monthSummary(transactions, month);
    final income = monthlyIncomeCents ?? (summary['income_cents'] as int);
    final expenses = summary['expense_cents'] as int;
    final lastDay = DateTime(month.year, month.month + 1, 0).day;
    final daysRemaining = month.isBefore(monthStart(today))
        ? 0
        : sameMonth(month, today)
        ? lastDay - today.day + 1
        : lastDay;
    final spendingCeiling = income - savingsTargetCents;
    final margin = spendingCeiling - expenses;
    final available = margin > 0 ? margin : 0;
    final shortfall = margin < 0 ? -margin : 0;
    // A user-supplied zero income is meaningful; an empty ledger is not evidence
    // of zero income and must prompt a question rather than a spending claim.
    final needsIncome =
        monthlyIncomeCents == null && summary['income_count'] == 0;
    return {
      ...summary,
      'savings_target_cents': savingsTargetCents,
      'income_source': monthlyIncomeCents == null
          ? 'registered'
          : 'user_scenario_total',
      'monthly_income_cents': needsIncome ? null : income,
      'needs_income_confirmation': needsIncome,
      'spending_ceiling_cents': needsIncome ? null : spendingCeiling,
      'remaining_margin_cents': needsIncome ? null : margin,
      'additional_spending_cents': needsIncome ? null : available,
      'shortfall_cents': needsIncome ? null : shortfall,
      'days_remaining': daysRemaining,
      'daily_spending_cents': needsIncome || daysRemaining == 0
          ? null
          : available ~/ daysRemaining,
      'assumptions': [
        'Meta é mensal. Renda informada substitui a renda registrada, não é somada.',
        'Despesas já registradas incluem parcelas e ocorrências futuras existentes.',
        'Não estima despesas ausentes nem repete automaticamente meses anteriores.',
        'É margem de orçamento, não saldo disponível: receitas podem não ter entrado e faturas anteriores podem estar em aberto.',
      ],
    };
  }

  static String monthKey(DateTime month) =>
      '${month.year.toString().padLeft(4, '0')}-${month.month.toString().padLeft(2, '0')}';

  int _sum(Iterable<FinanceTransaction> items) =>
      items.fold(0, (sum, item) => sum + _moneyToCents(item.amount));

  static int _moneyToCents(double value) => (value * 100).round();

  static bool _isAfterMonth(DateTime value, DateTime month) =>
      value.year > month.year ||
      (value.year == month.year && value.month > month.month);
}
