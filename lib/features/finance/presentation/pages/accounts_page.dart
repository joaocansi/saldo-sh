import 'package:flutter/material.dart';

import '../../../../app/app_theme.dart';
import '../../domain/models.dart';
import '../widgets/finance_widgets.dart';
import '../widgets/account_editor.dart';

class AccountsPage extends StatelessWidget {
  const AccountsPage({
    super.key,
    required this.accounts,
    required this.balanceFor,
    required this.invoiceSummaryFor,
    required this.availableFor,
    required this.onAdd,
    required this.onDelete,
    required this.onOpen,
  });
  final List<FinanceAccount> accounts;
  final double Function(FinanceAccount) balanceFor;
  final CardInvoiceSummary Function(FinanceAccount, DateTime) invoiceSummaryFor;
  final double Function(FinanceAccount) availableFor;
  final ValueChanged<FinanceAccount> onAdd, onDelete, onOpen;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(22, 8, 22, 110),
    children: [
      Row(
        children: [
          const Expanded(
            child: PageHeading(
              'Contas e cartões',
              'Saldos, limites e faturas em um só lugar.',
            ),
          ),
          FilledButton.icon(
            onPressed: () => accountDialog(context, onAdd),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Nova'),
          ),
        ],
      ),
      const SizedBox(height: 18),
      if (accounts.isEmpty)
        _AccountsEmptyState(onCreate: () => accountDialog(context, onAdd))
      else
        ...accounts.map((account) {
          final currentInvoice = account.isCard
              ? invoiceSummaryFor(account, monthStart(DateTime.now()))
              : null;
          final available = account.isCard ? availableFor(account) : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 11),
            child: Card(
              child: InkWell(
                onTap: () => onOpen(account),
                onLongPress: () => onDelete(account),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(17),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final identity = _AccountIdentity(
                        account: account,
                        available: available,
                        showChevron: constraints.maxWidth < 430,
                        onDelete: () => onDelete(account),
                      );
                      final value = _AccountValue(
                        value: account.isCard
                            ? currentInvoice!.remaining
                            : balanceFor(account),
                        label: account.isCard
                            ? currentInvoice!.paidCents > 0
                                  ? 'pago ${money(currentInvoice.paid)} de ${money(currentInvoice.total)}'
                                  : 'restante da fatura atual'
                            : 'saldo',
                      );
                      if (constraints.maxWidth < 430) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            identity,
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: value,
                            ),
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(child: identity),
                          const SizedBox(width: 12),
                          value,
                          const SizedBox(width: 6),
                          const Icon(Icons.chevron_right_rounded),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        }),
    ],
  );
}

class _AccountsEmptyState extends StatelessWidget {
  const _AccountsEmptyState({required this.onCreate});

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
                Icons.account_balance_wallet_rounded,
                size: 30,
                color: colors.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Comece organizando seu dinheiro',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Adicione sua primeira conta, carteira ou cartão para acompanhar '
              'saldos, gastos e faturas em um só lugar.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Criar conta ou cartão'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountIdentity extends StatelessWidget {
  const _AccountIdentity({
    required this.account,
    required this.available,
    required this.showChevron,
    required this.onDelete,
  });

  final FinanceAccount account;
  final double available;
  final bool showChevron;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: account.isCard
              ? FinanceColors.of(context).expense
              : FinanceColors.of(context).income,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          account.isCard
              ? Icons.credit_card_rounded
              : Icons.account_balance_rounded,
          color: Colors.white,
        ),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              account.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            Text(
              account.isCard
                  ? 'Fecha dia ${account.closingDay} · vence dia ${account.dueDay}'
                  : 'Conta de saldo',
              style: const TextStyle(fontSize: 11),
            ),
            if (account.isCard)
              Text(
                '${money(available)} de limite dispon\u00edvel',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  color: FinanceColors.of(context).installment,
                ),
              ),
          ],
        ),
      ),
      PopupMenuButton<String>(
        tooltip: 'Ações de ${account.name}',
        position: PopupMenuPosition.under,
        onSelected: (action) {
          if (action == 'delete') onDelete();
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(
                  Icons.delete_outline_rounded,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 10),
                Text(account.isCard ? 'Excluir cartão' : 'Excluir conta'),
              ],
            ),
          ),
        ],
      ),
      if (showChevron) ...[
        const SizedBox(width: 6),
        const Icon(Icons.chevron_right_rounded),
      ],
    ],
  );
}

