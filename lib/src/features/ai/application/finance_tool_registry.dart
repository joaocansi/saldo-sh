import 'dart:convert';

import '../../finance/application/account_reference_resolver.dart';
import '../../finance/application/account_draft.dart';
import '../../finance/application/finance_controller.dart';
import '../../finance/application/financial_planning_service.dart';
import '../../finance/application/finance_intent_guards.dart';
import '../../finance/application/transaction_builder.dart';
import '../../finance/domain/models.dart';
import '../domain/ai_chart.dart';
import '../domain/ai_conversation_context.dart';
import '../domain/ai_provider.dart';
import 'finance_tool_definitions.dart';
import 'finance_chart_snapshot_builder.dart';

class ToolExecution {
  const ToolExecution(this.output, {this.draft, this.accountDraft, this.chart});
  final String output;
  final TransactionDraft? draft;
  final AccountDraft? accountDraft;
  final AIChartSnapshot? chart;
}

class ToolInputException implements Exception {
  const ToolInputException(this.code, this.message, [this.details = const {}]);

  final String code;
  final String message;
  final Map<String, dynamic> details;

  Map<String, dynamic> toJson() => {
    'code': code,
    'message': message,
    if (details.isNotEmpty) 'details': details,
  };

  @override
  String toString() => message;
}

