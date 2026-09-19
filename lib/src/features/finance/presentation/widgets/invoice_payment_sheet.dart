import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/app_select_field.dart';
import '../../domain/models.dart';
import 'form_fields.dart';

class InvoicePaymentSaveResult {
  const InvoicePaymentSaveResult({
    required this.draft,
    required this.negativeBalanceConfirmed,
  });

  final InvoicePaymentDraft draft;
  final bool negativeBalanceConfirmed;
}

class InvoicePaymentSheet extends StatefulWidget {
  const InvoicePaymentSheet({
    super.key,
    required this.summary,
    required this.accounts,
    required this.validate,
    this.editing,
  });

  final CardInvoiceSummary summary;
  final List<FinanceAccount> accounts;
  final InvoicePaymentValidation Function(InvoicePaymentDraft draft) validate;
  final FinanceTransaction? editing;

  @override
  State<InvoicePaymentSheet> createState() => _InvoicePaymentSheetState();
}

class _InvoicePaymentSheetState extends State<InvoicePaymentSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;
  late String? _sourceAccountId;
  late DateTime _paymentDate;
  bool _submitted = false;
  InvoicePaymentValidation? _validation;

  List<FinanceAccount> get _availableAccounts => widget.accounts
      .where((account) => !account.isCard && !account.archived)
      .toList();

  @override
  void initState() {
    super.initState();
    final editing = widget.editing;
    final initialCents = editing == null
        ? widget.summary.remainingCents
        : (editing.amount * 100).round();
    _amountController = TextEditingController(
      text: (initialCents / 100).toStringAsFixed(2).replaceAll('.', ','),
    );
    _notesController = TextEditingController(text: editing?.notes ?? '');
    _sourceAccountId = editing?.accountId ?? _availableAccounts.firstOrNull?.id;
    _paymentDate = editing?.date ?? DateTime.now();
    _refreshValidation();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  InvoicePaymentDraft _draft() => InvoicePaymentDraft(
    cardId: widget.summary.card.id,
    invoicePeriod: widget.summary.period,
    sourceAccountId: _sourceAccountId ?? '',
    amountCents: _parseCents(_amountController.text),
    paymentDate: _paymentDate,
    notes: _notesController.text.trim(),
  );

  void _refreshValidation() {
    _validation = widget.validate(_draft());
  }

  Future<void> _submit() async {
    setState(() {
      _submitted = true;
      _refreshValidation();
    });
    if (!_formKey.currentState!.validate() || !_validation!.isValid) return;

    var negativeConfirmed = false;
    if (_validation!.requiresNegativeBalanceConfirmation) {
      negativeConfirmed =
          await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Saldo ficar\u00e1 negativo'),
              content: Text(
                'Saldo atual: ${money(_validation!.sourceBalanceCents / 100)}\n'
                'Saldo ap\u00f3s o pagamento: '
                '${money(_validation!.resultingBalanceCents / 100)}\n\n'
                'Deseja registrar mesmo assim?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Continuar'),
                ),
              ],
            ),
          ) ??
          false;
      if (!negativeConfirmed || !mounted) return;
    }
    Navigator.pop(
      context,
      InvoicePaymentSaveResult(
        draft: _draft(),
        negativeBalanceConfirmed: negativeConfirmed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => DraggableScrollableSheet(
    initialChildSize: .88,
    minChildSize: .58,
    maxChildSize: .96,
    builder: (context, scrollController) => Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
      child: Form(
        key: _formKey,
        autovalidateMode: _submitted
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        child: ListView(
          controller: scrollController,
          padding: EdgeInsets.fromLTRB(
            20,
            14,
            20,
            MediaQuery.viewInsetsOf(context).bottom + 32,
          ),
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              widget.editing == null ? 'Pagar fatura' : 'Editar pagamento',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.summary.card.name} \u00b7 ${monthLabel(widget.summary.period)}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            _InvoiceValues(summary: widget.summary),
            const SizedBox(height: 16),
            if (_availableAccounts.isEmpty)
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: const Padding(
                  padding: EdgeInsets.all(14),
                  child: Text(
                    'Crie uma conta ou carteira antes de pagar a fatura.',
                  ),
                ),
              )
            else
              AppSelectField<String>(
                value: _sourceAccountId,
                label: 'Conta de origem *',
                errorText: _submitted ? _validation?.sourceError : null,
                options: _availableAccounts
                    .map(
                      (account) => AppSelectOption(
                        value: account.id,
                        label: account.name,
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() {
                  _sourceAccountId = value;
                  _refreshValidation();
                }),
              ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (_) => setState(_refreshValidation),
              validator: (_) => _validation?.amountError,
              decoration: const InputDecoration(
                labelText: 'Valor do pagamento *',
                prefixText: 'R\$ ',
              ),
            ),
            const SizedBox(height: 10),
            DateButton(
              label: 'Data do pagamento',
              value: _paymentDate,
              errorText: _submitted ? _validation?.dateError : null,
              onChanged: (value) => setState(() {
                _paymentDate = value;
                _refreshValidation();
              }),
            ),
            if (_sourceAccountId != null && _validation?.sourceError == null)
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 9, 4, 0),
                child: Text(
                  'Saldo atual: '
                  '${money((_validation?.sourceBalanceCents ?? 0) / 100)} \u00b7 '
                  'Depois: '
                  '${money((_validation?.resultingBalanceCents ?? 0) / 100)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: (_validation?.resultingBalanceCents ?? 0) < 0
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            if (_submitted && _validation?.generalError != null)
              Padding(
                padding: const EdgeInsets.only(top: 9),
                child: Text(
                  _validation!.generalError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const SizedBox(height: 10),
            TextField(
              controller: _notesController,
              minLines: 1,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Observa\u00e7\u00e3o',
                prefixIcon: Icon(Icons.notes_rounded),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _availableAccounts.isEmpty ? null : _submit,
              icon: const Icon(Icons.check_rounded),
              label: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  widget.editing == null
                      ? 'Confirmar pagamento'
                      : 'Salvar altera\u00e7\u00f5es',
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  int _parseCents(String value) {
    var normalized = value.trim().replaceAll(' ', '');
    if (normalized.contains(',')) {
      normalized = normalized.replaceAll('.', '').replaceAll(',', '.');
    }
    final amount = double.tryParse(normalized);
    return amount == null ? 0 : (amount * 100).round();
  }
}

class _InvoiceValues extends StatelessWidget {
  const _InvoiceValues({required this.summary});

  final CardInvoiceSummary summary;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Expanded(
            child: _Value(label: 'Total', cents: summary.totalCents),
          ),
          Expanded(
            child: _Value(label: 'Pago', cents: summary.paidCents),
          ),
          Expanded(
            child: _Value(label: 'Restante', cents: summary.remainingCents),
          ),
        ],
      ),
    ),
  );
}

class _Value extends StatelessWidget {
  const _Value({required this.label, required this.cents});

  final String label;
  final int cents;

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
        money(cents / 100),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
      ),
    ],
  );
}
