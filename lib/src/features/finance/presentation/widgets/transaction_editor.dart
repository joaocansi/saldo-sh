import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/app_select_field.dart';
import '../../application/transaction_builder.dart';
import '../../domain/models.dart';
import 'form_fields.dart';

class TransactionSaveResult {
  const TransactionSaveResult(this.items, {required this.draft});

  final List<FinanceTransaction> items;
  final TransactionDraft draft;
}

class TransactionEditor extends StatefulWidget {
  const TransactionEditor({
    super.key,
    required this.accounts,
    this.editing,
    this.initialDraft,
  });

  final List<FinanceAccount> accounts;
  final FinanceTransaction? editing;
  final TransactionDraft? initialDraft;

  @override
  State<TransactionEditor> createState() => _TransactionEditorState();
}

class _TransactionEditorState extends State<TransactionEditor> {
  static const _builder = TransactionBuilder();

  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;
  final _formKey = GlobalKey<FormState>();

  late String _type;
  late String _category;
  late String _accountId;
  late String _status;
  late String _recurrence;
  late DateTime _date;
  late DateTime _dueDate;
  String _repeatMode = 'single';
  String? _targetAccountId;
  int _installmentCount = 2;
  int _initialInstallment = 1;
  bool _submitted = false;
  String? _accountError;
  String? _targetAccountError;

