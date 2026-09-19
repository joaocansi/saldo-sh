import 'package:flutter/material.dart';

import '../../../../app/app_theme.dart';
import '../../domain/models.dart';
import '../widgets/finance_widgets.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    super.key,
    required this.displayName,
    required this.month,
    required this.transactions,
    required this.accounts,
    required this.budgets,
    required this.cashFlowProjections,
    required this.balanceFor,
    required this.invoiceSummaryFor,
    required this.availableFor,
    required this.onMonth,
    required this.onTransactions,
    required this.onAccount,
  });
  final String displayName;
  final DateTime month;
  final List<FinanceTransaction> transactions;
  final List<FinanceAccount> accounts;
  final List<FinanceBudget> budgets;
  final List<CashFlowProjection> cashFlowProjections;
  final double Function(FinanceAccount) balanceFor;
  final CardInvoiceSummary Function(FinanceAccount, DateTime) invoiceSummaryFor;
  final double Function(FinanceAccount) availableFor;
  final ValueChanged<DateTime> onMonth;
  final ValueChanged<FinanceAccount> onAccount;
  final VoidCallback onTransactions;

  @override
  Widget build(BuildContext context) {
    final financeColors = FinanceColors.of(context);
    final monthItems = transactions
        .where((item) => sameMonth(item.dueDate, month))
        .toList();
    final income = monthItems
        .where((item) => item.isIncome)
        .fold(0.0, (sum, item) => sum + item.amount);
    final expense = monthItems
        .where((item) => item.isExpense)
        .fold(0.0, (sum, item) => sum + item.amount);
    final plannedIncome = monthItems
        .where((item) => item.isIncome && item.isPlanned)
        .fold(0.0, (sum, item) => sum + item.amount);
    final plannedExpense = monthItems
        .where((item) => item.isExpense && item.isPlanned)
        .fold(0.0, (sum, item) => sum + item.amount);
    final cashBalance = accounts
        .where((item) => !item.isCard)
        .fold(0.0, (sum, item) => sum + balanceFor(item));
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 110),
      children: [
        Text(
          'Olá, ${displayName.split(RegExp(r'\s+')).first}',
          style: const TextStyle(
            fontSize: 31,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Acompanhe o realizado e o que ainda vem pela frente.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 18),
        MonthSelector(month: month, onChanged: onMonth),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (_, box) {
            final cards = [
              SummaryCard(
                label: 'Saldo disponível',
                value: money(cashBalance),
                icon: Icons.account_balance_wallet_rounded,
                color: financeColors.income,
                footer: 'em contas',
              ),
              SummaryCard(
                label: 'Entradas do mês',
                value: money(income),
                icon: Icons.south_west_rounded,
                color: financeColors.income,
                footer: '${money(plannedIncome)} previstas',
              ),
              SummaryCard(
                label: 'Saídas do mês',
                value: money(expense),
                icon: Icons.north_east_rounded,
                color: financeColors.expense,
                footer: '${money(plannedExpense)} previstas',
              ),
            ];
            return box.maxWidth < 760
                ? Column(
                    children: cards
                        .map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: item,
                          ),
                        )
                        .toList(),
                  )
                : Row(
                    children: [
                      for (var i = 0; i < cards.length; i++) ...[
                        Expanded(child: cards[i]),
                        if (i < cards.length - 1) const SizedBox(width: 12),
                      ],
                    ],
                  );
          },
        ),
        const SizedBox(height: 18),
        CashFlowProjectionCard(projections: cashFlowProjections),
        const SizedBox(height: 18),
        Text(
          'Contas e cartões',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        if (accounts.isNotEmpty)
          SizedBox(
            height: 142,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: accounts.map((account) {
                final invoice = account.isCard
                    ? invoiceSummaryFor(account, month)
                    : null;
                final value = invoice?.remaining ?? balanceFor(account);
                final available = account.isCard
                    ? availableFor(account)
                    : value;
                final detail = invoice != null && invoice.paidCents > 0
                    ? 'Pago ${money(invoice.paid)} de ${money(invoice.total)} '
                          '\u00b7 ${money(available)} dispon\u00edveis'
                    : null;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: AccountMiniCard(
                    account: account,
                    value: value,
                    available: available,
                    detail: detail,
                    onTap: () => onAccount(account),
                  ),
                );
              }).toList(),
            ),
          ),
        if (accounts.isEmpty)
          Text(
            'Nenhuma conta ou cartão de crédito registrado.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        const SizedBox(height: 18),
        CategorySummary(transactions: monthItems),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Movimentações recentes',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: onTransactions,
                      child: const Text('Ver todas'),
                    ),
                  ],
                ),
                ...monthItems
                    .take(5)
                    .map(
                      (item) => TransactionTile(
                        item: item,
                        account: accounts
                            .where((account) => account.id == item.accountId)
                            .firstOrNull,
                      ),
                    ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
