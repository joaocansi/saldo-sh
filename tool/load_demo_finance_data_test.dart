import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_application_1/core/database/app_database.dart';
import 'package:flutter_application_1/core/database/device_identity.dart';
import 'package:flutter_application_1/features/finance/application/finance_controller.dart';
import 'package:flutter_application_1/features/finance/data/local/drift_finance_repository.dart';
import 'package:flutter_application_1/features/finance/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

const _demoPrefix = 'demo.ai.';

void main() {
  test('loads a realistic and idempotent finance scenario', () async {
    const databasePath = String.fromEnvironment('DEMO_DATABASE_PATH');
    if (databasePath.isEmpty) {
      fail('Informe --dart-define=DEMO_DATABASE_PATH=<caminho do banco>.');
    }

    final database = AppDatabase.forTesting(
      NativeDatabase(File(databasePath), logStatements: false),
    );
    addTearDown(database.close);
    final repository = DriftFinanceRepository(
      database,
      DeviceIdentity(database),
    );
    final today = _dateOnly(DateTime.now());

    final existingAccounts = await repository.readAccounts();
    final userAccounts = existingAccounts
        .where((account) => !account.id.startsWith(_demoPrefix))
        .toList();
    final templates = _accounts();
    final accountIds = <String, String>{};
    final demoAccounts = <FinanceAccount>[];
    for (final template in templates.entries) {
      final matchingUserAccount = userAccounts
          .where(
            (account) =>
                account.name.trim().toLowerCase() ==
                template.value.name.trim().toLowerCase(),
          )
          .firstOrNull;
      if (matchingUserAccount != null) {
        accountIds[template.key] = matchingUserAccount.id;
      } else {
        accountIds[template.key] = template.value.id;
        demoAccounts.add(template.value);
      }
    }
    await repository.saveAccounts([...userAccounts, ...demoAccounts]);

    final existingTransactions = await repository.readTransactions();
    final userTransactions = existingTransactions
        .where((transaction) => !transaction.id.startsWith(_demoPrefix))
        .toList();
    final demoTransactions = _transactions(today, accountIds);
    await repository.saveTransactions([
      ...userTransactions,
      ...demoTransactions,
    ]);

    final existingBudgets = await repository.readBudgets();
    final userBudgets = existingBudgets
        .where((budget) => !budget.id.startsWith(_demoPrefix))
        .toList();
    final userCategories = userBudgets.map((budget) => budget.category).toSet();
    final demoBudgets = _budgets()
        .where((budget) => !userCategories.contains(budget.category))
        .toList();
    await repository.saveBudgets([...userBudgets, ...demoBudgets]);

    final trackingStart = _month(today, -4);
    await repository.saveCardInvoiceTrackingStart(
      accountIds['nubank']!,
      trackingStart,
    );
    await repository.saveCardInvoiceTrackingStart(
      accountIds['inter']!,
      trackingStart,
    );

    final controller = FinanceController(repository, clock: () => today);
    await controller.initialize();
    expect(
      controller.accounts.where((account) => !account.archived).length,
      greaterThanOrEqualTo(5),
    );
    expect(
      controller.transactions.where((item) => item.id.startsWith(_demoPrefix)),
      hasLength(demoTransactions.length),
    );
    expect(demoTransactions.length, greaterThanOrEqualTo(70));
    expect(
      controller.accountBalanceCents(
        controller.accounts.firstWhere(
          (account) => account.id == accountIds['checking'],
        ),
      ),
      isNonZero,
    );
  });
}