class _AccountValue extends StatelessWidget {
  const _AccountValue({required this.value, required this.label});

  final double value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Text(
        money(value),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      ),
      Text(label, style: const TextStyle(fontSize: 10)),
    ],
  );
}

Future<void> accountDialog(
  BuildContext context,
  ValueChanged<FinanceAccount> onSave,
) async {
  final account = await showAccountEditor(context);
  if (account != null) onSave(account);
}

class AccountDetailsPage extends StatefulWidget {
  const AccountDetailsPage({
    super.key,
    required this.account,
    required this.transactions,
    required this.invoiceFor,
    required this.balanceFor,
    required this.onEdit,
    required this.transactionsForMonth,
  });
  final FinanceAccount account;
  final List<FinanceTransaction> transactions;
  final double Function(FinanceAccount, DateTime) invoiceFor;
  final double Function(FinanceAccount) balanceFor;
  final ValueChanged<FinanceTransaction> onEdit;
  final List<FinanceTransaction> Function(DateTime month) transactionsForMonth;
  @override
  State<AccountDetailsPage> createState() => _AccountDetailsPageState();
}

class _AccountDetailsPageState extends State<AccountDetailsPage> {
  DateTime month = monthStart(DateTime.now());
  @override
  Widget build(BuildContext context) {
    final monthTransactions = widget.transactionsForMonth(month);
    final items =
        monthTransactions
            .where(
              (item) =>
                  item.accountId == widget.account.id &&
                  sameMonth(
                    item.isCardPayment ? item.date : item.dueDate,
                    month,
                  ),
            )
            .toList()
          ..sort(
            (a, b) => (b.isCardPayment ? b.date : b.dueDate).compareTo(
              a.isCardPayment ? a.date : a.dueDate,
            ),
          );
    final invoice = widget.invoiceFor(widget.account, month);
    final future = widget.transactions
        .where(
          (item) =>
              item.accountId == widget.account.id &&
              item.isExpense &&
              item.dueDate.isAfter(DateTime.now()),
        )
        .fold(0.0, (sum, item) => sum + item.amount);
    return Scaffold(
      appBar: AppBar(title: Text(widget.account.name)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 40),
        children: [
          MonthSelector(
            month: month,
            onChanged: (value) => setState(() => month = value),
          ),
          const SizedBox(height: 12),
          SummaryCard(
            label: widget.account.isCard ? 'Fatura do mês' : 'Saldo atual',
            value: money(
              widget.account.isCard
                  ? invoice
                  : widget.balanceFor(widget.account),
            ),
            icon: widget.account.isCard
                ? Icons.credit_card_rounded
                : Icons.account_balance_rounded,
            color: FinanceColors.of(context).income,
            footer: widget.account.isCard
                ? '${money(widget.account.limit - future)} de limite disponível'
                : 'considerando lançamentos pagos',
          ),
          if (widget.account.isCard) ...[
            const SizedBox(height: 12),
            ProjectionCard(
              transactions: widget.transactions
                  .where((item) => item.accountId == widget.account.id)
                  .toList(),
              month: month,
            ),
          ],
          const SizedBox(height: 16),
          Text(
            widget.account.isCard ? 'Itens da fatura' : 'Movimentações',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: items.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(18),
                      child: Text('Nenhum lançamento neste período.'),
                    )
                  : Column(
                      children: items
                          .map(
                            (item) => InkWell(
                              onTap: () => widget.onEdit(item),
                              borderRadius: BorderRadius.circular(12),
                              child: TransactionTile(
                                item: item,
                                account: widget.account,
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
