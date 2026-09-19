import 'package:flutter/material.dart';

import '../../../../app/app_theme.dart';
import '../../domain/models.dart';
import '../extensions/transaction_style.dart';

class MonthSelector extends StatelessWidget {
  const MonthSelector({
    super.key,
    required this.month,
    required this.onChanged,
  });
  final DateTime month;
  final ValueChanged<DateTime> onChanged;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      IconButton(
        onPressed: () => onChanged(addMonths(month, -1)),
        icon: const Icon(Icons.chevron_left_rounded),
      ),
      Expanded(
        child: TextButton(
          onPressed: () async {
            final selected = await showDatePicker(
              context: context,
              initialDate: month,
              firstDate: DateTime(1),
              lastDate: DateTime(9999, 12, 31),
              initialDatePickerMode: DatePickerMode.year,
              helpText: 'Escolha o m\u00eas',
            );
            if (selected != null) onChanged(monthStart(selected));
          },
          child: Text(
            monthLabel(month),
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ),
      IconButton(
        onPressed: () => onChanged(addMonths(month, 1)),
        icon: const Icon(Icons.chevron_right_rounded),
      ),
    ],
  );
}

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.footer,
  });
  final String label, value, footer;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 3),
          Text(
            footer,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}

class CashFlowProjectionCard extends StatelessWidget {
  const CashFlowProjectionCard({super.key, required this.projections});
  final List<CashFlowProjection> projections;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Evolução do caixa',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          const Text(
            'Saldo acumulado ao fim de cada mês, considerando os lançamentos registrados',
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 16),
          if (projections.isEmpty)
            const Text('Ainda não há dados para projetar.')
          else
            LayoutBuilder(
              builder: (_, box) {
                final cards = projections
                    .map((projection) => _CashFlowMonth(projection: projection))
                    .toList();
                if (box.maxWidth < 560) {
                  return Column(
                    children: [
                      for (var i = 0; i < cards.length; i++) ...[
                        cards[i],
                        if (i < cards.length - 1) const SizedBox(height: 8),
                      ],
                    ],
                  );
                }
                return Row(
                  children: [
                    for (var i = 0; i < cards.length; i++) ...[
                      Expanded(child: cards[i]),
                      if (i < cards.length - 1) const SizedBox(width: 8),
                    ],
                  ],
                );
              },
            ),
        ],
      ),
    ),
  );
}

class _CashFlowMonth extends StatelessWidget {
  const _CashFlowMonth({required this.projection});

  final CashFlowProjection projection;

  @override
  Widget build(BuildContext context) {
    final financeColors = FinanceColors.of(context);
    final balanceColor = projection.endingBalanceCents >= 0
        ? financeColors.income
        : financeColors.expense;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest
            .withValues(alpha: .45),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            monthLabel(projection.month),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 9),
          Text(
            money(projection.endingBalance),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: balanceColor,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '+ ${money(projection.income)}  − ${money(projection.expense)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class ProjectionCard extends StatelessWidget {
  const ProjectionCard({
    super.key,
    required this.transactions,
    required this.month,
  });

  final List<FinanceTransaction> transactions;
  final DateTime month;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Próximos meses',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          const Text(
            'Valores já comprometidos em parcelas e recorrências',
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(3, (index) {
              final target = addMonths(month, index + 1);
              final incoming = transactions
                  .where(
                    (item) => item.isIncome && sameMonth(item.dueDate, target),
                  )
                  .fold(0.0, (sum, item) => sum + item.amount);
              final outgoing = transactions
                  .where(
                    (item) => item.isExpense && sameMonth(item.dueDate, target),
                  )
                  .fold(0.0, (sum, item) => sum + item.amount);
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest
                        .withValues(alpha: .45),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        monthLabel(target).split(' ').first.substring(0, 3),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '- ${money(outgoing)}',
                        style: TextStyle(
                          color: FinanceColors.of(context).expense,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '+ ${money(incoming)}',
                        style: TextStyle(
                          color: FinanceColors.of(context).income,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    ),
  );
}

class AccountMiniCard extends StatelessWidget {
  const AccountMiniCard({
    super.key,
    required this.account,
    required this.value,
    required this.available,
    required this.onTap,
    this.detail,
  });
  final FinanceAccount account;
  final double value, available;
  final VoidCallback onTap;
  final String? detail;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 235,
    child: Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    account.isCard
                        ? Icons.credit_card_rounded
                        : Icons.account_balance_rounded,
                    color: account.isCard
                        ? FinanceColors.of(context).installment
                        : FinanceColors.of(context).income,
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 13),
                ],
              ),
              const Spacer(),
              Text(
                account.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(
                account.isCard ? '${money(value)} na fatura' : money(value),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                account.isCard && detail != null
                    ? detail!
                    : account.isCard
                    ? '${money(available)} disponíveis'
                    : 'saldo atual',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class CategorySummary extends StatelessWidget {
  const CategorySummary({super.key, required this.transactions});
  final List<FinanceTransaction> transactions;
  @override
  Widget build(BuildContext context) {
    final totals = <String, double>{};
    for (final item in transactions.where((item) => item.isExpense)) {
      totals[item.category] = (totals[item.category] ?? 0) + item.amount;
    }
    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxValue = sorted.isEmpty ? 1.0 : sorted.first.value;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gastos por categoria',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 15),
            if (sorted.isEmpty)
              const Text('Nenhuma despesa neste mês.')
            else
              ...sorted
                  .take(5)
                  .map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                money(entry.value),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          LinearProgressIndicator(
                            value: entry.value / maxValue,
                            minHeight: 7,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.item,
    this.account,
    this.onActions,
  });
  final FinanceTransaction item;
  final FinanceAccount? account;
  final VoidCallback? onActions;
  @override
  Widget build(BuildContext context) {
    final color = item.color(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: .13),
        child: Icon(item.icon, color: color, size: 20),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
          if (item.isInstallment)
            StatusPill(
              '${item.installmentNumber}/${item.installmentCount}',
              FinanceColors.of(context).installment,
            ),
          if (item.isRecurring)
            const Padding(
              padding: EdgeInsets.only(left: 5),
              child: Icon(Icons.repeat_rounded, size: 15),
            ),
          if (onActions != null)
            IconButton(
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints.tightFor(width: 34, height: 34),
              padding: EdgeInsets.zero,
              tooltip: 'Ações da transação',
              onPressed: onActions,
              icon: const Icon(Icons.more_vert_rounded, size: 19),
            ),
        ],
      ),
      subtitle: item.isCardPayment
          ? Text(
              '${account?.name ?? 'Conta'} \u00b7 ${shortDate(item.date)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11),
            )
          : Text(
              '${item.category} · ${account?.name ?? 'Conta'} · ${shortDate(item.dueDate)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11),
            ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${item.isIncome
                ? '+'
                : item.isTransfer
                ? ''
                : '-'} ${money(item.amount)}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
          StatusPill(
            statusLabel(item.status),
            statusColor(context, item.status),
          ),
        ],
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill(this.label, this.color, {super.key});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(left: 5, top: 2),
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w700),
    ),
  );
}

String statusLabel(String status) => status == 'paid'
    ? 'Pago'
    : status == 'pending'
    ? 'Pendente'
    : 'Previsto';
Color statusColor(BuildContext context, String status) {
  final colors = FinanceColors.of(context);
  return status == 'paid'
      ? colors.income
      : status == 'pending'
      ? colors.warning
      : colors.installment;
}

class PageHeading extends StatelessWidget {
  const PageHeading(this.title, this.subtitle, {super.key});
  final String title, subtitle;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: -.7,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        subtitle,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    ],
  );
}
