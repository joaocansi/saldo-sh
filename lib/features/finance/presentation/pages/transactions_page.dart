import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/app_select_field.dart';
import '../../domain/models.dart';
import '../widgets/finance_widgets.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({
    super.key,
    required this.transactions,
    required this.accounts,
    required this.onEdit,
    required this.onDelete,
    required this.onPaid,
    this.transactionsForMonth,
  });
  final List<FinanceTransaction> transactions;
  final List<FinanceAccount> accounts;
  final ValueChanged<FinanceTransaction> onEdit, onPaid;
  final Future<void> Function(FinanceTransaction, bool) onDelete;
  final List<FinanceTransaction> Function(DateTime month)? transactionsForMonth;
  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final search = TextEditingController();
  String accountId = 'all';
  String status = 'all';
  DateTime month = monthStart(DateTime.now());

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final source =
        widget.transactionsForMonth?.call(month) ?? widget.transactions;
    final filtered =
        source
            .where(
              (item) =>
                  sameMonth(
                    item.isCardPayment ? item.date : item.dueDate,
                    month,
                  ) &&
                  (accountId == 'all' ||
                      item.accountId == accountId ||
                      item.targetAccountId == accountId) &&
                  (status == 'all' || item.status == status) &&
                  (search.text.isEmpty ||
                      '${item.name} ${item.category}'.toLowerCase().contains(
                        search.text.toLowerCase(),
                      )),
            )
            .toList()
          ..sort(
            (a, b) => (b.isCardPayment ? b.date : b.dueDate).compareTo(
              a.isCardPayment ? a.date : a.dueDate,
            ),
          );
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 110),
      children: [
        const PageHeading(
          'Transações',
          'Pesquise e filtre por mês, conta ou situação.',
        ),
        const SizedBox(height: 14),
        MonthSelector(
          month: month,
          onChanged: (value) => setState(() => month = value),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: search,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search_rounded),
            hintText: 'Buscar por nome ou categoria',
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: AppSelectField<String>(
                value: accountId,
                label: 'Conta/cartão',
                options: [
                  const AppSelectOption(value: 'all', label: 'Todas'),
                  ...widget.accounts.map(
                    (account) =>
                        AppSelectOption(value: account.id, label: account.name),
                  ),
                ],
                onChanged: (value) => setState(() => accountId = value),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppSelectField<String>(
                value: status,
                label: 'Situação',
                options: const [
                  AppSelectOption(value: 'all', label: 'Todas'),
                  AppSelectOption(value: 'paid', label: 'Pago'),
                  AppSelectOption(value: 'pending', label: 'Pendente'),
                  AppSelectOption(value: 'planned', label: 'Previsto'),
                ],
                onChanged: (value) => setState(() => status = value),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: filtered.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: Text('Nenhuma transação encontrada.')),
                  )
                : Column(
                    children: filtered.map((item) {
                      final account = widget.accounts
                          .where((account) => account.id == item.accountId)
                          .firstOrNull;
                      return InkWell(
                        onTap: () => widget.onEdit(item),
                        onLongPress: () => transactionActions(context, item),
                        borderRadius: BorderRadius.circular(14),
                        child: TransactionTile(
                          item: item,
                          account: account,
                          onActions: () => transactionActions(context, item),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> transactionActions(
    BuildContext context,
    FinanceTransaction item,
  ) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            if (!item.isCardPayment && item.status != 'paid')
              ListTile(
                leading: const Icon(Icons.check_circle_outline_rounded),
                title: const Text('Marcar como pago'),
                onTap: () => Navigator.pop(context, 'paid'),
              ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(item.isCardPayment ? 'Editar pagamento' : 'Editar'),
              onTap: () => Navigator.pop(context, 'edit'),
            ),
            ListTile(
              leading: Icon(
                Icons.delete_outline_rounded,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                item.isCardPayment
                    ? 'Estornar pagamento'
                    : item.isInstallment || item.isRecurring
                    ? 'Excluir somente esta'
                    : 'Excluir transação',
              ),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
            if (item.isInstallment || item.isRecurring)
              ListTile(
                leading: Icon(
                  Icons.delete_sweep_outlined,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: const Text('Excluir esta e as futuras'),
                onTap: () => Navigator.pop(context, 'future'),
              ),
          ],
        ),
      ),
    );
    if (action == 'paid') widget.onPaid(item);
    if (action == 'edit') widget.onEdit(item);
    if (action == 'delete') widget.onDelete(item, false);
    if (action == 'future') widget.onDelete(item, true);
  }
}
