import 'dart:convert';

import 'package:saldo_sh/src/features/ai/application/finance_tool_registry.dart';
import 'package:saldo_sh/src/features/finance/application/finance_controller.dart';
import 'package:saldo_sh/src/features/finance/domain/models.dart';
import 'package:saldo_sh/src/features/finance/domain/repositories/finance_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reads finance data and only prepares a transaction draft', () async {
    final repository = _MemoryRepository();
    final controller = FinanceController(repository);
    await controller.initialize();
    await controller.addAccount(
      FinanceAccount(
        id: 'checking',
        name: 'Conta',
        kind: 'account',
        openingBalance: 100,
      ),
    );
    final tools = FinanceToolRegistry(controller);

    final balance = await tools.execute('get_balance', {});
    expect(balance.output, contains('10000'));
    final prepared = await tools.execute('prepare_transaction', {
      'name': 'Mercado',
      'amount': 42.5,
      'category': 'Alimentação',
      'type': 'expense',
      'account_id': 'checking',
      'date': '2026-09-07',
    });

    expect(prepared.draft?.name, 'Mercado');
    expect(repository.transactions, isEmpty);
    expect(prepared.output, contains('requires_user_confirmation'));
  });

  test('rejects unknown tools and invalid account IDs', () async {
    final controller = FinanceController(_MemoryRepository());
    await controller.initialize();
    final tools = FinanceToolRegistry(controller);
    await expectLater(tools.execute('run_sql', {}), throwsFormatException);
    await expectLater(
      tools.execute('prepare_transaction', {
        'name': 'Teste',
        'amount': 1,
        'type': 'expense',
        'account_id': 'other-user-account',
      }),
      throwsA(isA<ToolInputException>()),
    );
  });

  test('resolves a card by name and calculates due date locally', () async {
    final repository = _MemoryRepository();
    final controller = FinanceController(repository);
    await controller.initialize();
    await controller.addAccount(
      FinanceAccount(
        id: 'nubank-card',
        name: 'Nubank Platinum',
        kind: 'card',
        openingBalance: 0,
        limit: 5000,
        closingDay: 10,
        dueDay: 20,
      ),
    );
    final tools = FinanceToolRegistry(
      controller,
      clock: () => DateTime(2026, 9, 9, 14),
    );

    final prepared = await tools.execute('prepare_transaction', {
      'name': 'Notebook',
      'amount_cents': 32000,
      'category': 'Compras',
      'type': 'expense',
      'account_ref': 'cartão Nubank Platinum',
      'purchase_date': '2026-09-15',
      'installments': 10,
      'initial_installment': 2,
    });

    expect(prepared.draft?.accountId, 'nubank-card');
    expect(prepared.draft?.date, DateTime(2026, 9, 15));
    expect(prepared.draft?.dueDate, DateTime(2026, 10, 20));
    expect(prepared.draft?.installmentCount, 10);
    expect(prepared.draft?.initialInstallment, 2);
  });

  test(
    'card proposal validates required fields and never persists automatically',
    () async {
      final repository = _MemoryRepository();
      final controller = FinanceController(repository);
      await controller.initialize();
      final tools = FinanceToolRegistry(controller);
      const args = {
        'name': 'Meu cartão',
        'kind': 'card',
        'limit_cents': 500000,
        'closing_day': 4,
        'due_day': 10,
      };
      final result = await tools.execute('prepare_account', args);
      expect(result.accountDraft?.name, 'Meu cartão');
      expect(result.accountDraft?.limitCents, 500000);
      expect(result.accountDraft?.closingDay, 4);
      expect(result.accountDraft?.dueDay, 10);
      expect(repository.accounts, isEmpty);
      expect(controller.accounts, isEmpty);
      for (final key in ['limit_cents', 'closing_day', 'due_day']) {
        await expectLater(
          tools.execute('prepare_account', {...args}..remove(key)),
          throwsA(isA<ToolInputException>()),
        );
      }
      for (final invalid in [
        {...args, 'closing_day': 32},
        {...args, 'due_day': 1.5},
        {...args, 'limit_cents': 0},
        {...args, 'name': 'Cartão\ninválido'},
        {...args, 'opening_balance_cents': 100},
      ]) {
        await expectLater(
          tools.execute('prepare_account', invalid),
          throwsA(isA<ToolInputException>()),
        );
      }
    },
  );

  test(
    'rejects duplicate account proposals and unsupported query filters',
    () async {
      final repository = _MemoryRepository()
        ..accounts = [
          FinanceAccount(
            id: '1',
            name: 'Carteira',
            kind: 'cash',
            openingBalance: 0,
          ),
        ];
      final controller = FinanceController(repository);
      await controller.initialize();
      final tools = FinanceToolRegistry(controller);
      await expectLater(
        tools.execute('prepare_account', {'name': 'carteira', 'kind': 'cash'}),
        throwsA(isA<ToolInputException>()),
      );
      await expectLater(
        tools.execute('query_finances', {
          'operation': 'savings_plan',
          'account_ref': 'Carteira',
          'savings_target_cents': 10000,
        }),
        throwsA(isA<ToolInputException>()),
      );
      await expectLater(
        tools.execute('query_finances', {
          'operation': 'savings_plan',
          'savings_target_cents': 10.5,
        }),
        throwsA(isA<ToolInputException>()),
      );
      await expectLater(
        tools.execute('query_finances', {
          'operation': 'transactions',
          'from': '2026-02-30',
        }),
        throwsA(isA<ToolInputException>()),
      );
      await expectLater(
        tools.execute('query_finances', {
          'operation': 'compare_months',
          'months': 13,
        }),
        throwsA(isA<ToolInputException>()),
      );
    },
  );

  test(
    'small transaction pages cover filtered history without duplicates',
    () async {
      final repository = _MemoryRepository()
        ..accounts = [
          FinanceAccount(
            id: 'checking',
            name: 'Conta',
            kind: 'account',
            openingBalance: 0,
          ),
        ]
        ..transactions = [
          for (var i = 0; i < 19; i++)
            FinanceTransaction(
              id: '$i',
              name: 'Mercado $i',
              category: 'Alimentação',
              amount: 10,
              date: DateTime(2026, 9, i + 1),
              dueDate: DateTime(2026, 9, i + 1),
              type: 'expense',
              accountId: 'checking',
            ),
        ];
      final controller = FinanceController(repository);
      await controller.initialize();
      final tools = FinanceToolRegistry(controller);
      final names = <String>{};
      int? offset = 0;
      while (offset != null) {
        final result = jsonDecode(
          (await tools.execute('query_finances', {
            'operation': 'transactions',
            'month': '2026-09',
            'search': 'mercado',
            'offset': offset,
          })).output,
        ) as Map;
        final items = result['transactions'] as List;
        expect(items.length, lessThanOrEqualTo(8));
        for (final item in items) {
          expect(names.add(item['name'] as String), isTrue);
        }
        expect(result['total'], 19);
        offset = result['next_offset'] as int?;
      }
      expect(names, hasLength(19));
    },
  );

  test(
    'balance uses all invoice commitments and accounts for partial payments',
    () async {
      final repository = _MemoryRepository()
        ..accounts = [
          FinanceAccount(
            id: 'card',
            name: 'Cartão',
            kind: 'card',
            openingBalance: 0,
            limit: 5000,
          ),
        ]
        ..transactions = [
          for (final month in [9, 10])
            FinanceTransaction(
              id: 'purchase-$month',
              name: 'Compra',
              category: 'Compras',
              amount: 1000,
              date: DateTime(2026, 9, 1),
              dueDate: DateTime(2026, month, 10),
              type: 'expense',
              accountId: 'card',
            ),
          FinanceTransaction(
            id: 'payment',
            name: 'Fatura',
            category: 'Outros',
            amount: 400,
            date: DateTime(2026, 9, 2),
            dueDate: DateTime(2026, 9, 10),
            type: 'cardPayment',
            accountId: 'checking',
            targetAccountId: 'card',
          ),
        ];
      final controller = FinanceController(
        repository,
        clock: () => DateTime(2026, 9, 9),
      );
      await controller.initialize();
      final tools = FinanceToolRegistry(
        controller,
        clock: () => DateTime(2026, 9, 9),
      );
      final balance = jsonDecode(
        (await tools.execute('query_finances', {
          'operation': 'balance',
        })).output,
      );
      expect(balance['balances'][0]['available_limit_cents'], 340000);
      expect(balance['total_cash_cents'], 0);
      final invoices = jsonDecode(
        (await tools.execute('query_finances', {
          'operation': 'invoices',
        })).output,
      );
      expect(invoices['invoices'][0]['paid_cents'], 40000);
      expect(invoices['invoices'][0]['remaining_cents'], 60000);
      final months = jsonDecode(
        (await tools.execute('query_finances', {
          'operation': 'compare_months',
          'month': '2026-09',
          'months': 2,
        })).output,
      );
      expect(months['months'][0]['expense_cents'], 100000);
      expect(months['months'][1]['expense_cents'], 100000);
    },
  );

  test(
    'visualization snapshots are local, filtered and exclude money moves',
    () async {
      final repository = _MemoryRepository()
        ..accounts = [
          FinanceAccount(
            id: 'checking',
            name: 'Conta corrente',
            kind: 'account',
            openingBalance: 1000,
          ),
          FinanceAccount(
            id: 'savings',
            name: 'Reserva',
            kind: 'account',
            openingBalance: 500,
          ),
        ]
        ..transactions = [
          FinanceTransaction(
            id: 'salary',
            name: 'Salário',
            category: 'Salário',
            amount: 5000,
            date: DateTime(2026, 9, 1),
            dueDate: DateTime(2026, 9, 1),
            type: 'income',
            accountId: 'checking',
          ),
          FinanceTransaction(
            id: 'rent',
            name: 'Aluguel',
            category: 'Moradia',
            amount: 2000,
            date: DateTime(2026, 9, 2),
            dueDate: DateTime(2026, 9, 10),
            type: 'expense',
            accountId: 'checking',
            status: 'planned',
          ),
          FinanceTransaction(
            id: 'transfer',
            name: 'Guardar',
            category: 'Outros',
            amount: 500,
            date: DateTime(2026, 9, 3),
            dueDate: DateTime(2026, 9, 3),
            type: 'transfer',
            accountId: 'checking',
            targetAccountId: 'savings',
          ),
          FinanceTransaction(
            id: 'payment',
            name: 'Pagamento de fatura',
            category: 'Outros',
            amount: 300,
            date: DateTime(2026, 9, 4),
            dueDate: DateTime(2026, 9, 4),
            type: 'cardPayment',
            accountId: 'checking',
            targetAccountId: 'card',
          ),
        ];
      final controller = FinanceController(repository);
      await controller.initialize();
      final tools = FinanceToolRegistry(
        controller,
        clock: () => DateTime(2026, 9, 12),
      );

      final withoutChart = await tools.execute('query_finances', {
        'operation': 'compare_months',
        'month': '2026-09',
        'visualize': false,
      });
      expect(withoutChart.chart, isNull);

      final comparison = await tools.execute('query_finances', {
        'operation': 'compare_months',
        'month': '2026-09',
        'months': 2,
        'account_ref': 'Conta corrente',
        'visualize': true,
      });
      expect(comparison.chart?.kind.name, 'incomeExpense');
      expect(comparison.chart?.accountName, 'Conta corrente');
      expect(comparison.chart?.series[0].points[0].valueCents, 500000);
      expect(comparison.chart?.series[1].points[0].valueCents, 200000);

      final cashFlow = await tools.execute('query_finances', {
        'operation': 'cash_flow',
        'month': '2026-09',
        'months': 2,
        'account_ref': 'Conta corrente',
        'visualize': true,
      });
      expect(cashFlow.chart?.kind.name, 'cashFlow');
      expect(cashFlow.chart?.series.single.points[0].valueCents, 400000);
      expect(cashFlow.chart?.series.single.points[1].valueCents, 400000);

      await expectLater(
        tools.execute('query_finances', {
          'operation': 'balance',
          'visualize': true,
        }),
        throwsA(
          isA<ToolInputException>().having(
            (error) => error.code,
            'code',
            'unsupported_visualization',
          ),
        ),
      );
    },
  );

  test('category charts keep seven categories and group the rest', () async {
    final repository = _MemoryRepository()
      ..accounts = [
        FinanceAccount(
          id: 'checking',
          name: 'Conta',
          kind: 'account',
          openingBalance: 0,
        ),
      ]
      ..transactions = [
        for (var index = 0; index < 10; index++)
          FinanceTransaction(
            id: '$index',
            name: 'Despesa $index',
            category: 'Categoria $index',
            amount: 100 - index.toDouble(),
            date: DateTime(2026, 9, index + 1),
            dueDate: DateTime(2026, 9, index + 1),
            type: 'expense',
            accountId: 'checking',
          ),
      ];
    final controller = FinanceController(repository);
    await controller.initialize();
    final tools = FinanceToolRegistry(controller);

    final result = await tools.execute('query_finances', {
      'operation': 'category_spending',
      'month': '2026-09',
      'account_ref': 'Conta',
      'visualize': true,
    });
    final payload = jsonDecode(result.output) as Map<String, dynamic>;
    final categories = payload['categories'] as Map<String, dynamic>;
    expect(categories, hasLength(8));
    expect(categories['Outros'], 27600);
    expect(result.chart?.series.single.points, hasLength(8));
  });
}

class _MemoryRepository implements FinanceRepository {
  List<FinanceTransaction> transactions = [];
  List<FinanceAccount> accounts = [];
  List<FinanceBudget> budgets = [];

  @override
  Future<List<FinanceAccount>> readAccounts() async => List.of(accounts);
  @override
  Future<List<FinanceBudget>> readBudgets() async => List.of(budgets);
  @override
  Future<List<FinanceTransaction>> readTransactions() async =>
      List.of(transactions);
  @override
  Future<Map<String, DateTime>> readCardInvoiceTrackingStarts() async => {};
  @override
  Future<bool> readDarkTheme() async => false;
  @override
  Future<void> saveAccounts(List<FinanceAccount> items) async =>
      accounts = List.of(items);
  @override
  Future<void> saveBudgets(List<FinanceBudget> items) async =>
      budgets = List.of(items);
  @override
  Future<void> saveCardInvoiceTrackingStart(
    String cardId,
    DateTime month,
  ) async {}
  @override
  Future<void> saveDarkTheme(bool value) async {}
  @override
  Future<void> saveTransactions(List<FinanceTransaction> items) async =>
      transactions = List.of(items);
}
