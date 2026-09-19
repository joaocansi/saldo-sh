import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/device_identity.dart';
import '../../../../core/sync/vector_clock.dart';
import '../../domain/entities/finance_account.dart';
import '../../domain/entities/finance_budget.dart';
import '../../domain/entities/finance_recurrence.dart';
import '../../domain/entities/finance_transaction.dart';
import '../../domain/repositories/finance_repository.dart';

class DriftFinanceRepository
    implements FinanceRepository, RecurrenceRepository {
  DriftFinanceRepository(this.database, this.deviceIdentity);

  static const darkThemeKey = 'theme.dark';
  static const invoiceTrackingStartPrefix = 'card.invoiceTrackingStart.';

  final AppDatabase database;
  final DeviceIdentity deviceIdentity;

  static int toCents(double value) => (value * 100).round();
  static double fromCents(int value) => value / 100;
  static int dateToStorage(DateTime value) =>
      DateTime(value.year, value.month, value.day).millisecondsSinceEpoch;
  static DateTime dateFromStorage(int value) {
    final date = DateTime.fromMillisecondsSinceEpoch(value);
    return DateTime(date.year, date.month, date.day);
  }

  @override
  Future<List<FinanceAccount>> readAccounts() async {
    final rows =
        await (database.select(database.accountRecords)
              ..where((row) => row.deletedAt.isNull())
              ..orderBy([(row) => OrderingTerm.asc(row.name)]))
            .get();
    return rows.map(accountFromRecord).toList();
  }

  @override
  Future<List<FinanceTransaction>> readTransactions() async {
    final rows =
        await (database.select(database.transactionRecords)
              ..where((row) => row.deletedAt.isNull())
              ..orderBy([(row) => OrderingTerm.desc(row.dueDate)]))
            .get();
    return rows.map(transactionFromRecord).toList();
  }

  @override
  Future<List<FinanceBudget>> readBudgets() async {
    final rows =
        await (database.select(database.budgetRecords)
              ..where((row) => row.deletedAt.isNull())
              ..orderBy([(row) => OrderingTerm.asc(row.category)]))
            .get();
    return rows.map(budgetFromRecord).toList();
  }

  @override
  Future<List<FinanceRecurrence>> readRecurrences() async {
    final rows =
        await (database.select(database.recurrenceRecords)
              ..where((row) => row.deletedAt.isNull())
              ..orderBy([(row) => OrderingTerm.asc(row.startsOn)]))
            .get();
    return rows.map(recurrenceFromRecord).toList();
  }

  @override
  Future<void> saveAccounts(List<FinanceAccount> items) async {
    final deviceId = await deviceIdentity.getOrCreateId();
    await database.transaction(() async {
      final existing = await database.select(database.accountRecords).get();
      final activeIds = items.map((item) => item.id).toSet();
      for (final item in items) {
        final current = existing.where((row) => row.id == item.id).firstOrNull;
        if (current != null &&
            current.deletedAt == null &&
            _accountEquals(item, current)) {
          continue;
        }
        final mutation = await _mutationMetadata(
          deviceId,
          current?.vectorClock,
        );
        await database
            .into(database.accountRecords)
            .insertOnConflictUpdate(_accountCompanion(item, mutation));
        await _removeTombstone('account', item.id);
      }
      for (final row in existing.where(
        (row) => row.deletedAt == null && !activeIds.contains(row.id),
      )) {
        await _markAccountDeleted(row, deviceId);
      }
    });
  }

  @override
  Future<void> saveTransactions(List<FinanceTransaction> items) async {
    final deviceId = await deviceIdentity.getOrCreateId();
    await database.transaction(() async {
      final existing = await database.select(database.transactionRecords).get();
      final activeIds = items.map((item) => item.id).toSet();
      for (final item in items) {
        final current = existing.where((row) => row.id == item.id).firstOrNull;
        if (current != null &&
            current.deletedAt == null &&
            _transactionEquals(item, current)) {
          continue;
        }
        final mutation = await _mutationMetadata(
          deviceId,
          current?.vectorClock,
        );
        await database
            .into(database.transactionRecords)
            .insertOnConflictUpdate(_transactionCompanion(item, mutation));
        await _removeTombstone('transaction', item.id);
      }
      for (final row in existing.where(
        (row) => row.deletedAt == null && !activeIds.contains(row.id),
      )) {
        await _markTransactionDeleted(row, deviceId);
      }
    });
  }

  @override
  Future<void> saveBudgets(List<FinanceBudget> items) async {
    final deviceId = await deviceIdentity.getOrCreateId();
    await database.transaction(() async {
      final existing = await database.select(database.budgetRecords).get();
      final activeIds = items.map((item) => item.id).toSet();
      for (final item in items) {
        final current = existing.where((row) => row.id == item.id).firstOrNull;
        if (current != null &&
            current.deletedAt == null &&
            _budgetEquals(item, current)) {
          continue;
        }
        final mutation = await _mutationMetadata(
          deviceId,
          current?.vectorClock,
        );
        await database
            .into(database.budgetRecords)
            .insertOnConflictUpdate(_budgetCompanion(item, mutation));
        await _removeTombstone('budget', item.id);
      }
      for (final row in existing.where(
        (row) => row.deletedAt == null && !activeIds.contains(row.id),
      )) {
        await _markBudgetDeleted(row, deviceId);
      }
    });
  }

  @override
  Future<void> saveRecurrences(List<FinanceRecurrence> items) async {
    final deviceId = await deviceIdentity.getOrCreateId();
    await database.transaction(() async {
      final existing = await database.select(database.recurrenceRecords).get();
      final activeIds = items.map((item) => item.id).toSet();
      for (final item in items) {
        final current = existing.where((row) => row.id == item.id).firstOrNull;
        if (current != null &&
            current.deletedAt == null &&
            _recurrenceEquals(item, current)) {
          continue;
        }
        final mutation = await _mutationMetadata(
          deviceId,
          current?.vectorClock,
        );
        await database
            .into(database.recurrenceRecords)
            .insertOnConflictUpdate(_recurrenceCompanion(item, mutation));
        await _removeTombstone('recurrence', item.id);
      }
      for (final row in existing.where(
        (row) => row.deletedAt == null && !activeIds.contains(row.id),
      )) {
        await _markRecurrenceDeleted(row, deviceId);
      }
    });
  }

  @override
  Future<Map<String, DateTime>> readCardInvoiceTrackingStarts() async {
    final rows = await database.select(database.preferenceRecords).get();
    final result = <String, DateTime>{};
    for (final row in rows.where(
      (item) => item.key.startsWith(invoiceTrackingStartPrefix),
    )) {
      final value = jsonDecode(row.valueJson);
      if (value is! String) continue;
      final parsed = DateTime.tryParse('$value-01');
      if (parsed == null) continue;
      result[row.key.substring(invoiceTrackingStartPrefix.length)] = DateTime(
        parsed.year,
        parsed.month,
      );
    }
    return result;
  }

  @override
  Future<void> saveCardInvoiceTrackingStart(
    String cardId,
    DateTime month,
  ) async {
    final key = '$invoiceTrackingStartPrefix$cardId';
    final normalized = DateTime(month.year, month.month);
    final value =
        '${normalized.year.toString().padLeft(4, '0')}-'
        '${normalized.month.toString().padLeft(2, '0')}';
    final current = await (database.select(
      database.preferenceRecords,
    )..where((row) => row.key.equals(key))).getSingleOrNull();
    if (current != null && jsonDecode(current.valueJson) == value) return;
    final deviceId = await deviceIdentity.getOrCreateId();
    final mutation = await _mutationMetadata(deviceId, current?.vectorClock);
    await database
        .into(database.preferenceRecords)
        .insertOnConflictUpdate(
          PreferenceRecordsCompanion.insert(
            key: key,
            valueJson: jsonEncode(value),
            updatedAt: mutation.updatedAt,
            originDeviceId: deviceId,
            vectorClock: Value(mutation.vectorClock),
          ),
        );
  }

  @override
  Future<bool> readDarkTheme() async {
    final row = await (database.select(
      database.preferenceRecords,
    )..where((item) => item.key.equals(darkThemeKey))).getSingleOrNull();
    if (row == null) return false;
    return jsonDecode(row.valueJson) == true;
  }

  @override
  Future<void> saveDarkTheme(bool value) async {
    final deviceId = await deviceIdentity.getOrCreateId();
    final current = await (database.select(
      database.preferenceRecords,
    )..where((row) => row.key.equals(darkThemeKey))).getSingleOrNull();
    if (current != null && jsonDecode(current.valueJson) == value) return;
    final mutation = await _mutationMetadata(deviceId, current?.vectorClock);
    await database
        .into(database.preferenceRecords)
        .insertOnConflictUpdate(
          PreferenceRecordsCompanion.insert(
            key: darkThemeKey,
            valueJson: jsonEncode(value),
            updatedAt: mutation.updatedAt,
            originDeviceId: deviceId,
            vectorClock: Value(mutation.vectorClock),
          ),
        );
  }

  Future<_MutationMetadata> _mutationMetadata(
    String deviceId,
    String? currentClock,
  ) async {
    final counter = await deviceIdentity.nextCounter();
    final clock = VectorClock.fromJsonString(currentClock ?? '{}').values;
    clock[deviceId] = counter;
    return _MutationMetadata(
      updatedAt: DateTime.now().toUtc().millisecondsSinceEpoch,
      vectorClock: VectorClock(clock).toJsonString(),
      originDeviceId: deviceId,
    );
  }

  Future<void> importLegacySnapshot({
    required List<FinanceAccount> accounts,
    required List<FinanceTransaction> transactions,
    required List<FinanceBudget> budgets,
    required bool darkTheme,
  }) async {
    final deviceId = await deviceIdentity.getOrCreateId();
    await database.transaction(() async {
      final existingCount =
          await database.accountRecords.count().getSingle() +
          await database.transactionRecords.count().getSingle() +
          await database.budgetRecords.count().getSingle();
      if (existingCount != 0) {
        await _setMetadata('legacy_migration_v2', 'skipped_existing_data');
        return;
      }

      var counter = 0;
      _MutationMetadata metadata() {
        counter++;
        return _MutationMetadata(
          updatedAt: DateTime.now().toUtc().millisecondsSinceEpoch,
          vectorClock: VectorClock({deviceId: counter}).toJsonString(),
          originDeviceId: deviceId,
        );
      }

      for (final account in accounts) {
        await database
            .into(database.accountRecords)
            .insert(_accountCompanion(account, metadata()));
      }
      for (final transaction in transactions) {
        await database
            .into(database.transactionRecords)
            .insert(_transactionCompanion(transaction, metadata()));
      }
      for (final budget in budgets) {
        await database
            .into(database.budgetRecords)
            .insert(_budgetCompanion(budget, metadata()));
      }

      final storedCounts = (
        await database.accountRecords.count().getSingle(),
        await database.transactionRecords.count().getSingle(),
        await database.budgetRecords.count().getSingle(),
      );
      final expectedCounts = (
        accounts.length,
        transactions.length,
        budgets.length,
      );
      if (storedCounts != expectedCounts) {
        throw StateError('A validação da migração local falhou.');
      }
      final storedTransactions = await database
          .select(database.transactionRecords)
          .get();
      final expectedRelationships = {
        for (final item in transactions)
          item.id: (item.accountId, item.targetAccountId),
      };
      final relationshipsPreserved = storedTransactions.every(
        (row) =>
            expectedRelationships[row.id] ==
            (row.accountId, row.targetAccountId),
      );
      if (!relationshipsPreserved) {
        throw StateError(
          'Os relacionamentos da migração não foram preservados.',
        );
      }

      final preferenceMetadata = metadata();
      await database
          .into(database.preferenceRecords)
          .insertOnConflictUpdate(
            PreferenceRecordsCompanion.insert(
              key: darkThemeKey,
              valueJson: jsonEncode(darkTheme),
              updatedAt: preferenceMetadata.updatedAt,
              originDeviceId: deviceId,
              vectorClock: Value(preferenceMetadata.vectorClock),
            ),
          );
      await _setMetadata('device_counter', '$counter');
      await _setMetadata('legacy_migration_v2', 'completed');
    });
  }

  Future<void> _setMetadata(String key, String value) => database
      .into(database.syncMetadata)
      .insertOnConflictUpdate(
        SyncMetadataCompanion.insert(key: key, value: value),
      );

  Future<void> _markAccountDeleted(AccountRecord row, String deviceId) async {
    final mutation = await _mutationMetadata(deviceId, row.vectorClock);
    await (database.update(
      database.accountRecords,
    )..where((item) => item.id.equals(row.id))).write(
      AccountRecordsCompanion(
        deletedAt: Value(mutation.updatedAt),
        updatedAt: Value(mutation.updatedAt),
        originDeviceId: Value(deviceId),
        vectorClock: Value(mutation.vectorClock),
      ),
    );
    await _putTombstone('account', row.id, deviceId, mutation);
  }

  Future<void> _markTransactionDeleted(
    TransactionRecord row,
    String deviceId,
  ) async {
    final mutation = await _mutationMetadata(deviceId, row.vectorClock);
    await (database.update(
      database.transactionRecords,
    )..where((item) => item.id.equals(row.id))).write(
      TransactionRecordsCompanion(
        deletedAt: Value(mutation.updatedAt),
        updatedAt: Value(mutation.updatedAt),
        originDeviceId: Value(deviceId),
        vectorClock: Value(mutation.vectorClock),
      ),
    );
    await _putTombstone('transaction', row.id, deviceId, mutation);
  }

  Future<void> _markBudgetDeleted(BudgetRecord row, String deviceId) async {
    final mutation = await _mutationMetadata(deviceId, row.vectorClock);
    await (database.update(
      database.budgetRecords,
    )..where((item) => item.id.equals(row.id))).write(
      BudgetRecordsCompanion(
        deletedAt: Value(mutation.updatedAt),
        updatedAt: Value(mutation.updatedAt),
        originDeviceId: Value(deviceId),
        vectorClock: Value(mutation.vectorClock),
      ),
    );
    await _putTombstone('budget', row.id, deviceId, mutation);
  }

  Future<void> _markRecurrenceDeleted(
    RecurrenceRecord row,
    String deviceId,
  ) async {
    final mutation = await _mutationMetadata(deviceId, row.vectorClock);
    await (database.update(
      database.recurrenceRecords,
    )..where((item) => item.id.equals(row.id))).write(
      RecurrenceRecordsCompanion(
        deletedAt: Value(mutation.updatedAt),
        updatedAt: Value(mutation.updatedAt),
        originDeviceId: Value(deviceId),
        vectorClock: Value(mutation.vectorClock),
      ),
    );
    await _putTombstone('recurrence', row.id, deviceId, mutation);
  }

  Future<void> _putTombstone(
    String type,
    String id,
    String deviceId,
    _MutationMetadata mutation,
  ) => database
      .into(database.tombstoneRecords)
      .insertOnConflictUpdate(
        TombstoneRecordsCompanion.insert(
          entityType: type,
          entityId: id,
          deletedAt: mutation.updatedAt,
          originDeviceId: deviceId,
          vectorClock: mutation.vectorClock,
        ),
      );

  Future<void> _removeTombstone(String type, String id) =>
      (database.delete(database.tombstoneRecords)..where(
            (row) => row.entityType.equals(type) & row.entityId.equals(id),
          ))
          .go();

  AccountRecordsCompanion _accountCompanion(
    FinanceAccount item,
    _MutationMetadata mutation,
  ) => AccountRecordsCompanion.insert(
    id: item.id,
    name: item.name,
    kind: item.kind,
    openingBalanceCents: Value(toCents(item.openingBalance)),
    creditLimitCents: Value(toCents(item.limit)),
    closingDay: Value(item.closingDay),
    dueDay: Value(item.dueDay),
    archived: Value(item.archived),
    updatedAt: mutation.updatedAt,
    originDeviceId: mutation.originDeviceId ?? '',
    vectorClock: Value(mutation.vectorClock),
  );

  TransactionRecordsCompanion _transactionCompanion(
    FinanceTransaction item,
    _MutationMetadata mutation,
  ) => TransactionRecordsCompanion.insert(
    id: item.id,
    name: item.name,
    category: item.category,
    amountCents: toCents(item.amount),
    transactionDate: dateToStorage(item.date),
    dueDate: dateToStorage(item.dueDate),
    type: item.type,
    accountId: item.accountId,
    targetAccountId: Value(item.targetAccountId),
    status: item.status,
    notes: Value(item.notes),
    recurrence: Value(item.recurrence),
    seriesId: Value(item.seriesId),
    installmentGroupId: Value(item.installmentGroupId),
    installmentNumber: Value(item.installmentNumber),
    installmentCount: Value(item.installmentCount),
    updatedAt: mutation.updatedAt,
    originDeviceId: mutation.originDeviceId ?? '',
    vectorClock: Value(mutation.vectorClock),
  );

  BudgetRecordsCompanion _budgetCompanion(
    FinanceBudget item,
    _MutationMetadata mutation,
  ) => BudgetRecordsCompanion.insert(
    id: item.id,
    category: item.category,
    limitCents: toCents(item.limit),
    updatedAt: mutation.updatedAt,
    originDeviceId: mutation.originDeviceId ?? '',
    vectorClock: Value(mutation.vectorClock),
  );

  RecurrenceRecordsCompanion _recurrenceCompanion(
    FinanceRecurrence item,
    _MutationMetadata mutation,
  ) => RecurrenceRecordsCompanion.insert(
    id: item.id,
    transactionTemplateJson: jsonEncode(item.toStorageJson()),
    frequency: item.frequency,
    status: Value(item.status),
    startsOn: dateToStorage(item.startsOn),
    endsOn: Value(item.endsOn == null ? null : dateToStorage(item.endsOn!)),
    updatedAt: mutation.updatedAt,
    originDeviceId: mutation.originDeviceId ?? '',
    vectorClock: Value(mutation.vectorClock),
  );

  static FinanceAccount accountFromRecord(AccountRecord row) => FinanceAccount(
    id: row.id,
    name: row.name,
    kind: row.kind,
    openingBalance: fromCents(row.openingBalanceCents),
    limit: fromCents(row.creditLimitCents),
    closingDay: row.closingDay,
    dueDay: row.dueDay,
    archived: row.archived,
  );

  static FinanceTransaction transactionFromRecord(TransactionRecord row) =>
      FinanceTransaction(
        id: row.id,
        name: row.name,
        category: row.category,
        amount: fromCents(row.amountCents),
        date: dateFromStorage(row.transactionDate),
        dueDate: dateFromStorage(row.dueDate),
        type: row.type,
        accountId: row.accountId,
        targetAccountId: row.targetAccountId,
        status: row.status,
        notes: row.notes,
        recurrence: row.recurrence,
        seriesId: row.seriesId,
        installmentGroupId: row.installmentGroupId,
        installmentNumber: row.installmentNumber,
        installmentCount: row.installmentCount,
      );

  static FinanceBudget budgetFromRecord(BudgetRecord row) => FinanceBudget(
    id: row.id,
    category: row.category,
    limit: fromCents(row.limitCents),
  );

  static FinanceRecurrence recurrenceFromRecord(RecurrenceRecord row) {
    final decoded = jsonDecode(row.transactionTemplateJson);
    if (decoded is! Map) {
      throw const FormatException('Regra de recorrencia invalida.');
    }
    final json = Map<String, dynamic>.from(decoded);
    final rawTemplate = json['template'];
    final templateJson = rawTemplate is Map
        ? Map<String, dynamic>.from(rawTemplate)
        : json;
    final rawExcluded = json['excludedOccurrenceKeys'];
    return FinanceRecurrence(
      id: row.id,
      template: FinanceTransaction.fromJson(templateJson),
      frequency: row.frequency,
      startsOn: dateFromStorage(row.startsOn),
      endsOn: row.endsOn == null ? null : dateFromStorage(row.endsOn!),
      status: row.status,
      excludedOccurrenceKeys: rawExcluded is List
          ? rawExcluded.map((value) => value.toString()).toSet()
          : const <String>{},
    );
  }

  bool _accountEquals(FinanceAccount item, AccountRecord row) =>
      item.name == row.name &&
      item.kind == row.kind &&
      toCents(item.openingBalance) == row.openingBalanceCents &&
      toCents(item.limit) == row.creditLimitCents &&
      item.closingDay == row.closingDay &&
      item.dueDay == row.dueDay &&
      item.archived == row.archived;

  bool _transactionEquals(FinanceTransaction item, TransactionRecord row) =>
      item.name == row.name &&
      item.category == row.category &&
      toCents(item.amount) == row.amountCents &&
      dateToStorage(item.date) == row.transactionDate &&
      dateToStorage(item.dueDate) == row.dueDate &&
      item.type == row.type &&
      item.accountId == row.accountId &&
      item.targetAccountId == row.targetAccountId &&
      item.status == row.status &&
      item.notes == row.notes &&
      item.recurrence == row.recurrence &&
      item.seriesId == row.seriesId &&
      item.installmentGroupId == row.installmentGroupId &&
      item.installmentNumber == row.installmentNumber &&
      item.installmentCount == row.installmentCount;

  bool _budgetEquals(FinanceBudget item, BudgetRecord row) =>
      item.category == row.category && toCents(item.limit) == row.limitCents;

  bool _recurrenceEquals(FinanceRecurrence item, RecurrenceRecord row) =>
      jsonEncode(item.toStorageJson()) == row.transactionTemplateJson &&
      item.frequency == row.frequency &&
      item.status == row.status &&
      dateToStorage(item.startsOn) == row.startsOn &&
      (item.endsOn == null ? null : dateToStorage(item.endsOn!)) == row.endsOn;
}

class _MutationMetadata {
  const _MutationMetadata({
    required this.updatedAt,
    required this.vectorClock,
    this.originDeviceId,
  });

  final int updatedAt;
  final String vectorClock;
  final String? originDeviceId;
}