  @override
  void initState() {
    super.initState();
    final transaction = widget.editing;
    final draft = widget.initialDraft;
    _nameController = TextEditingController(
      text: transaction?.name ?? draft?.name ?? '',
    );
    _amountController = TextEditingController(
      text:
          transaction?.amount.toStringAsFixed(2) ??
          (draft == null ? '' : draft.amount.toStringAsFixed(2)),
    );
    _notesController = TextEditingController(
      text: transaction?.notes ?? draft?.notes ?? '',
    );
    _type = transaction?.type ?? draft?.type ?? 'expense';
    _category =
        transaction?.category ?? draft?.category ?? financeCategories.first;
    final selectedAccountId = transaction?.accountId ?? draft?.accountId;
    _accountId = widget.accounts.any((item) => item.id == selectedAccountId)
        ? selectedAccountId!
        : (widget.accounts.firstOrNull?.id ?? '');
    _targetAccountId = transaction?.targetAccountId ?? draft?.targetAccountId;
    _status = transaction?.status ?? draft?.status ?? 'paid';
    _recurrence = transaction?.recurrence ?? draft?.recurrence ?? 'monthly';
    _date = transaction?.date ?? draft?.date ?? DateTime.now();
    _dueDate = transaction?.dueDate ?? draft?.dueDate ?? DateTime.now();

    if (draft != null) {
      _repeatMode = draft.mode;
      _installmentCount = draft.installmentCount;
      _initialInstallment = draft.initialInstallment;
    }

    if (transaction?.isInstallment == true) {
      _repeatMode = 'installment';
      _installmentCount = transaction!.installmentCount;
      _initialInstallment = transaction.installmentNumber;
    } else if (transaction?.isRecurring == true) {
      _repeatMode = 'recurring';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    final amount =
        double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0;
    setState(() {
      _submitted = true;
      _accountError = _accountId.isEmpty
          ? 'Selecione uma conta ou cartão.'
          : null;
      _targetAccountError = _validateTargetAccount();
    });
    if (!_formKey.currentState!.validate() ||
        _accountError != null ||
        _targetAccountError != null) {
      return;
    }

    final draft = TransactionDraft(
      name: _nameController.text.trim(),
      amount: amount,
      category: _category,
      type: _type,
      accountId: _accountId,
      targetAccountId: _targetAccountId,
      date: _date,
      dueDate: _dueDate,
      status: _status,
      mode: _repeatMode,
      recurrence: _recurrence,
      installmentCount: _installmentCount,
      initialInstallment: _initialInstallment,
      notes: _notesController.text.trim(),
    );
    final transactions = _builder.build(
      draft,
      widget.accounts,
      editing: widget.editing,
    );
    Navigator.pop(context, TransactionSaveResult(transactions, draft: draft));
  }

  @override
  Widget build(BuildContext context) => DraggableScrollableSheet(
    initialChildSize: .91,
    minChildSize: .55,
    maxChildSize: .96,
    builder: (_, scrollController) => Material(
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
            const _SheetHandle(),
            const SizedBox(height: 16),
            _buildHeader(),
            const SizedBox(height: 15),
            _buildTypeSelector(),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                final name = value?.trim() ?? '';
                if (name.isEmpty) return 'Informe o nome da transação.';
                if (name.length > 160) return 'Use no máximo 160 caracteres.';
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Nome da transação *',
                prefixIcon: Icon(Icons.edit_note_rounded),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return 'Informe o valor.';
                final parsed = double.tryParse(text.replaceAll(',', '.'));
                if (parsed == null || parsed <= 0) {
                  return 'Informe um valor maior que zero.';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Valor *',
                prefixText: 'R\$ ',
              ),
            ),
            const SizedBox(height: 10),
            _buildCategoryAndAccount(),
            if (_type == 'transfer') _buildTargetAccount(),
            const SizedBox(height: 10),
            _buildDates(),
            const SizedBox(height: 10),
            _buildStatus(),
            if (widget.editing == null && _type != 'transfer')
              _buildRepetition(),
            const SizedBox(height: 10),
            TextField(
              controller: _notesController,
              minLines: 1,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Observação',
                prefixIcon: Icon(Icons.notes_rounded),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.check_rounded),
              label: const Padding(
                padding: EdgeInsets.all(14),
                child: Text('Salvar localmente'),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildHeader() => Text(
    widget.editing == null ? 'Novo lançamento' : 'Editar lançamento',
    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
  );

  Widget _buildTypeSelector() => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < 390;
      return SegmentedButton<String>(
        showSelectedIcon: false,
        segments: [
          ButtonSegment(
            value: 'expense',
            label: const Text('Despesa'),
            icon: compact ? null : const Icon(Icons.north_east_rounded),
          ),
          ButtonSegment(
            value: 'income',
            label: const Text('Receita'),
            icon: compact ? null : const Icon(Icons.south_west_rounded),
          ),
          ButtonSegment(
            value: 'transfer',
            label: const Text('Transferir'),
            icon: compact ? null : const Icon(Icons.swap_horiz_rounded),
          ),
        ],
        selected: {_type},
        onSelectionChanged: (value) => setState(() {
          _type = value.first;
          _targetAccountError = _validateTargetAccount();
        }),
      );
    },
  );

  Widget _buildCategoryAndAccount() => LayoutBuilder(
    builder: (context, constraints) {
      final category = AppSelectField<String>(
        value: _category,
        label: 'Categoria',
        options: financeCategories
            .map((item) => AppSelectOption(value: item, label: item))
            .toList(),
        onChanged: (value) => setState(() => _category = value),
      );
      final account = AppSelectField<String>(
        value: _accountId.isEmpty ? null : _accountId,
        label: 'Conta/cartão *',
        errorText: _accountError,
        options: widget.accounts
            .map((item) => AppSelectOption(value: item.id, label: item.name))
            .toList(),
        onChanged: (value) => setState(() {
          _accountId = value;
          _accountError = null;
          if (_targetAccountId == value) _targetAccountId = null;
          _targetAccountError = _validateTargetAccount();
        }),
      );

      if (constraints.maxWidth < 360) {
        return Column(
          children: [category, const SizedBox(height: 10), account],
        );
      }
      return Row(
        children: [
          Expanded(child: category),
          const SizedBox(width: 9),
          Expanded(child: account),
        ],
      );
    },
  );

  Widget _buildTargetAccount() => Padding(
    padding: const EdgeInsets.only(top: 10),
    child: AppSelectField<String>(
      value: _targetAccountId,
      label: 'Conta de destino *',
      errorText: _targetAccountError,
      options: widget.accounts
          .where((item) => item.id != _accountId && !item.isCard)
          .map((item) => AppSelectOption(value: item.id, label: item.name))
          .toList(),
      onChanged: (value) => setState(() {
        _targetAccountId = value;
        _targetAccountError = _validateTargetAccount();
      }),
    ),
  );

  String? _validateTargetAccount() {
    if (_type != 'transfer') return null;
    if (_targetAccountId == null || _targetAccountId!.isEmpty) {
      return _submitted ? 'Selecione a conta de destino.' : null;
    }
    if (_targetAccountId == _accountId) {
      return 'A conta de destino deve ser diferente.';
    }
    return null;
  }

  Widget _buildDates() => Row(
    children: [
      Expanded(
        child: DateButton(
          label: 'Data',
          value: _date,
          onChanged: (value) => setState(() => _date = value),
        ),
      ),
      const SizedBox(width: 9),
      Expanded(
        child: DateButton(
          label: 'Vencimento',
          value: _dueDate,
          onChanged: (value) => setState(() => _dueDate = value),
        ),
      ),
    ],
  );

  Widget _buildStatus() => AppSelectField<String>(
    value: _status,
    label: 'Situação',
    options: const [
      AppSelectOption(value: 'paid', label: 'Pago/recebido'),
      AppSelectOption(value: 'pending', label: 'Pendente'),
      AppSelectOption(value: 'planned', label: 'Previsto'),
    ],
    onChanged: (value) => setState(() => _status = value),
  );

  Widget _buildRepetition() => Padding(
    padding: const EdgeInsets.only(top: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Repetição', style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 7),
        Wrap(
          spacing: 7,
          children: [
            for (final option in const [
              ('single', 'Única'),
              ('installment', 'Parcelada'),
              ('recurring', 'Recorrente'),
            ])
              ChoiceChip(
                label: Text(option.$2),
                selected: _repeatMode == option.$1,
                onSelected: (_) => setState(() => _repeatMode = option.$1),
              ),
          ],
        ),
        if (_repeatMode == 'installment') _buildInstallments(),
        if (_repeatMode == 'recurring') _buildRecurrence(),
      ],
    ),
  );