Map<String, FinanceAccount> _accounts() => {
  'checking': FinanceAccount(
    id: '${_demoPrefix}account.checking',
    name: 'Conta corrente principal',
    kind: 'account',
    openingBalance: 5200,
  ),
  'reserve': FinanceAccount(
    id: '${_demoPrefix}account.reserve',
    name: 'Reserva de emergência',
    kind: 'account',
    openingBalance: 18500,
  ),
  'wallet': FinanceAccount(
    id: '${_demoPrefix}account.wallet',
    name: 'Carteira',
    kind: 'cash',
    openingBalance: 320,
  ),
  'nubank': FinanceAccount(
    id: '${_demoPrefix}card.nubank',
    name: 'Nubank Platinum',
    kind: 'card',
    openingBalance: 0,
    limit: 8000,
    closingDay: 5,
    dueDay: 12,
  ),
  'inter': FinanceAccount(
    id: '${_demoPrefix}card.inter',
    name: 'Inter Gold',
    kind: 'card',
    openingBalance: 0,
    limit: 4500,
    closingDay: 20,
    dueDay: 28,
  ),
};

List<FinanceBudget> _budgets() => [
  FinanceBudget(
    id: '${_demoPrefix}budget.food',
    category: 'Alimentação',
    limit: 1600,
  ),
  FinanceBudget(
    id: '${_demoPrefix}budget.housing',
    category: 'Moradia',
    limit: 3400,
  ),
  FinanceBudget(
    id: '${_demoPrefix}budget.transport',
    category: 'Transporte',
    limit: 850,
  ),
  FinanceBudget(
    id: '${_demoPrefix}budget.leisure',
    category: 'Lazer',
    limit: 650,
  ),
  FinanceBudget(
    id: '${_demoPrefix}budget.health',
    category: 'Saúde',
    limit: 800,
  ),
  FinanceBudget(
    id: '${_demoPrefix}budget.subscriptions',
    category: 'Assinaturas',
    limit: 250,
  ),
  FinanceBudget(
    id: '${_demoPrefix}budget.shopping',
    category: 'Compras',
    limit: 1100,
  ),
];

