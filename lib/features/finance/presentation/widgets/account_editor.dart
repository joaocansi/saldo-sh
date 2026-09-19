import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/presentation/widgets/app_select_field.dart';
import '../../application/account_draft.dart';
import '../../domain/entities/finance_account.dart';

Future<FinanceAccount?> showAccountEditor(
  BuildContext context, {
  AccountDraft? initialDraft,
}) => showDialog<FinanceAccount>(
  context: context,
  builder: (_) => AccountEditor(initialDraft: initialDraft),
);

class AccountEditor extends StatefulWidget {
  const AccountEditor({super.key, this.initialDraft});
  final AccountDraft? initialDraft;

  @override
  State<AccountEditor> createState() => _AccountEditorState();
}

class _AccountEditorState extends State<AccountEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _value;
  late final TextEditingController _closing;
  late final TextEditingController _due;
  late String _kind;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    final draft = widget.initialDraft;
    _kind = draft?.kind ?? 'account';
    _name = TextEditingController(text: draft?.name ?? '');
    _value = TextEditingController(
      text: draft == null
          ? ''
          : ((_kind == 'card' ? draft.limitCents : draft.openingBalanceCents) /
                    100)
                .toStringAsFixed(2)
                .replaceAll('.', ','),
    );
    _closing = TextEditingController(text: (draft?.closingDay ?? 4).toString());
    _due = TextEditingController(text: (draft?.dueDay ?? 10).toString());
  }

  @override
  void dispose() {
    _name.dispose();
    _value.dispose();
    _closing.dispose();
    _due.dispose();
    super.dispose();
  }

  double? _amount(String text) {
    var normalized = text.trim();
    if (normalized.isEmpty) return _kind == 'card' ? null : 0;
    if (normalized.contains(',')) {
      normalized = normalized.replaceAll('.', '').replaceAll(',', '.');
    }
    if (!RegExp(r'^-?\d+(\.\d{1,2})?$').hasMatch(normalized)) return null;
    final value = double.tryParse(normalized);
    return value == null || !value.isFinite || value.abs() > 1000000000
        ? null
        : value;
  }

  String? _day(String? text) {
    final day = int.tryParse(text ?? '');
    return day == null || day < 1 || day > 31
        ? 'Informe um dia de 1 a 31.'
        : null;
  }

  void _save() {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;
    final amount = _amount(_value.text)!;
    Navigator.pop(
      context,
      FinanceAccount(
        id: const Uuid().v4(),
        name: _name.text.trim(),
        kind: _kind,
        openingBalance: _kind == 'card' ? 0 : amount,
        limit: _kind == 'card' ? amount : 0,
        closingDay: _kind == 'card' ? int.parse(_closing.text) : 4,
        dueDay: _kind == 'card' ? int.parse(_due.text) : 10,
      ),
    );
  }

  IconData get _kindIcon => switch (_kind) {
    'card' => Icons.credit_card_rounded,
    'cash' => Icons.account_balance_wallet_rounded,
    _ => Icons.account_balance_rounded,
  };

  String get _kindLabel => switch (_kind) {
    'card' => 'cartão',
    'cash' => 'carteira',
    _ => 'conta',
  };

  String get _title {
    if (widget.initialDraft != null) return 'Revisar $_kindLabel';
    return switch (_kind) {
      'card' => 'Novo cartão',
      'cash' => 'Nova carteira',
      _ => 'Nova conta',
    };
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _kindIcon,
            size: 21,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(_title)),
      ],
    ),
    content: SizedBox(
      width: 380,
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          autovalidateMode: _submitted
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Nome'),
                maxLength: 160,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Informe o nome.'
                    : RegExp(r'[\x00-\x1f\x7f]').hasMatch(value)
                    ? 'Use um nome válido.'
                    : null,
              ),
              const SizedBox(height: 10),
              AppSelectField<String>(
                value: _kind,
                label: 'Tipo',
                options: const [
                  AppSelectOption(value: 'account', label: 'Conta'),
                  AppSelectOption(value: 'cash', label: 'Carteira/dinheiro'),
                  AppSelectOption(value: 'card', label: 'Cartão de crédito'),
                ],
                onChanged: (kind) => setState(() => _kind = kind),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _value,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: InputDecoration(
                  labelText: _kind == 'card' ? 'Limite total' : 'Saldo inicial',
                  prefixText: 'R\$ ',
                ),
                validator: (text) {
                  final value = _amount(text ?? '');
                  return value == null || _kind == 'card' && value <= 0
                      ? _kind == 'card'
                            ? 'Informe um limite maior que zero.'
                            : 'Informe um saldo válido.'
                      : null;
                },
              ),
              if (_kind == 'card') ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _closing,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Dia de fechamento',
                        ),
                        validator: _day,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _due,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Dia de vencimento',
                        ),
                        validator: _day,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(onPressed: _save, child: const Text('Salvar')),
    ],
  );
}
