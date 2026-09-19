import 'package:flutter/material.dart';

import '../../../../app/app_theme.dart';
import '../../application/finance_controller.dart';
import '../../domain/models.dart';
import '../widgets/finance_widgets.dart';

typedef OpenInvoicePayment = Future<void> Function(
  CardInvoiceSummary summary, {
  FinanceTransaction? editing,
});

class CardAccountDetailsPage extends StatefulWidget {
  const CardAccountDetailsPage({
    super.key,
    required this.account,
    required this.controller,
    required this.onEditPurchase,
    required this.onPay,
    required this.onDeletePayment,
  });

  final FinanceAccount account;
  final FinanceController controller;
  final ValueChanged<FinanceTransaction> onEditPurchase;
  final OpenInvoicePayment onPay;
  final ValueChanged<FinanceTransaction> onDeletePayment;

  @override
  State<CardAccountDetailsPage> createState() => _CardAccountDetailsPageState();
}

class _CardAccountDetailsPageState extends State<CardAccountDetailsPage> {
  DateTime month = monthStart(DateTime.now());

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      final summary = widget.controller.invoiceSummary(widget.account, month);
      final monthTransactions = widget.controller.transactionsForMonth(month);
      final purchases =
          monthTransactions
              .where(
                (item) =>
                    item.accountId == widget.account.id &&
                    item.isExpense &&
                    sameMonth(item.dueDate, month),
              )
              .toList()
            ..sort((a, b) => b.date.compareTo(a.date));
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
              label: 'Restante da fatura',
              value: money(summary.remaining),
              icon: Icons.credit_card_rounded,
              color: _statusColor(context, summary.status),
              footer:
                  '${money(widget.controller.cardAvailableLimit(widget.account))} '
                  'de limite dispon\u00edvel',
            ),
            const SizedBox(height: 12),
            _InvoiceOverview(summary: summary),
            if (!summary.isTracked) ...[
              const SizedBox(height: 12),
              Card(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: const Padding(
                  padding: EdgeInsets.all(14),
                  child: Text(
                    'Hist\u00f3rico sem controle de pagamento. O acompanhamento '
                    'deste cart\u00e3o come\u00e7a na fatura atual.',
                  ),
                ),
              ),
            ],
            if (summary.canPay) ...[
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => widget.onPay(summary),
                icon: const Icon(Icons.account_balance_wallet_rounded),
                label: const Padding(
                  padding: EdgeInsets.all(13),
                  child: Text('Pagar fatura'),
                ),
              ),
            ],
            const SizedBox(height: 12),
            ProjectionCard(
              transactions: widget.controller
                  .transactionsForRange(
                    monthStart(month),
                    DateTime(month.year, month.month + 4, 0),
                  )
                  .where(
                    (item) =>
                        item.accountId == widget.account.id && item.isExpense,
                  )
                  .toList(),
              month: month,
            ),
            const SizedBox(height: 18),
            const Text(
              'Itens da fatura',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            _TransactionSection(
              emptyMessage: 'Nenhuma compra nesta fatura.',
              children: purchases
                  .map(
                    (item) => InkWell(
                      onTap: () => widget.onEditPurchase(item),
                      borderRadius: BorderRadius.circular(12),
                      child: TransactionTile(
                        item: item,
                        account: widget.account,
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 18),
            const Text(
              'Pagamentos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            _TransactionSection(
              emptyMessage: 'Nenhum pagamento registrado.',
              children: summary.payments
                  .map(
                    (payment) => _PaymentTile(
                      payment: payment,
                      source: widget.controller.accounts
                          .where((account) => account.id == payment.accountId)
                          .firstOrNull,
                      onEdit: () => widget.onPay(summary, editing: payment),
                      onDelete: () => widget.onDeletePayment(payment),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      );
    },
  );
}

class _InvoiceOverview extends StatelessWidget {
  const _InvoiceOverview({required this.summary});

  final CardInvoiceSummary summary;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _OverviewValue(label: 'Total', value: summary.total),
              ),
              Expanded(
                child: _OverviewValue(label: 'Pago', value: summary.paid),
              ),
              Expanded(
                child: _OverviewValue(
                  label: 'Restante',
                  value: summary.remaining,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Wrap(
            spacing: 14,
            runSpacing: 8,
            children: [
              _InfoChip(
                icon: Icons.lock_clock_rounded,
                label: 'Fecha em ${shortDate(summary.closingDate)}',
              ),
              _InfoChip(
                icon: Icons.event_rounded,
                label: 'Vence em ${shortDate(summary.dueDate)}',
              ),
              _InfoChip(
                icon: Icons.info_outline_rounded,
                label: cardInvoiceStatusLabel(summary.status),
                color: _statusColor(context, summary.status),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _OverviewValue extends StatelessWidget {
  const _OverviewValue({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        money(value),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
      ),
    ],
  );
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: (color ?? Theme.of(context).colorScheme.primary).withValues(
        alpha: .1,
      ),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    ),
  );
}

class _TransactionSection extends StatelessWidget {
  const _TransactionSection({
    required this.emptyMessage,
    required this.children,
  });

  final String emptyMessage;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: children.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(18),
              child: Text(emptyMessage),
            )
          : Column(children: children),
    ),
  );
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({
    required this.payment,
    required this.source,
    required this.onEdit,
    required this.onDelete,
  });

  final FinanceTransaction payment;
  final FinanceAccount? source;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
    leading: CircleAvatar(
      backgroundColor: Theme.of(context).colorScheme.primary
          .withValues(alpha: .12),
      child: Icon(
        Icons.account_balance_wallet_rounded,
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
    title: const Text(
      'Pagamento de fatura',
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
    ),
    subtitle: Text(
      '${source?.name ?? 'Conta removida'} \u00b7 ${shortDate(payment.date)}',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          money(payment.amount),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        PopupMenuButton<String>(
          tooltip: 'A\u00e7\u00f5es do pagamento',
          onSelected: (action) {
            if (action == 'edit') onEdit();
            if (action == 'delete') onDelete();
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'edit', child: Text('Editar pagamento')),
            PopupMenuItem(value: 'delete', child: Text('Estornar pagamento')),
          ],
        ),
      ],
    ),
  );
}

String cardInvoiceStatusLabel(CardInvoiceStatus status) => switch (status) {
  CardInvoiceStatus.untracked => 'Hist\u00f3rico n\u00e3o rastreado',
  CardInvoiceStatus.open => 'Fatura aberta',
  CardInvoiceStatus.closed => 'Fatura fechada',
  CardInvoiceStatus.partiallyPaid => 'Parcialmente paga',
  CardInvoiceStatus.paid => 'Fatura paga',
  CardInvoiceStatus.overdue => 'Fatura vencida',
};

Color _statusColor(BuildContext context, CardInvoiceStatus status) =>
    switch (status) {
      CardInvoiceStatus.paid => Theme.of(context).colorScheme.primary,
      CardInvoiceStatus.overdue => Theme.of(context).colorScheme.error,
      CardInvoiceStatus.partiallyPaid => FinanceColors.of(context).warning,
      CardInvoiceStatus.untracked => Theme.of(
        context,
      ).colorScheme.onSurfaceVariant,
      _ => Theme.of(context).colorScheme.tertiary,
    };
