import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DataClassName('AccountRecord')
class AccountRecords extends Table {
  @override
  String get tableName => 'accounts';

  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 120)();
  TextColumn get kind => text()();
  IntColumn get openingBalanceCents =>
      integer().withDefault(const Constant(0))();
  IntColumn get creditLimitCents => integer().withDefault(const Constant(0))();
  IntColumn get closingDay => integer().withDefault(const Constant(1))();
  IntColumn get dueDay => integer().withDefault(const Constant(10))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();
  TextColumn get originDeviceId => text()();
  TextColumn get vectorClock => text().withDefault(const Constant('{}'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('TransactionRecord')
class TransactionRecords extends Table {
  @override
  String get tableName => 'transactions';

  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 160)();
  TextColumn get category => text().withLength(min: 1, max: 80)();
  IntColumn get amountCents => integer()();
  IntColumn get transactionDate => integer()();
  IntColumn get dueDate => integer()();
  TextColumn get type => text()();
  TextColumn get accountId => text()();
  TextColumn get targetAccountId => text().nullable()();
  TextColumn get status => text()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  TextColumn get recurrence => text().withDefault(const Constant('none'))();
  TextColumn get seriesId => text().nullable()();
  TextColumn get installmentGroupId => text().nullable()();
  IntColumn get installmentNumber => integer().withDefault(const Constant(1))();
  IntColumn get installmentCount => integer().withDefault(const Constant(1))();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();
  TextColumn get originDeviceId => text()();
  TextColumn get vectorClock => text().withDefault(const Constant('{}'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('BudgetRecord')
class BudgetRecords extends Table {
  @override
  String get tableName => 'budgets';

  TextColumn get id => text()();
  TextColumn get category => text().withLength(min: 1, max: 80)();
  IntColumn get limitCents => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();
  TextColumn get originDeviceId => text()();
  TextColumn get vectorClock => text().withDefault(const Constant('{}'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('RecurrenceRecord')
class RecurrenceRecords extends Table {
  @override
  String get tableName => 'recurrence_rules';

  TextColumn get id => text()();
  TextColumn get transactionTemplateJson => text()();
  TextColumn get frequency => text()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  IntColumn get startsOn => integer()();
  IntColumn get endsOn => integer().nullable()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();
  TextColumn get originDeviceId => text()();
  TextColumn get vectorClock => text().withDefault(const Constant('{}'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('PreferenceRecord')
class PreferenceRecords extends Table {
  @override
  String get tableName => 'preferences';

  TextColumn get key => text()();
  TextColumn get valueJson => text()();
  BoolColumn get synchronizable =>
      boolean().withDefault(const Constant(true))();
  IntColumn get updatedAt => integer()();
  TextColumn get originDeviceId => text()();
  TextColumn get vectorClock => text().withDefault(const Constant('{}'))();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

class SyncMetadata extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DataClassName('TombstoneRecord')
class TombstoneRecords extends Table {
  @override
  String get tableName => 'tombstones';

  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  IntColumn get deletedAt => integer()();
  TextColumn get originDeviceId => text()();
  TextColumn get vectorClock => text()();

  @override
  Set<Column<Object>> get primaryKey => {entityType, entityId};
}

@DataClassName('SyncConflictRecord')
class SyncConflictRecords extends Table {
  @override
  String get tableName => 'sync_conflicts';

  TextColumn get id => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get localJson => text()();
  TextColumn get remoteJson => text()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('AIToolAuditRecord')
class AIToolAuditRecords extends Table {
  @override
  String get tableName => 'ai_tool_audit';

  TextColumn get id => text()();
  TextColumn get toolName => text()();
  TextColumn get risk => text()();
  TextColumn get argumentsSummary => text()();
  BoolColumn get success => boolean()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('AIConversationRecord')
class AIConversationRecords extends Table {
  @override
  String get tableName => 'ai_conversations';

  TextColumn get id => text()();
  TextColumn get title => text().withLength(min: 1, max: 100)();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('AIChatMessageRecord')
class AIChatMessageRecords extends Table {
  @override
  String get tableName => 'ai_chat_messages';

  TextColumn get id => text()();
  TextColumn get conversationId => text().references(
    AIConversationRecords,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get role => text()();
  TextColumn get content => text()();
  TextColumn get metadataJson => text().withDefault(const Constant('{}'))();
  IntColumn get createdAt => integer()();
  IntColumn get sequence => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    AccountRecords,
    TransactionRecords,
    BudgetRecords,
    RecurrenceRecords,
    PreferenceRecords,
    SyncMetadata,
    TombstoneRecords,
    SyncConflictRecords,
    AIToolAuditRecords,
    AIConversationRecords,
    AIChatMessageRecords,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'verde'));

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(aIConversationRecords);
        await migrator.createTable(aIChatMessageRecords);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await customStatement('PRAGMA journal_mode = WAL');
    },
  );

  Future<void> clearAllUserData() => transaction(() async {
    await delete(aIChatMessageRecords).go();
    await delete(aIConversationRecords).go();
    await delete(aIToolAuditRecords).go();
    await delete(syncConflictRecords).go();
    await delete(tombstoneRecords).go();
    await delete(recurrenceRecords).go();
    await delete(transactionRecords).go();
    await delete(budgetRecords).go();
    await delete(accountRecords).go();
    await delete(preferenceRecords).go();
    await delete(syncMetadata).go();
  });
}
