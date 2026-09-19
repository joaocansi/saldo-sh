import 'dart:convert';

import 'package:drift/native.dart';
import 'package:saldo_sh/src/core/database/app_database.dart';
import 'package:saldo_sh/src/core/database/device_identity.dart';
import 'package:saldo_sh/src/features/finance/data/local/drift_finance_repository.dart';
import 'package:saldo_sh/src/features/finance/data/local/legacy_finance_migrator.dart';
import 'package:saldo_sh/src/features/finance/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppDatabase database;
  late DriftFinanceRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftFinanceRepository(database, DeviceIdentity(database));
  });

  tearDown(() => database.close());

  test('stores money in integer cents and creates tombstones', () async {
    final account = FinanceAccount(
      id: 'account-1',
      name: 'Conta',
      kind: 'account',
      openingBalance: 10.129,
    );
    await repository.saveAccounts([account]);
    await repository.saveTransactions([
      FinanceTransaction(
        id: 'transaction-1',
        name: 'Café',
        category: 'Alimentação',
        amount: 12.345,
        date: DateTime(2026, 9, 7),
        dueDate: DateTime(2026, 9, 7),
        type: 'expense',
        accountId: account.id,
      ),
    ]);

    final accountRow = await database
        .select(database.accountRecords)
        .getSingle();
    final transactionRow = await database
        .select(database.transactionRecords)
        .getSingle();
    expect(accountRow.openingBalanceCents, 1013);
    expect(transactionRow.amountCents, 1235);
    expect((await repository.readTransactions()).single.amount, 12.35);

    await repository.saveTransactions([]);
    expect(await repository.readTransactions(), isEmpty);
    final tombstone = await database
        .select(database.tombstoneRecords)
        .getSingle();
    expect(tombstone.entityType, 'transaction');
    expect(tombstone.entityId, 'transaction-1');
  });

  test('stores the invoice tracking start as a synced preference', () async {
    await repository.saveCardInvoiceTrackingStart(
      'card-1',
      DateTime(2026, 9, 18),
    );

    final starts = await repository.readCardInvoiceTrackingStarts();
    final row = await database.select(database.preferenceRecords).getSingle();
    expect(starts['card-1'], DateTime(2026, 9));
    expect(row.key, 'card.invoiceTrackingStart.card-1');
    expect(row.synchronizable, isTrue);
  });

  test(
    'stores recurrence rules and tombstones without transaction rows',
    () async {
      final template = FinanceTransaction(
        id: 'salary-template',
        name: 'SalÃ¡rio',
        category: 'Renda',
        amount: 5000,
        date: DateTime(2026, 10, 5),
        dueDate: DateTime(2026, 10, 5),
        type: 'income',
        accountId: 'checking',
        status: 'pending',
        recurrence: 'monthly',
        seriesId: 'salary',
      );
      await repository.saveRecurrences([
        FinanceRecurrence(
          id: 'salary',
          template: template,
          frequency: 'monthly',
          startsOn: DateTime(2026, 10, 5),
          excludedOccurrenceKeys: {'2027-01-05'},
        ),
      ]);

      final restored = (await repository.readRecurrences()).single;
      expect(restored.template.amount, 5000);
      expect(restored.excludedOccurrenceKeys, contains('2027-01-05'));
      expect(await repository.readTransactions(), isEmpty);

      await repository.saveRecurrences([]);
      expect(await repository.readRecurrences(), isEmpty);
      final tombstone = await (database.select(
        database.tombstoneRecords,
      )..where((row) => row.entityType.equals('recurrence'))).getSingle();
      expect(tombstone.entityId, 'salary');
    },
  );

  test(
    'migrates legacy JSON once and removes it only after validation',
    () async {
      SharedPreferences.setMockInitialValues({
        'verde.accounts.v2': jsonEncode([
          {
            'id': 'account-1',
            'name': 'Conta antiga',
            'kind': 'account',
            'openingBalance': 100.25,
          },
        ]),
        'verde.transactions.v2': jsonEncode([
          {
            'id': 'transaction-1',
            'name': 'Mercado',
            'category': 'Alimentação',
            'amount': 30.5,
            'date': '2026-09-01T00:00:00.000',
            'dueDate': '2026-09-01T00:00:00.000',
            'type': 'expense',
            'accountId': 'Conta antiga',
          },
        ]),
        'verde.budgets.v2': jsonEncode([
          {'id': 'budget-1', 'category': 'Alimentação', 'limit': 500},
        ]),
        'verde.dark-theme.v1': true,
      });

      final migrator = LegacyFinanceMigrator(database, repository);
      await migrator.run();
      await migrator.run();

      expect(await repository.readAccounts(), hasLength(1));
      expect(
        (await repository.readTransactions()).single.accountId,
        'account-1',
      );
      expect(await repository.readBudgets(), hasLength(1));
      expect(await repository.readDarkTheme(), isTrue);
      final preferences = await SharedPreferences.getInstance();
      expect(preferences.containsKey('verde.accounts.v2'), isFalse);
      expect(preferences.containsKey('verde.transactions.v2'), isFalse);
      expect(preferences.containsKey('verde.budgets.v2'), isFalse);
    },
  );
}