class FinanceToolRegistry {
  FinanceToolRegistry(this._finance, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now,
      _chartBuilder = FinanceChartSnapshotBuilder(clock: clock);

  final FinanceController _finance;
  final DateTime Function() _clock;
  final FinanceChartSnapshotBuilder _chartBuilder;
  static const _accountResolver = AccountReferenceResolver();
  static const _transactionBuilder = TransactionBuilder();
  static const _planning = FinancialPlanningService();

  List<AIToolDefinition> get definitions => financeToolDefinitions;

  /// Refreshes the in-memory snapshot immediately before an assistant request.
  /// This matters after a Drive merge or a write from another application flow.
  Future<void> refresh() => _finance.reload();

  String describe(String name, Map<String, dynamic> args) {
    if (name == 'prepare_transaction') {
      return 'Preparando o rascunho do lançamento';
    }
    if (name == 'prepare_account') {
      return 'Preparando o cadastro da conta ou cartão';
    }
    if (name != 'query_finances') return 'Consultando dados locais';
    if (args['visualize'] == true) {
      return switch (args['operation']) {
        'compare_months' => 'Preparando o gráfico de entradas e saídas',
        'cash_flow' => 'Preparando o gráfico de evolução do caixa',
        'category_spending' => 'Preparando o gráfico de categorias',
        'budget_status' => 'Preparando o gráfico dos orçamentos',
        'invoices' => 'Preparando o gráfico das faturas',
        _ => 'Preparando a visualização local',
      };
    }
    return switch (args['operation']) {
      'accounts' => 'Buscando contas e cartões',
      'balance' => 'Atualizando os saldos das contas',
      'transactions' => 'Buscando transações',
      'month_summary' => 'Calculando o resumo do mês',
      'category_spending' => 'Somando gastos por categoria',
      'budget_status' => 'Verificando os orçamentos',
      'savings_plan' => 'Calculando o limite de gastos para a meta',
      'compare_months' => 'Comparando os meses registrados',
      'cash_flow' => 'Calculando a evolução acumulada do caixa',
      'invoices' => 'Verificando faturas e pagamentos',
      _ => 'Consultando dados locais',
    };
  }

  String modelContext(DateTime now) => jsonEncode({
    'current_date': _dateString(now),
    'currency': 'BRL',
    'accounts': [
      for (final account in _finance.accounts.where((a) => !a.archived).take(8))
        {'name': _short(account.name), 'kind': account.kind},
    ],
    'more_accounts': _finance.accounts.where((a) => !a.archived).length > 8,
  });

  String modelConversationContext(AIConversationContext context) {
    if (context.isEmpty) return '{}';

    Map<String, dynamic> transaction(AITransactionMemory memory) {
      final account = _activeAccount(memory.accountId);
      final target = memory.targetAccountId == null
          ? null
          : _activeAccount(memory.targetAccountId!);
      return {
        'name': _short(memory.name),
        'amount_cents': memory.amountCents,
        'category': memory.category,
        'type': memory.type,
        'purchase_date': _dateString(memory.purchaseDate),
        'state': memory.confirmed ? 'confirmed' : 'prepared',
        'account_ref': account?.name,
        'account_kind': account?.kind,
        'available': account != null,
        if (target != null) 'target_account_ref': target.name,
      };
    }

    Map<String, dynamic> account(AIAccountMemory memory) {
      final current = memory.accountId == null
          ? null
          : _activeAccount(memory.accountId!);
      return {
        'name': current?.name ?? _short(memory.name),
        'kind': current?.kind ?? memory.kind,
        'state': memory.confirmed ? 'confirmed' : 'prepared',
        'available': memory.confirmed ? current != null : true,
      };
    }

    return jsonEncode({
      if (context.recentTransactions.isNotEmpty) ...{
        'last_transaction': transaction(context.recentTransactions.first),
        'recent_transactions': context.recentTransactions
            .skip(1)
            .map(transaction)
            .toList(),
      },
      if (context.recentAccounts.isNotEmpty) ...{
        'last_account_created': account(context.recentAccounts.first),
        'recent_accounts_created': context.recentAccounts
            .skip(1)
            .map(account)
            .toList(),
      },
    });
  }

  FinanceAccount? _activeAccount(String id) => _finance.accounts
      .where((account) => account.id == id && !account.archived)
      .firstOrNull;

  Future<ToolExecution> execute(String name, Map<String, dynamic> args) async {
    return switch (name) {
      'query_finances' => _queryFinances(args),
      'list_accounts' => ToolExecution(jsonEncode(_accountsPayload(args))),
      'get_balance' => _getBalance(args),
      'get_transactions' => _getTransactions(args),
      'get_month_summary' => _getMonthSummary(args),
      'get_category_spending' => _getCategorySpending(args),
      'get_budget_status' => _getBudgetStatus(args),
      'prepare_transaction' => _prepareTransaction(args),
      'prepare_account' => _prepareAccount(args),
      _ => throw const FormatException('Tool não permitida.'),
    };
  }

  Map<String, dynamic> _accountsPayload(Map<String, dynamic> args) {
    final search = normalizeFinanceText(args['search'] as String? ?? '');
    final accounts = _finance.accounts
        .where((account) => !account.archived)
        .where((account) => normalizeFinanceText(account.name).contains(search))
        .toList();
    final (offset, limit) = _page(args);
    return {
      'accounts': [
        for (final account in accounts.skip(offset).take(limit))
          {
            'account_id': account.id,
            'name': _short(account.name),
            'kind': account.kind,
            if (account.isCard) ...{
              'closing_day': account.closingDay,
              'due_day': account.dueDay,
              'limit_cents': (account.limit * 100).round(),
            },
          },
      ],
      ..._pagination(accounts.length, offset, limit),
    };
  }

  ToolExecution _queryFinances(Map<String, dynamic> args) {
    final operation = args['operation'];
    if (args.containsKey('visualize') && args['visualize'] is! bool) {
      throw const ToolInputException(
        'invalid_argument',
        'visualize precisa ser verdadeiro ou falso.',
      );
    }
    final visualize = args['visualize'] == true;
    final allowed = switch (operation) {
      'accounts' => {'search', 'offset', 'limit'},
      'balance' => {'account_ref', 'offset', 'limit'},
      'transactions' => {
        'account_ref',
        'search',
        'category',
        'type',
        'status',
        'from',
        'to',
        'month',
        'offset',
        'limit',
      },
      'month_summary' => {'month'},
      'category_spending' => {'month', 'account_ref'},
      'budget_status' => {'month', 'offset', 'limit'},
      'savings_plan' => {
        'month',
        'savings_target_cents',
        'monthly_income_cents',
      },
      'compare_months' || 'cash_flow' => {'month', 'months', 'account_ref'},
      'invoices' => {'month', 'months', 'account_ref', 'offset', 'limit'},
      _ => throw const ToolInputException(
        'invalid_operation',
        'Consulta não permitida.',
      ),
    };
    if (args.keys.any(
      (key) =>
          key != 'operation' && key != 'visualize' && !allowed.contains(key),
    )) {
      throw ToolInputException(
        'unsupported_filter',
        'Filtro não suportado nesta consulta.',
        {'allowed': allowed.toList()},
      );
    }
    const chartOperations = {
      'compare_months',
      'cash_flow',
      'category_spending',
      'budget_status',
      'invoices',
    };
    if (visualize && !chartOperations.contains(operation)) {
      throw const ToolInputException(
        'unsupported_visualization',
        'Esta consulta não possui um gráfico compatível.',
      );
    }
    for (final key in [
      'account_ref',
      'search',
      'category',
      'type',
      'status',
      'from',
      'to',
      'month',
    ]) {
      if (args.containsKey(key) &&
          (args[key] is! String || (args[key] as String).length > 160)) {
        throw ToolInputException('invalid_argument', 'Texto inválido.', {
          'field': key,
        });
      }
    }
    final month = args['month'] == null
        ? monthStart(_clock())
        : _month(args['month']);
    final execution = switch (operation) {
      'accounts' => ToolExecution(jsonEncode(_accountsPayload(args))),
      'balance' => _getBalance(args),
      'transactions' => _getTransactions(args),
      'month_summary' => _getMonthSummary({
        'month': FinancialPlanningService.monthKey(month),
      }),
      'category_spending' => _getCategorySpending({
        ...args,
        'month': FinancialPlanningService.monthKey(month),
      }),
      'budget_status' => _getBudgetStatus({
        ...args,
        'month': FinancialPlanningService.monthKey(month),
      }),
      'savings_plan' => ToolExecution(
        jsonEncode({
          'as_of': _dateTimeString(_clock()),
          ..._planning.savingsPlan(
            transactions: _finance.transactionsForMonth(month),
            month: month,
            today: _clock(),
            savingsTargetCents: _integer(
              args,
              'savings_target_cents',
              min: 0,
              max: 100000000000,
            ),
            monthlyIncomeCents: args.containsKey('monthly_income_cents')
                ? _integer(
                    args,
                    'monthly_income_cents',
                    min: 0,
                    max: 100000000000,
                  )
                : null,
          ),
        }),
      ),
      'compare_months' => _compareMonths(args, month),
      'cash_flow' => _cashFlow(args, month),
      'invoices' => _getInvoices(args, month),
      _ => throw const ToolInputException(
        'invalid_operation',
        'Consulta não permitida.',
      ),
    };
    if (!visualize) return execution;
    final decoded = jsonDecode(execution.output);
    if (decoded is! Map) return execution;
    return ToolExecution(
      execution.output,
      chart: _chartBuilder.build(
        operation.toString(),
        Map<String, dynamic>.from(decoded),
      ),
    );
  }

  ToolExecution _prepareAccount(Map<String, dynamic> args) {
    const allowed = {
      'name',
      'kind',
      'opening_balance_cents',
      'limit_cents',
      'closing_day',
      'due_day',
    };
    if (args.keys.any((key) => !allowed.contains(key))) {
      throw const ToolInputException(
        'invalid_argument',
        'Campo de conta não permitido.',
      );
    }
    final name = args['name'];
    final kind = args['kind'];
    if (name is! String ||
        name.trim().isEmpty ||
        name.length > 160 ||
        RegExp(r'[\x00-\x1f\x7f]').hasMatch(name) ||
        !{'account', 'cash', 'card'}.contains(kind)) {
      throw const ToolInputException(
        'invalid_account',
        'Informe nome e tipo válidos para a conta.',
      );
    }
    if (_finance.accounts.any(
      (a) =>
          !a.archived &&
          a.kind == kind &&
          normalizeFinanceText(a.name) == normalizeFinanceText(name),
    )) {
      throw const ToolInputException(
        'duplicate_account',
        'Já existe uma conta deste tipo com esse nome. Confirme se deseja outra e escolha um nome diferente.',
      );
    }
    if (kind == 'card' && args.containsKey('opening_balance_cents') ||
        kind != 'card' &&
            ['limit_cents', 'closing_day', 'due_day'].any(args.containsKey)) {
      throw const ToolInputException(
        'invalid_account_fields',
        'Saldo inicial é de conta/carteira; limite e dias são de cartão.',
      );
    }
    final draft = AccountDraft(
      name: name.trim(),
      kind: kind as String,
      openingBalanceCents: kind == 'card'
          ? 0
          : _integer(
              args,
              'opening_balance_cents',
              min: -100000000000,
              max: 100000000000,
              fallback: 0,
            ),
      limitCents: kind == 'card'
          ? _integer(args, 'limit_cents', min: 1, max: 100000000000)
          : 0,
      closingDay: kind == 'card'
          ? _integer(args, 'closing_day', min: 1, max: 31)
          : null,
      dueDay: kind == 'card'
          ? _integer(args, 'due_day', min: 1, max: 31)
          : null,
    );
    return ToolExecution(
      jsonEncode({
        'prepared': true,
        'requires_user_confirmation': true,
        ...draft.toJson(),
      }),
      accountDraft: draft,
    );
  }

  ToolExecution _getInvoices(Map<String, dynamic> args, DateTime month) {
    final reference = args['account_ref'] as String?;
    final selected = reference == null
        ? null
        : _resolveAccount(reference, field: 'account_ref');
    if (selected != null && !selected.isCard) {
      throw const ToolInputException(
        'not_a_card',
        'Selecione um cartão de crédito.',
      );
    }
    final cards = _finance.accounts
        .where(
          (a) =>
              a.isCard &&
              !a.archived &&
              (selected == null || a.id == selected.id),
        )
        .toList();
    final (offset, limit) = _page(args);
    final includeEvolution =
        args['visualize'] == true || args.containsKey('months');
    final periodCount = includeEvolution
        ? _integer(args, 'months', min: 1, max: 12, fallback: 6)
        : 1;
    final evolution = <Map<String, dynamic>>[];
    if (includeEvolution) {
      for (var index = 0; index < periodCount; index++) {
        final period = DateTime(month.year, month.month + index);
        var totalCents = 0;
        var paidCents = 0;
        for (final card in cards) {
          final invoice = _finance.invoiceSummary(card, period);
          totalCents += invoice.totalCents;
          paidCents += invoice.paidCents;
        }
        evolution.add({
          'month': FinancialPlanningService.monthKey(period),
          'total_cents': totalCents,
          'paid_cents': paidCents,
          'remaining_cents': (totalCents - paidCents).clamp(0, totalCents),
        });
      }
    }
    return ToolExecution(
      jsonEncode({
        'month': FinancialPlanningService.monthKey(month),
        if (selected != null) 'account_name': _short(selected.name),
        'invoices': [
          for (final card in cards.skip(offset).take(limit))
            _invoicePayload(card, month),
        ],
        if (includeEvolution) 'evolution': evolution,
        ..._pagination(cards.length, offset, limit),
      }),
    );
  }

  ToolExecution _compareMonths(Map<String, dynamic> args, DateTime month) {
    final count = _integer(
      args,
      'months',
      min: 1,
      max: 12,
      fallback: args['visualize'] == true ? 6 : 3,
    );
    final selected = _optionalAccount(args['account_ref']);
    final throughMonth = DateTime(month.year, month.month + count - 1);
    final transactions = _finance
        .transactionsForRange(
          monthStart(month),
          DateTime(throughMonth.year, throughMonth.month + 1, 0),
        )
        .where((item) => selected == null || item.accountId == selected.id)
        .toList();
    return ToolExecution(
      jsonEncode({
        if (selected != null) 'account_name': _short(selected.name),
        'months': [
          for (var index = 0; index < count; index++)
            _planning.monthSummary(
              transactions,
              DateTime(month.year, month.month + index),
            ),
        ],
      }),
    );
  }

  ToolExecution _cashFlow(Map<String, dynamic> args, DateTime month) {
    final count = _integer(args, 'months', min: 1, max: 12, fallback: 6);
    final selected = _optionalAccount(args['account_ref']);
    if (selected?.isCard == true) {
      throw const ToolInputException(
        'not_a_cash_account',
        'Evolução do caixa aceita contas e carteiras. Para cartões, use invoices.',
      );
    }
    final projection = _finance.cashFlowProjection(
      month,
      months: count,
      account: selected,
    );
    return ToolExecution(
      jsonEncode({
        if (selected != null) 'account_name': _short(selected.name),
        'basis': 'opening balance plus registered income and expenses by due date; excludes transfers and card payments',
        'months': [
          for (final item in projection)
            {
              'month': FinancialPlanningService.monthKey(item.month),
              'income_cents': item.incomeCents,
              'expense_cents': item.expenseCents,
              'ending_balance_cents': item.endingBalanceCents,
            },
        ],
      }),
    );
  }

  Map<String, dynamic> _invoicePayload(FinanceAccount card, DateTime month) {
    final invoice = _finance.invoiceSummary(card, month);
    return {
      'name': _short(card.name),
      'total_cents': invoice.totalCents,
      'paid_cents': invoice.paidCents,
      'remaining_cents': invoice.remainingCents,
      'status': invoice.status.name,
      'due_date': _dateString(invoice.dueDate),
      'available_limit_cents': (_finance.cardAvailableLimit(card) * 100)
          .round(),
    };
  }

  int _integer(
    Map<String, dynamic> args,
    String key, {
    required int min,
    required int max,
    int? fallback,
  }) {
    if (!args.containsKey(key) && fallback != null) return fallback;
    final value = args[key];
    if (value is! num ||
        !value.isFinite ||
        value != value.roundToDouble() ||
        value < min ||
        value > max) {
      throw ToolInputException(
        'invalid_integer',
        'Informe um inteiro entre $min e $max.',
        {'field': key},
      );
    }
    return value.toInt();
  }

  (int, int) _page(Map<String, dynamic> args) => (
    _integer(args, 'offset', min: 0, max: 100000000, fallback: 0),
    _integer(args, 'limit', min: 1, max: 20, fallback: 8),
  );

  Map<String, dynamic> _pagination(int total, int offset, int limit) => {
    'total': total,
    if (offset + limit < total) 'next_offset': offset + limit,
  };

  String _short(String text) =>
      text.length <= 160 ? text : '${text.substring(0, 157)}…';

  ToolExecution _getBalance(Map<String, dynamic> args) {
    final reference =
        args['account_ref']?.toString() ?? args['account_id']?.toString();
    final id = reference == null
        ? null
        : _resolveAccount(reference, field: 'account_ref').id;
    final accounts = id == null
        ? _finance.accounts.where((account) => !account.archived).toList()
        : _finance.accounts
              .where((account) => !account.archived && account.id == id)
              .toList();
    if (id != null && accounts.isEmpty) {
      throw ToolInputException(
        'account_not_found',
        'A conta informada não existe.',
        {'available_accounts': _accountSummaries()},
      );
    }
    final currentMonth = monthStart(_clock());
    final (offset, limit) = _page(args);
    return ToolExecution(
      jsonEncode({
        'as_of': _dateTimeString(_clock()),
        'total_cash_cents': accounts
            .where((a) => !a.isCard)
            .fold<int>(0, (sum, a) => sum + _finance.accountBalanceCents(a)),
        'balances': [
          for (final account in accounts.skip(offset).take(limit))
            {
              'name': _short(account.name),
              'kind': account.kind,
              if (account.isCard) ...{
                'invoice_cents':
                    (_finance.invoiceTotal(account, currentMonth) * 100)
                        .round(),
                'available_limit_cents':
                    (_finance.cardAvailableLimit(account) * 100).round(),
              } else
                'balance_cents': (_finance.accountBalance(account) * 100)
                    .round(),
            },
        ],
        ..._pagination(accounts.length, offset, limit),
      }),
    );
  }

  ToolExecution _getTransactions(Map<String, dynamic> args) {
    if (args.containsKey('month') &&
        (args.containsKey('from') || args.containsKey('to'))) {
      throw const ToolInputException(
        'ambiguous_period',
        'Use month ou from/to.',
      );
    }
    final month = args['month'] == null ? null : _month(args['month']);
    final from = month ?? _optionalDate(args['from']);
    final to = month == null
        ? _optionalDate(args['to'])
        : DateTime(month.year, month.month + 1, 0);
    if (from != null && to != null && from.isAfter(to)) {
      throw const ToolInputException(
        'invalid_period',
        'A data inicial deve preceder a final.',
      );
    }
    final (offset, limit) = _page(args);
    Iterable<FinanceTransaction> items = from != null && to != null
        ? _finance.transactionsForRange(from, to)
        : month != null
        ? _finance.transactionsForMonth(month)
        : _finance.transactions;
    final accountReference =
        args['account_ref']?.toString() ?? args['account_id']?.toString();
    final accountId = accountReference == null
        ? null
        : _resolveAccount(accountReference, field: 'account_ref').id;
    final category = args['category']?.toString();
    final type = args['type']?.toString();
    final status = args['status']?.toString();
    final search = normalizeFinanceText(args['search'] as String? ?? '');
    if (category != null && !financeCategories.contains(category) ||
        type != null &&
            !{'income', 'expense', 'transfer', 'cardPayment'}.contains(type) ||
        status != null && !{'paid', 'pending', 'planned'}.contains(status)) {
      throw const ToolInputException(
        'invalid_filter',
        'Categoria, tipo ou status inválido.',
      );
    }
    items = items.where((t) => normalizeFinanceText(t.name).contains(search));
    if (status != null) items = items.where((t) => t.status == status);
    if (accountId != null) {
      items = items.where(
        (item) =>
            item.accountId == accountId || item.targetAccountId == accountId,
      );
    }
    if (category != null) {
      items = items.where((item) => item.category == category);
    }
    if (type != null) {
      items = items.where((item) => item.type == type);
    }
    if (from != null) {
      items = items.where((item) => !item.dueDate.isBefore(from));
    }
    if (to != null) {
      items = items.where(
        (item) =>
            item.dueDate.isBefore(DateTime(to.year, to.month, to.day + 1)),
      );
    }
    final sorted = items.toList()
      ..sort((a, b) {
        final byDate = b.dueDate.compareTo(a.dueDate);
        return byDate == 0 ? a.id.compareTo(b.id) : byDate;
      });
    return ToolExecution(
      jsonEncode({
        'transactions': [
          for (final item in sorted.skip(offset).take(limit))
            {
              'name': _short(item.name),
              'amount_cents': (item.amount * 100).round(),
              'type': item.type,
              'category': item.category,
              'account_name': _finance.accounts
                  .where((account) => account.id == item.accountId)
                  .map((a) => _short(a.name))
                  .firstOrNull,
              if (item.targetAccountId != null)
                'target_account': _finance.accounts
                    .where((a) => a.id == item.targetAccountId)
                    .map((a) => _short(a.name))
                    .firstOrNull,
              'purchase_date': _dateString(item.date),
              'due_date': _dateString(item.dueDate),
              'status': item.status,
              if (item.isInstallment) ...{
                'installment_number': item.installmentNumber,
                'installment_count': item.installmentCount,
              },
              if (item.isRecurring) 'recurrence': item.recurrence,
            },
        ],
        ..._pagination(sorted.length, offset, limit),
      }),
    );
  }

  ToolExecution _getMonthSummary(Map<String, dynamic> args) {
    final month = _month(args['month']);
    return ToolExecution(
      jsonEncode(
        _planning.monthSummary(_finance.transactionsForMonth(month), month),
      ),
    );
  }

  ToolExecution _getCategorySpending(Map<String, dynamic> args) {
    final selected = _optionalAccount(args['account_ref']);
    final totals = <String, int>{};
    for (final item in _inMonth(_month(args['month'])).where(
      (item) =>
          item.isExpense && (selected == null || item.accountId == selected.id),
    )) {
      totals.update(
        item.category,
        (value) => value + (item.amount * 100).round(),
        ifAbsent: () => (item.amount * 100).round(),
      );
    }
    final ranked = totals.entries.toList()
      ..sort((left, right) => right.value.compareTo(left.value));
    final categories = <String, int>{
      for (final item in ranked.take(7)) item.key: item.value,
    };
    if (ranked.length > 7) {
      categories['Outros'] = ranked
          .skip(7)
          .fold(0, (sum, item) => sum + item.value);
    }
    return ToolExecution(
      jsonEncode({
        'month': args['month'],
        if (selected != null) 'account_name': _short(selected.name),
        'categories': categories,
      }),
    );
  }

  ToolExecution _getBudgetStatus(Map<String, dynamic> args) {
    final month = _month(args['month']);
    final expenses = _inMonth(month).where((item) => item.isExpense).toList();
    final (offset, limit) = _page(args);
    return ToolExecution(
      jsonEncode({
        'month': args['month'],
        'budgets': [
          for (final budget in _finance.budgets.skip(offset).take(limit))
            {
              'category': budget.category,
              'limit_cents': (budget.limit * 100).round(),
              'spent_cents': _sum(
                expenses.where((item) => item.category == budget.category),
              ),
            },
        ],
        ..._pagination(_finance.budgets.length, offset, limit),
      }),
    );
  }

  ToolExecution _prepareTransaction(Map<String, dynamic> args) {
    final name = args['name']?.toString().trim() ?? '';
    final amountCents = args.containsKey('amount_cents')
        ? _integer(args, 'amount_cents', min: 1, max: 100000000000)
        : (((args['amount'] as num?)?.toDouble() ?? 0) * 100).round();
    final type = args['type']?.toString() ?? '';
    if (name.isEmpty ||
        name.length > 160 ||
        RegExp(r'[\x00-\x1f\x7f]').hasMatch(name) ||
        amountCents <= 0 ||
        amountCents > 100000000000) {
      throw const ToolInputException(
        'invalid_name_or_amount',
        'Informe um nome curto e um valor positivo em centavos.',
      );
    }
    if (!{'income', 'expense', 'transfer'}.contains(type)) {
      throw const ToolInputException(
        'invalid_transaction_type',
        'Use expense, income ou transfer.',
      );
    }

    final account = _resolveAccount(
      args['account_ref']?.toString() ?? args['account_id']?.toString(),
      field: 'account_ref',
    );
    final target = type == 'transfer'
        ? _resolveAccount(
            args['target_account_ref']?.toString() ??
                args['target_account_id']?.toString(),
            field: 'target_account_ref',
          )
        : null;
    if (target?.id == account.id) {
      throw const ToolInputException(
        'same_transfer_account',
        'A origem e o destino da transferência devem ser diferentes.',
      );
    }
    if (type == 'transfer' && (account.isCard || target!.isCard)) {
      throw const ToolInputException(
        'invalid_transfer',
        'Transferências são entre contas de saldo. Para cartão use Pagar fatura.',
      );
    }

    final installments = _integer(
      args,
      'installments',
      min: 1,
      max: 60,
      fallback: 1,
    );
    final initialInstallment = _integer(
      args,
      'initial_installment',
      min: 1,
      max: installments,
      fallback: 1,
    );
    final now = _clock();
    final date =
        _optionalDate(args['purchase_date'] ?? args['date']) ??
        DateTime(now.year, now.month, now.day);
    final rawCategory = args['category']?.toString() ?? 'Outros';
    final category = financeCategories.where(
      (item) => normalizeFinanceText(item) == normalizeFinanceText(rawCategory),
    );
    if (category.isEmpty) {
      throw ToolInputException(
        'invalid_category',
        'A categoria não pertence à lista permitida.',
        {'valid_categories': financeCategories},
      );
    }
    final recurrence = args['recurrence']?.toString() ?? 'none';
    if (installments > 1 && recurrence != 'none') {
      throw const ToolInputException(
        'ambiguous_schedule',
        'Escolha parcelamento ou recorrência.',
      );
    }
    if (!{
      'none',
      'daily',
      'weekly',
      'monthly',
      'yearly',
    }.contains(recurrence)) {
      throw const ToolInputException(
        'invalid_recurrence',
        'Recorrência inválida.',
      );
    }
    final notes = args['notes']?.toString().trim() ?? '';
    if (isInvoicePaymentIntent('$name $notes')) {
      throw const ToolInputException(
        'invoice_payment',
        'Use Contas e cartões > Pagar fatura. Esse pagamento não é uma nova despesa.',
      );
    }
    if (notes.length > 1000) {
      throw const ToolInputException(
        'notes_too_long',
        'A observação deve ter no máximo 1000 caracteres.',
      );
    }

    final initialDraft = TransactionDraft(
      name: name,
      amount: amountCents / 100,
      category: category.single,
      type: type,
      accountId: account.id,
      targetAccountId: target?.id,
      date: date,
      dueDate: date,
      status: {'paid', 'pending', 'planned'}.contains(args['status'])
          ? args['status'] as String
          : date.isAfter(DateTime(now.year, now.month, now.day))
          ? 'planned'
          : 'paid',
      mode: installments > 1
          ? 'installment'
          : recurrence == 'none'
          ? 'single'
          : 'recurring',
      recurrence: recurrence == 'none' ? 'monthly' : recurrence,
      installmentCount: installments,
      initialInstallment: initialInstallment,
      notes: notes,
    );
    final calculatedDueDate = _transactionBuilder.dueDateFor(
      initialDraft,
      _finance.accounts,
    );
    final draft = TransactionDraft(
      name: initialDraft.name,
      amount: initialDraft.amount,
      category: initialDraft.category,
      type: initialDraft.type,
      accountId: initialDraft.accountId,
      targetAccountId: initialDraft.targetAccountId,
      date: initialDraft.date,
      dueDate: calculatedDueDate,
      status: initialDraft.status,
      mode: initialDraft.mode,
      recurrence: initialDraft.recurrence,
      installmentCount: initialDraft.installmentCount,
      initialInstallment: initialDraft.initialInstallment,
      notes: initialDraft.notes,
    );
    return ToolExecution(
      jsonEncode({
        'prepared': true,
        'requires_user_confirmation': true,
        'name': draft.name,
        'amount_cents': amountCents,
        'type': draft.type,
        'category': draft.category,
        'account': {
          'id': account.id,
          'name': account.name,
          'kind': account.kind,
        },
        'purchase_date': _dateString(draft.date),
        'calculated_due_date': _dateString(draft.dueDate),
        if (account.isCard) 'due_date_explanation': 'Calculada localmente pelos dias de fechamento e vencimento do cartão.',
      }),
      draft: draft,
    );
  }

  Iterable<FinanceTransaction> _inMonth(DateTime month) =>
      _finance.transactionsForRange(
        monthStart(month),
        DateTime(month.year, month.month + 1, 0),
      );

  int _sum(Iterable<FinanceTransaction> items) =>
      items.fold(0, (total, item) => total + (item.amount * 100).round());

  FinanceAccount _resolveAccount(String? reference, {required String field}) {
    final resolution = _accountResolver.resolve(reference, _finance.accounts);
    if (resolution.account case final account?) return account;
    if (resolution.isAmbiguous) {
      throw ToolInputException(
        'ambiguous_account',
        'A referência de conta está ambígua. Pergunte ao usuário qual deseja usar.',
        {
          'field': field,
          'candidates': resolution.candidates
              .map(
                (account) => {
                  'account_id': account.id,
                  'name': account.name,
                  'kind': account.kind,
                },
              )
              .toList(),
        },
      );
    }
    throw ToolInputException(
      'account_not_found',
      'Não foi possível identificar a conta. Pergunte ao usuário qual deseja usar.',
      {'field': field, 'available_accounts': _accountSummaries()},
    );
  }

  FinanceAccount? _optionalAccount(Object? reference) => reference == null
      ? null
      : _resolveAccount(reference.toString(), field: 'account_ref');

  List<Map<String, String>> _accountSummaries() => _finance.accounts
      .where((account) => !account.archived)
      .take(8)
      .map(
        (account) => {
          'account_id': account.id,
          'name': _short(account.name),
          'kind': account.kind,
        },
      )
      .toList();

  DateTime _month(Object? value) {
    final match = RegExp(r'^(\d{4})-(\d{2})$')
        .firstMatch(value?.toString() ?? '');
    if (match == null) throw const FormatException('Mês inválido.');
    final month = int.parse(match.group(2)!);
    if (month < 1 || month > 12) throw const FormatException('Mês inválido.');
    return DateTime(int.parse(match.group(1)!), month);
  }

  DateTime? _optionalDate(Object? value) {
    if (value == null) return null;
    final normalized = normalizeFinanceText(value.toString());
    final now = _clock();
    final today = DateTime(now.year, now.month, now.day);
    if (normalized == 'hoje') return today;
    if (normalized == 'ontem') return today.subtract(const Duration(days: 1));
    if (normalized == 'anteontem') {
      return today.subtract(const Duration(days: 2));
    }
    if (normalized == 'amanha') return today.add(const Duration(days: 1));
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$')
        .firstMatch(value.toString());
    if (match == null) {
      throw const ToolInputException(
        'invalid_date',
        'Use uma data válida no formato YYYY-MM-DD.',
      );
    }
    final date = DateTime(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    );
    if (_dateString(date) != value.toString()) {
      throw const ToolInputException(
        'invalid_date',
        'Use uma data real no formato YYYY-MM-DD.',
      );
    }
    return date;
  }

  String _dateString(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  String _dateTimeString(DateTime date) => date.toUtc().toIso8601String();
}
