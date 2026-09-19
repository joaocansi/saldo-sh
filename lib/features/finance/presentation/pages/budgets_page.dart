import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/app_theme.dart';
import '../../../../core/presentation/widgets/app_select_field.dart';
import '../../domain/models.dart';
import '../widgets/finance_widgets.dart';

class BudgetsPage extends StatelessWidget {
  const BudgetsPage({
    super.key,
    required this.budgets,
    required this.transactions,
    required this.onSave,
    required this.onDelete,
  });
  final List<FinanceBudget> budgets;
  final List<FinanceTransaction> transactions;
  final ValueChanged<FinanceBudget> onSave, onDelete;
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 110),
      children: [
        Row(
          children: [
            const Expanded(
              child: PageHeading(
                'Orçamento',
                'Limites mensais incluindo valores previstos.',
              ),
            ),
            IconButton.filled(
              onPressed: () => budgetDialog(context, onSave),
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
        const SizedBox(height: 18),
        if (budgets.isEmpty)
          _BudgetsEmptyState(onCreate: () => budgetDialog(context, onSave))
        else
          ...budgets.map((budget) {
            final realized = transactions
                .where(
                  (item) =>
                      item.isExpense &&
                      item.status == 'paid' &&
                      item.category == budget.category &&
                      sameMonth(item.dueDate, now),
                )
                .fold(0.0, (sum, item) => sum + item.amount);
            final planned = transactions
                .where(
                  (item) =>
                      item.isExpense &&
                      item.status != 'paid' &&
                      item.category == budget.category &&
                      sameMonth(item.dueDate, now),
                )
                .fold(0.0, (sum, item) => sum + item.amount);
            final ratio = budget.limit <= 0
                ? 0.0
                : ((realized + planned) / budget.limit).clamp(0, 1).toDouble();
            final financeColors = FinanceColors.of(context);
            final color = realized + planned > budget.limit
                ? financeColors.expense
                : ratio > .8
                ? financeColors.warning
                : financeColors.income;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              budget.category,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                budgetDialog(context, onSave, budget),
                            icon: const Icon(Icons.edit_outlined, size: 19),
                          ),
                          IconButton(
                            onPressed: () => onDelete(budget),
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              size: 19,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${money(realized)} realizados + ${money(planned)} previstos',
                        style: const TextStyle(fontSize: 11),
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: ratio,
                        color: color,
                        minHeight: 9,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        '${money((budget.limit - realized - planned).clamp(0, double.infinity))} disponíveis de ${money(budget.limit)}',
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}

class _BudgetsEmptyState extends StatelessWidget {
  const _BudgetsEmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.pie_chart_outline_rounded,
                size: 30,
                color: colors.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Planeje antes de gastar',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Defina limites mensais por categoria para acompanhar o que já '
              'saiu e o que ainda está previsto.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Criar primeiro orçamento'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> budgetDialog(
  BuildContext context,
  ValueChanged<FinanceBudget> onSave, [
  FinanceBudget? editing,
]) async {
  var category = editing?.category ?? financeCategories.first;
  final limit = TextEditingController(
    text: editing?.limit.toStringAsFixed(2) ?? '',
  );
  await showDialog<void>(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (context, setLocal) => AlertDialog(
        title: Text(editing == null ? 'Novo orçamento' : 'Editar orçamento'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppSelectField<String>(
                value: category,
                label: 'Categoria',
                options: financeCategories
                    .map((item) => AppSelectOption(value: item, label: item))
                    .toList(),
                onChanged: (item) => setLocal(() => category = item),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: limit,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Limite mensal',
                  prefixText: 'R\$ ',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final value =
                  double.tryParse(limit.text.replaceAll(',', '.')) ?? 0;
              if (value <= 0) return;
              onSave(
                FinanceBudget(
                  id: editing?.id ?? const Uuid().v4(),
                  category: category,
                  limit: value,
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    ),
  );
  limit.dispose();
}
