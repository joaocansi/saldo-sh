import '../domain/ai_chart.dart';

class FinanceChartSnapshotBuilder {
  FinanceChartSnapshotBuilder({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;

  AIChartSnapshot build(String operation, Map<String, dynamic> payload) =>
      switch (operation) {
        'compare_months' => _incomeExpense(payload),
        'cash_flow' => _cashFlow(payload),
        'category_spending' => _categorySpending(payload),
        'budget_status' => _budgetUsage(payload),
        'invoices' => _invoiceEvolution(payload),
        _ => throw ArgumentError.value(
          operation,
          'operation',
          'A operação não possui visualização.',
        ),
      };

  AIChartSnapshot _incomeExpense(Map<String, dynamic> payload) {
    final months = _maps(payload['months']);
    return _snapshot(
      kind: AIChartKind.incomeExpense,
      title: 'Entradas e saídas',
      subtitle: _subtitle(payload, 'Comparação mensal dos lançamentos'),
      periodLabels: months.map((item) => item['month'].toString()).toList(),
      series: [
        _series('Entradas', 'income', months, 'income_cents'),
        _series('Saídas', 'expense', months, 'expense_cents'),
      ],
      accountName: _accountName(payload),
    );
  }

  AIChartSnapshot _cashFlow(Map<String, dynamic> payload) {
    final months = _maps(payload['months']);
    return _snapshot(
      kind: AIChartKind.cashFlow,
      title: 'Evolução do caixa',
      subtitle: _subtitle(payload, 'Saldo acumulado ao fim de cada mês'),
      periodLabels: months.map((item) => item['month'].toString()).toList(),
      series: [
        _series('Caixa acumulado', 'balance', months, 'ending_balance_cents'),
      ],
      accountName: _accountName(payload),
    );
  }

  AIChartSnapshot _categorySpending(Map<String, dynamic> payload) {
    final categories = payload['categories'];
    final points = <AIChartPoint>[];
    if (categories is Map) {
      for (final entry in categories.entries) {
        final value = entry.value;
        if (value is num) {
          points.add(
            AIChartPoint(label: entry.key.toString(), valueCents: value.toInt()),
          );
        }
      }
    }
    final month = payload['month']?.toString() ?? '';
    return _snapshot(
      kind: AIChartKind.categorySpending,
      title: 'Gastos por categoria',
      subtitle: _subtitle(payload, 'Distribuição das despesas registradas'),
      periodLabels: [month],
      series: [AIChartSeries(label: 'Despesas', role: 'category', points: points)],
      accountName: _accountName(payload),
    );
  }

  AIChartSnapshot _budgetUsage(Map<String, dynamic> payload) {
    final budgets = _maps(payload['budgets']);
    return _snapshot(
      kind: AIChartKind.budgetUsage,
      title: 'Consumo dos orçamentos',
      subtitle: 'Gasto registrado em relação ao limite mensal',
      periodLabels: [payload['month']?.toString() ?? ''],
      series: [
        _series('Gasto', 'spent', budgets, 'spent_cents', labelKey: 'category'),
        _series('Limite', 'limit', budgets, 'limit_cents', labelKey: 'category'),
      ],
    );
  }

  AIChartSnapshot _invoiceEvolution(Map<String, dynamic> payload) {
    final months = _maps(payload['evolution']);
    return _snapshot(
      kind: AIChartKind.invoiceEvolution,
      title: 'Evolução das faturas',
      subtitle: _subtitle(payload, 'Valores pagos e ainda em aberto'),
      periodLabels: months.map((item) => item['month'].toString()).toList(),
      series: [
        _series('Pago', 'paid', months, 'paid_cents'),
        _series('Em aberto', 'remaining', months, 'remaining_cents'),
      ],
      accountName: _accountName(payload),
    );
  }

  AIChartSeries _series(
    String label,
    String role,
    List<Map<String, dynamic>> rows,
    String valueKey, {
    String labelKey = 'month',
  }) => AIChartSeries(
    label: label,
    role: role,
    points: [
      for (final row in rows)
        if (row[labelKey] != null && row[valueKey] is num)
          AIChartPoint(
            label: row[labelKey].toString(),
            valueCents: (row[valueKey] as num).toInt(),
          ),
    ],
  );

  AIChartSnapshot _snapshot({
    required AIChartKind kind,
    required String title,
    required String subtitle,
    required List<String> periodLabels,
    required List<AIChartSeries> series,
    String? accountName,
  }) {
    final labels = periodLabels.where((label) => label.isNotEmpty).toList();
    return AIChartSnapshot(
      kind: kind,
      title: title,
      subtitle: subtitle,
      generatedAt: _clock(),
      periodStart: labels.isEmpty ? '' : labels.first,
      periodEnd: labels.isEmpty ? '' : labels.last,
      accountName: accountName,
      series: series,
    );
  }

  String _subtitle(Map<String, dynamic> payload, String base) {
    final accountName = payload['account_name'];
    return accountName is String && accountName.isNotEmpty
        ? '$base · $accountName'
        : base;
  }

  String? _accountName(Map<String, dynamic> payload) =>
      payload['account_name'] is String
      ? payload['account_name'] as String
      : null;

  List<Map<String, dynamic>> _maps(Object? source) => source is List
      ? source
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList(growable: false)
      : const [];
}