  Widget _buildInstallments() => Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: NumberField(
                label: 'Total de parcelas',
                value: _installmentCount,
                min: 2,
                max: 60,
                onChanged: (value) => setState(() {
                  _installmentCount = value;
                  if (_initialInstallment > value) {
                    _initialInstallment = value;
                  }
                }),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: NumberField(
                label: 'Parcela inicial',
                value: _initialInstallment,
                min: 1,
                max: _installmentCount,
                onChanged: (value) =>
                    setState(() => _initialInstallment = value),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Será salvo de $_initialInstallment/$_installmentCount até '
          '$_installmentCount/$_installmentCount. O valor informado é o valor '
          'de cada parcela.',
          style: const TextStyle(fontSize: 11),
        ),
      ],
    ),
  );

  Widget _buildRecurrence() => Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSelectField<String>(
          value: _recurrence,
          label: 'Frequência',
          options: const [
            AppSelectOption(value: 'daily', label: 'Diária'),
            AppSelectOption(value: 'weekly', label: 'Semanal'),
            AppSelectOption(value: 'monthly', label: 'Mensal'),
            AppSelectOption(value: 'yearly', label: 'Anual'),
          ],
          onChanged: (value) => setState(() => _recurrence = value),
        ),
        const SizedBox(height: 6),
        Text(
          'As próximas ocorrências serão exibidas como previsões. '
          'Um lançamento real só será criado quando chegar a data.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    ),
  );
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 42,
      height: 4,
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor,
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}
