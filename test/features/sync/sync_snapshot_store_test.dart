import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:saldo_sh/src/core/database/app_database.dart';
import 'package:saldo_sh/src/core/database/device_identity.dart';
import 'package:saldo_sh/src/features/finance/data/local/drift_finance_repository.dart';
import 'package:saldo_sh/src/features/finance/domain/models.dart';
import 'package:saldo_sh/src/features/settings/data/drift_settings_repository.dart';
import 'package:saldo_sh/src/features/settings/domain/app_settings.dart';
import 'package:saldo_sh/src/features/sync/data/sync_snapshot_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase androidDb;
  late AppDatabase windowsDb;
  late DriftFinanceRepository androidRepo;
  late DriftFinanceRepository windowsRepo;
  late SyncSnapshotStore androidSync;
  late SyncSnapshotStore windowsSync;

  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  setUp(() {
    androidDb = AppDatabase.forTesting(NativeDatabase.memory());
    windowsDb = AppDatabase.forTesting(NativeDatabase.memory());
    final androidIdentity = DeviceIdentity(androidDb);
    final windowsIdentity = DeviceIdentity(windowsDb);
    androidRepo = DriftFinanceRepository(androidDb, androidIdentity);
    windowsRepo = DriftFinanceRepository(windowsDb, windowsIdentity);
    androidSync = SyncSnapshotStore(androidDb, androidIdentity);
    windowsSync = SyncSnapshotStore(windowsDb, windowsIdentity);
  });

  tearDown(() async {
    await androidDb.close();
    await windowsDb.close();
  });

  test('merges independent records idempotently', () async {
    await androidRepo.saveAccounts([_account('android', 'Android')]);
    await windowsRepo.saveAccounts([_account('windows', 'Windows')]);

    await windowsSync.merge(await androidSync.exportSnapshot());
    await windowsSync.merge(await androidSync.exportSnapshot());

    expect(await windowsRepo.readAccounts(), hasLength(2));
  });

  test('syncs invoice payments and their tracking preference', () async {
    final checking = _account('checking', 'Conta');
    final card = FinanceAccount(
      id: 'card',
      name: 'Cartao',
      kind: 'card',
      openingBalance: 0,
      limit: 1000,
    );
    await androidRepo.saveAccounts([checking, card]);
    await androidRepo.saveCardInvoiceTrackingStart('card', DateTime(2026, 9));
    await androidRepo.saveTransactions([
      FinanceTransaction(
        id: 'payment',
        name: 'Pagamento de fatura - Cartao',
        category: 'Pagamento de fatura',
        amount: 40,
        date: DateTime(2026, 9, 15),
        dueDate: DateTime(2026, 9, 20),
        type: 'cardPayment',
        accountId: 'checking',
        targetAccountId: 'card',
      ),
    ]);

    await windowsSync.merge(await androidSync.exportSnapshot());

    expect((await windowsRepo.readTransactions()).single.isCardPayment, isTrue);
    expect(
      (await windowsRepo.readCardInvoiceTrackingStarts())['card'],
      DateTime(2026, 9),
    );
  });

  test(
    'exports version 3 and still accepts version 1 and 2 snapshots',
    () async {
      await androidRepo.saveAccounts([_account('legacy', 'Legacy')]);
      final version1 = await androidSync.exportSnapshot()
        ..['schemaVersion'] = 1
        ..remove('resetId');

      expect((await androidSync.exportSnapshot())['schemaVersion'], 3);
      await windowsSync.merge(version1);
      expect(await windowsRepo.readAccounts(), hasLength(1));

      final version2Reset = windowsSync.emptyResetSnapshot('legacy-reset')
        ..['schemaVersion'] = 2;
      await windowsSync.merge(version2Reset);
      expect(await windowsRepo.readAccounts(), isEmpty);
    },
  );

  test('detects concurrent changes to the same record', () async {
    await androidRepo.saveAccounts([_account('shared', 'Inicial')]);
    await windowsSync.merge(await androidSync.exportSnapshot());

    await androidRepo.saveAccounts([_account('shared', 'Alterado no Android')]);
    await windowsRepo.saveAccounts([_account('shared', 'Alterado no Windows')]);
    await windowsSync.merge(await androidSync.exportSnapshot());

    final conflicts = await windowsSync.readConflicts();
    expect(conflicts, hasLength(1));
    expect(conflicts.single.entityId, 'shared');
    expect(
      (await windowsRepo.readAccounts()).single.name,
      'Alterado no Windows',
    );
  });

  test('propagates a tombstone without recreating deleted data', () async {
    await androidRepo.saveAccounts([_account('shared', 'Conta')]);
    await windowsSync.merge(await androidSync.exportSnapshot());
    await androidRepo.saveAccounts([]);

    await windowsSync.merge(await androidSync.exportSnapshot());

    expect(await windowsRepo.readAccounts(), isEmpty);
    expect(
      await windowsDb.select(windowsDb.tombstoneRecords).get(),
      hasLength(1),
    );
  });

  test('turns an offline edit versus deletion into a conflict', () async {
    await androidRepo.saveAccounts([_account('shared', 'Inicial')]);
    await windowsSync.merge(await androidSync.exportSnapshot());
    await androidRepo.saveAccounts([_account('shared', 'Editada no Android')]);
    await windowsRepo.saveAccounts([]);

    final result = await androidSync.merge(await windowsSync.exportSnapshot());

    expect(result.conflicts, 1);
    expect(await androidSync.readConflicts(), hasLength(1));
    expect(
      (await androidRepo.readAccounts()).single.name,
      'Editada no Android',
    );
  });

  test(
    'remote reset clears synced data but preserves the local profile',
    () async {
      final identity = DeviceIdentity(androidDb);
      final settings = DriftSettingsRepository(androidDb, identity);
      await androidRepo.saveAccounts([_account('account', 'Conta')]);
      await settings.saveDisplayName('João');
      await settings.saveAISettings(
        const AISettings(
          provider: 'openrouter',
          endpoint: 'https://openrouter.ai/api/v1',
          model: 'modelo',
        ),
      );

      final result = await androidSync.merge(
        androidSync.emptyResetSnapshot('reset-1'),
      );

      expect(result.changed, isTrue);
      expect(await androidRepo.readAccounts(), isEmpty);
      expect(await settings.readDisplayName(), 'João');
      expect((await settings.readAISettings()).provider, 'openai');
      final exported = await androidSync.exportSnapshot();
      expect(exported['schemaVersion'], 3);
      expect(exported['resetId'], 'reset-1');
    },
  );

  test('ignores a version 1 snapshot after acknowledging a reset', () async {
    await androidSync.merge(androidSync.emptyResetSnapshot('reset-1'));
    await androidRepo.saveAccounts([_account('new', 'Depois do reset')]);
    await windowsRepo.saveAccounts([_account('old', 'Antes do reset')]);

    await androidSync.merge(await windowsSync.exportSnapshot());

    final accounts = await androidRepo.readAccounts();
    expect(accounts.map((item) => item.id), ['new']);
  });
}

FinanceAccount _account(String id, String name) =>
    FinanceAccount(id: id, name: name, kind: 'account', openingBalance: 0);