List<FinanceTransaction> _transactions(
  DateTime today,
  Map<String, String> accounts,
) {
  final items = <FinanceTransaction>[];
  final electricity = [248.31, 267.84, 231.65, 289.20, 275.40, 261.75];

  void add({
    required String id,
    required String name,
    required String category,
    required double amount,
    required DateTime date,
    DateTime? dueDate,
    String type = 'expense',
    required String account,
    String? targetAccount,
    String? status,
    String notes = '',
    String recurrence = 'none',
    String? seriesId,
    String? installmentGroupId,
    int installmentNumber = 1,
    int installmentCount = 1,
  }) {
    final due = dueDate ?? date;
    items.add(
      FinanceTransaction(
        id: '$_demoPrefix$id',
        name: name,
        category: category,
        amount: amount,
        date: date,
        dueDate: due,
        type: type,
        accountId: accounts[account]!,
        targetAccountId: targetAccount == null
            ? null
            : accounts[targetAccount]!,
        status: status ?? (due.isAfter(today) ? 'planned' : 'paid'),
        notes: notes,
        recurrence: recurrence,
        seriesId: seriesId,
        installmentGroupId: installmentGroupId,
        installmentNumber: installmentNumber,
        installmentCount: installmentCount,
      ),
    );
  }

  for (var offset = -3; offset <= 2; offset++) {
    final month = _month(today, offset);
    final key = _monthKey(month);
    add(
      id: 'salary.$key',
      name: 'Salário ACME Tecnologia',
      category: 'Salário',
      amount: 7500,
      date: _day(month, 5),
      type: 'income',
      account: 'checking',
      recurrence: 'monthly',
      seriesId: '${_demoPrefix}series.salary',
      notes: 'Salário líquido mensal',
    );
    add(
      id: 'rent.$key',
      name: 'Aluguel',
      category: 'Moradia',
      amount: 2100,
      date: _day(month, 8),
      account: 'checking',
      recurrence: 'monthly',
      seriesId: '${_demoPrefix}series.rent',
    );
    add(
      id: 'condo.$key',
      name: 'Condomínio',
      category: 'Moradia',
      amount: 590,
      date: _day(month, 10),
      account: 'checking',
      recurrence: 'monthly',
      seriesId: '${_demoPrefix}series.condo',
    );
    add(
      id: 'internet.$key',
      name: 'Internet fibra',
      category: 'Assinaturas',
      amount: 119.90,
      date: _day(month, 12),
      account: 'checking',
      recurrence: 'monthly',
      seriesId: '${_demoPrefix}series.internet',
    );
    add(
      id: 'health.$key',
      name: 'Plano de saúde',
      category: 'Saúde',
      amount: 489,
      date: _day(month, 7),
      account: 'checking',
      recurrence: 'monthly',
      seriesId: '${_demoPrefix}series.health',
    );
    add(
      id: 'gym.$key',
      name: 'Academia',
      category: 'Saúde',
      amount: 129.90,
      date: _day(month, 3),
      account: 'checking',
      recurrence: 'monthly',
      seriesId: '${_demoPrefix}series.gym',
    );
    add(
      id: 'electricity.$key',
      name: 'Energia elétrica',
      category: 'Moradia',
      amount: electricity[offset + 3],
      date: _day(month, 15),
      account: 'checking',
      recurrence: 'monthly',
      seriesId: '${_demoPrefix}series.electricity',
    );
    add(
      id: 'mobile.$key',
      name: 'Plano de celular',
      category: 'Assinaturas',
      amount: 69.90,
      date: _day(month, 18),
      account: 'checking',
      recurrence: 'monthly',
      seriesId: '${_demoPrefix}series.mobile',
    );
    add(
      id: 'investment.$key',
      name: 'Aporte na reserva',
      category: 'Outros',
      amount: 1000,
      date: _day(month, 6),
      type: 'transfer',
      account: 'checking',
      targetAccount: 'reserve',
      recurrence: 'monthly',
      seriesId: '${_demoPrefix}series.investment',
      notes: 'Meta mensal de investimento',
    );
  }

  add(
    id: 'freelance.${_monthKey(_month(today, -1))}',
    name: 'Projeto freelance',
    category: 'Salário',
    amount: 1350,
    date: _day(_month(today, -1), 22),
    type: 'income',
    account: 'checking',
  );
  add(
    id: 'freelance.${_monthKey(_month(today, 0))}',
    name: 'Projeto freelance',
    category: 'Salário',
    amount: 950,
    date: _day(_month(today, 0), 25),
    type: 'income',
    account: 'checking',
    status: 'planned',
    notes: 'Pagamento aguardando o cliente',
  );

  for (var offset = -3; offset <= 0; offset++) {
    final invoiceMonth = _month(today, offset);
    final purchaseMonth = _month(invoiceMonth, -1);
    final key = _monthKey(invoiceMonth);
    final groceries = 648.35 + (offset + 3) * 27.25;
    final restaurant = 176.80 + (offset + 3) * 13.40;
    const streaming = 54.90;
    const notebookInstallment = 349.90;
    add(
      id: 'nubank.groceries.$key',
      name: 'Supermercado Pão de Açúcar',
      category: 'Alimentação',
      amount: groceries,
      date: _day(purchaseMonth, 16),
      dueDate: _day(invoiceMonth, 12),
      account: 'nubank',
    );
    add(
      id: 'nubank.restaurant.$key',
      name: 'Restaurante',
      category: 'Lazer',
      amount: restaurant,
      date: _day(purchaseMonth, 23),
      dueDate: _day(invoiceMonth, 12),
      account: 'nubank',
    );
    add(
      id: 'nubank.streaming.$key',
      name: 'Netflix',
      category: 'Assinaturas',
      amount: streaming,
      date: _day(purchaseMonth, 25),
      dueDate: _day(invoiceMonth, 12),
      account: 'nubank',
      recurrence: 'monthly',
      seriesId: '${_demoPrefix}series.netflix',
    );
    add(
      id: 'notebook.installment.${offset + 4}',
      name: 'Notebook Dell',
      category: 'Compras',
      amount: notebookInstallment,
      date: _day(purchaseMonth, 17),
      dueDate: _day(invoiceMonth, 12),
      account: 'nubank',
      installmentGroupId: '${_demoPrefix}installment.notebook',
      installmentNumber: offset + 4,
      installmentCount: 10,
    );

    final nubankTotal =
        groceries + restaurant + streaming + notebookInstallment;
    add(
      id: 'payment.nubank.$key',
      name: 'Pagamento de fatura - Nubank Platinum',
      category: 'Pagamento de fatura',
      amount: offset == 0 ? 800 : nubankTotal,
      date: _day(
        invoiceMonth,
        offset == 0 ? (today.day < 10 ? today.day : 10) : 11,
      ),
      dueDate: _day(invoiceMonth, 12),
      type: 'cardPayment',
      account: 'checking',
      targetAccount: 'nubank',
      status: 'paid',
      notes: offset == 0 ? 'Pagamento parcial da fatura' : '',
    );

    final fuel = 268.40 + (offset + 3) * 18.60;
    final pharmacy = 118.75 + (offset + 3) * 9.15;
    const course = 89.90;
    add(
      id: 'inter.fuel.$key',
      name: 'Posto Shell',
      category: 'Transporte',
      amount: fuel,
      date: _day(invoiceMonth, 4),
      dueDate: _day(invoiceMonth, 28),
      account: 'inter',
    );
    add(
      id: 'inter.pharmacy.$key',
      name: 'Drogasil',
      category: 'Saúde',
      amount: pharmacy,
      date: _day(invoiceMonth, 9),
      dueDate: _day(invoiceMonth, 28),
      account: 'inter',
    );
    add(
      id: 'inter.course.$key',
      name: 'Alura',
      category: 'Educação',
      amount: course,
      date: _day(invoiceMonth, 14),
      dueDate: _day(invoiceMonth, 28),
      account: 'inter',
      recurrence: 'monthly',
      seriesId: '${_demoPrefix}series.alura',
    );
    if (offset < 0) {
      add(
        id: 'payment.inter.$key',
        name: 'Pagamento de fatura - Inter Gold',
        category: 'Pagamento de fatura',
        amount: fuel + pharmacy + course,
        date: _day(invoiceMonth, 27),
        dueDate: _day(invoiceMonth, 28),
        type: 'cardPayment',
        account: 'checking',
        targetAccount: 'inter',
        status: 'paid',
      );
    }
  }

  for (var number = 5; number <= 10; number++) {
    final invoiceMonth = _month(today, number - 4);
    add(
      id: 'notebook.installment.$number',
      name: 'Notebook Dell',
      category: 'Compras',
      amount: 349.90,
      date: _day(_month(invoiceMonth, -1), 17),
      dueDate: _day(invoiceMonth, 12),
      account: 'nubank',
      status: 'planned',
      installmentGroupId: '${_demoPrefix}installment.notebook',
      installmentNumber: number,
      installmentCount: 10,
    );
  }

  for (var number = 1; number <= 6; number++) {
    final invoiceMonth = _month(today, number);
    add(
      id: 'monitor.installment.$number',
      name: 'Monitor LG 27 polegadas',
      category: 'Compras',
      amount: 289.90,
      date: number == 1 ? today : _day(_month(today, number - 1), today.day),
      dueDate: _day(invoiceMonth, 12),
      account: 'nubank',
      status: 'planned',
      installmentGroupId: '${_demoPrefix}installment.monitor',
      installmentNumber: number,
      installmentCount: 6,
    );
  }

  add(
    id: 'wallet.lunch.1',
    name: 'Almoço no trabalho',
    category: 'Alimentação',
    amount: 34.90,
    date: _day(_month(today, 0), 2),
    account: 'wallet',
  );
  add(
    id: 'wallet.coffee.1',
    name: 'Café e pão de queijo',
    category: 'Alimentação',
    amount: 16.50,
    date: _day(_month(today, 0), 9),
    account: 'wallet',
  );

  return items;
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

DateTime _month(DateTime date, int offset) =>
    DateTime(date.year, date.month + offset);

DateTime _day(DateTime month, int day) {
  final lastDay = DateTime(month.year, month.month + 1, 0).day;
  return DateTime(month.year, month.month, day.clamp(1, lastDay));
}

String _monthKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}';
