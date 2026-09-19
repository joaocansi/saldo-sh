import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/app_theme.dart';
import '../../domain/models.dart';
import '../widgets/finance_widgets.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key, required this.transactions});
  final List<FinanceTransaction> transactions;
  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  DateTime month = monthStart(DateTime.now());
  @override
  Widget build(BuildContext context) {
    final current = widget.transactions
        .where((item) => sameMonth(item.dueDate, month))
        .toList();
    final income = current
        .where((item) => item.isIncome)
        .fold(0.0, (sum, item) => sum + item.amount);
    final expense = current
        .where((item) => item.isExpense)
        .fold(0.0, (sum, item) => sum + item.amount);
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 110),
      children: [
        const PageHeading(
          'Relatórios',
          'Todos os valores são calculados dos dados locais.',
        ),
        const SizedBox(height: 12),
        MonthSelector(
          month: month,
          onChanged: (value) => setState(() => month = value),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                label: 'Entradas',
                value: money(income),
                icon: Icons.south_west_rounded,
                color: FinanceColors.of(context).income,
                footer: 'no período',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SummaryCard(
                label: 'Saídas',
                value: money(expense),
                icon: Icons.north_east_rounded,
                color: FinanceColors.of(context).expense,
                footer: 'no período',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        CategorySummary(transactions: current),
        const SizedBox(height: 14),
        MonthlyEvolution(transactions: widget.transactions, month: month),
      ],
    );
  }
}

class MonthlyEvolution extends StatelessWidget {
  const MonthlyEvolution({
    super.key,
    required this.transactions,
    required this.month,
  });
  final List<FinanceTransaction> transactions;
  final DateTime month;
  @override
  Widget build(BuildContext context) {
    final months = List.generate(6, (index) => addMonths(month, index - 5));
    final values = months
        .map(
          (target) => transactions
              .where(
                (item) => item.isExpense && sameMonth(item.dueDate, target),
              )
              .fold(0.0, (sum, item) => sum + item.amount),
        )
        .toList();
    final maxValue = values.fold(1.0, math.max);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Evolução de gastos',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 150,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(
                  months.length,
                  (index) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            values[index].toStringAsFixed(0),
                            style: const TextStyle(fontSize: 9),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 105 * values[index] / maxValue,
                            decoration: BoxDecoration(
                              color: FinanceColors.of(context).income,
                              borderRadius: BorderRadius.circular(7),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            monthLabel(months[index]).substring(0, 3),
                            style: const TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
