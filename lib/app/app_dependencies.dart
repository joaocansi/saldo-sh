import '../core/database/app_database.dart';
import '../core/database/device_identity.dart';
import '../core/security/secret_store.dart';
import '../features/ai/data/openai_compatible_provider.dart';
import '../features/ai/data/drift_ai_tool_audit.dart';
import '../features/ai/data/drift_ai_conversation_repository.dart';
import '../features/ai/domain/ai_conversation.dart';
import '../features/ai/domain/ai_provider.dart';
import '../features/ai/domain/ai_tool_audit.dart';
import '../features/finance/application/finance_controller.dart';
import '../features/finance/data/local/drift_finance_repository.dart';
import '../features/finance/data/local/legacy_finance_migrator.dart';
import '../features/finance/domain/repositories/finance_repository.dart';
import '../features/settings/data/drift_settings_repository.dart';
import '../features/settings/application/factory_reset_service.dart';
import '../features/settings/domain/settings_repository.dart';
import '../features/sync/application/drive_sync_controller.dart';
import '../features/sync/application/sync_engine.dart';
import '../features/sync/data/sync_snapshot_store.dart';
import '../features/sync/oauth/drive_auth_service.dart';
import '../features/sync/oauth/google_drive_auth_service.dart';
import '../features/sync/security/sync_cipher.dart';
import '../features/sync/security/sync_key_manager.dart';

class AppDependencies {
  AppDependencies._({
    required this.database,
    required this.financeRepository,
    required this.settingsRepository,
    required this.secretStore,
    required this.aiProvider,
    required this.aiToolAudit,
    required this.aiConversationRepository,
    required this.driveAuth,
    required this.syncSnapshotStore,
    required this.syncCipher,
    required this.syncKeyManager,
    required this.factoryResetService,
  });

  final AppDatabase database;
  final FinanceRepository financeRepository;
  final SettingsRepository settingsRepository;
  final SecretStore secretStore;
  final AIProvider aiProvider;
  final AIToolAudit aiToolAudit;
  final AIConversationRepository aiConversationRepository;
  final DriveAuthService driveAuth;
  final SyncSnapshotStore syncSnapshotStore;
  final SyncCipher syncCipher;
  final SyncKeyManager syncKeyManager;
  final FactoryResetService factoryResetService;

  static Future<AppDependencies> create({
    AppDatabase? database,
    SecretStore? secretStore,
    DriveAuthService? driveAuth,
    AIProvider? aiProvider,
    bool migrateLegacyData = true,
  }) async {
    final db = database ?? AppDatabase();
    final secrets = secretStore ?? PlatformSecretStore();
    final identity = DeviceIdentity(db);
    final finance = DriftFinanceRepository(db, identity);
    if (migrateLegacyData) {
      await LegacyFinanceMigrator(db, finance).run();
    }
    final cipher = SyncCipher();
    return AppDependencies._(
      database: db,
      financeRepository: finance,
      settingsRepository: DriftSettingsRepository(db, identity),
      secretStore: secrets,
      aiProvider: aiProvider ?? OpenAICompatibleProvider(),
      aiToolAudit: DriftAIToolAudit(db),
      aiConversationRepository: DriftAIConversationRepository(db),
      driveAuth: driveAuth ?? GoogleDriveAuthService(secrets),
      syncSnapshotStore: SyncSnapshotStore(db, identity),
      syncCipher: cipher,
      syncKeyManager: SyncKeyManager(secrets, cipher),
      factoryResetService: FactoryResetService(db, secrets),
    );
  }

  DriveSyncController createSyncController(
    FinanceController finance, {
    Future<void> Function()? onRemoteDataChanged,
  }) => DriveSyncController(
    driveAuth,
    settingsRepository,
    syncKeyManager,
    SyncEngine(syncSnapshotStore, syncCipher),
    syncSnapshotStore,
    onRemoteDataChanged: onRemoteDataChanged ?? finance.reload,
  );
}
