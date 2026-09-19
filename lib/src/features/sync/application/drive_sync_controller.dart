import 'dart:async';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../core/database/app_database.dart';
import '../../settings/domain/app_settings.dart';
import '../../settings/domain/settings_repository.dart';
import '../data/google_drive_remote_store.dart';
import '../data/sync_snapshot_store.dart';
import '../domain/sync_models.dart';
import '../oauth/drive_auth_service.dart';
import '../security/sync_key_manager.dart';
import 'sync_engine.dart';

class DriveSyncController extends ChangeNotifier {
  DriveSyncController(
    this._auth,
    this._settingsRepository,
    this._keyManager,
    this._engine,
    this._localStore, {
    required this.onRemoteDataChanged,
    DriveRemoteStore Function(http.Client)? remoteStoreFactory,
  }) : _remoteStoreFactory =
           remoteStoreFactory ?? ((client) => GoogleDriveRemoteStore(client));

  final DriveAuthService _auth;
  final SettingsRepository _settingsRepository;
  final SyncKeyManager _keyManager;
  final SyncEngine _engine;
  final SyncSnapshotStore _localStore;
  final DriveRemoteStore Function(http.Client) _remoteStoreFactory;
  final Future<void> Function() onRemoteDataChanged;

  DriveAuthSession? _session;
  Timer? _debounce;
  SyncSettings settings = const SyncSettings();
  SyncStatus status = SyncStatus.disconnected;
  String? errorMessage;
  DateTime? lastSyncAt;

  bool get needsGoogleReconnect => settings.enabled && _session == null;

  Future<void> initialize() async {
    settings = await _settingsRepository.readSyncSettings();
    if (!settings.enabled) {
      status = SyncStatus.disconnected;
      notifyListeners();
      return;
    }
    final key = await _keyManager.read();
    _session = await _auth.restore();
    if (key == null || _session == null) {
      status = SyncStatus.disconnected;
      errorMessage = key == null
          ? 'Informe novamente a senha de sincronização.'
          : 'Reconecte sua conta Google.';
      notifyListeners();
      return;
    }
    await syncNow();
  }

  Future<void> connect(
    String password, {
    bool allowAccountChange = false,
  }) async {
    errorMessage = null;
    try {
      final newSession = await _auth.connect();
      final previousEmail = settings.accountEmail;
      final nextEmail = newSession.accountEmail;
      if (!allowAccountChange &&
          previousEmail != null &&
          nextEmail != null &&
          previousEmail != nextEmail) {
        newSession.close();
        await _auth.disconnect();
        throw AccountChangeConfirmationRequired(previousEmail, nextEmail);
      }
      _session?.close();
      _session = newSession;
      final remoteStore = _remoteStoreFactory(newSession.client);
      final remote = await remoteStore.download();
      if (remote == null) {
        await _keyManager.create(password);
      } else {
        await _keyManager.unlock(password, remote.bytes);
      }
      settings = settings.copyWith(
        enabled: true,
        accountEmail: nextEmail ?? previousEmail,
      );
      await _settingsRepository.saveSyncSettings(settings);
      await syncNow(rethrowErrors: true);
    } on AccountChangeConfirmationRequired {
      status = SyncStatus.disconnected;
      notifyListeners();
      rethrow;
    } catch (error) {
      status = SyncStatus.error;
      errorMessage = _safeError(error);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> reconnect() async {
    if (!settings.enabled || status == SyncStatus.resetting) return;
    errorMessage = null;
    try {
      final newSession = await _auth.connect();
      final previousEmail = settings.accountEmail;
      final nextEmail = newSession.accountEmail;
      if (previousEmail != null &&
          nextEmail != null &&
          previousEmail != nextEmail) {
        newSession.close();
        await _auth.invalidateCachedSession();
        throw DriveAuthException(
          'Selecione a conta $previousEmail para continuar sincronizando. Para '
          'trocar de Drive, desconecte a sincronização primeiro.',
        );
      }
      if (await _keyManager.read() == null) {
        newSession.close();
        await _auth.invalidateCachedSession();
        throw const DriveAuthException(
          'A chave de sincronização não está disponível. Desconecte e conecte '
          'novamente informando a senha.',
        );
      }
      _session?.close();
      _session = newSession;
      await syncNow(rethrowErrors: true);
    } catch (error) {
      status = SyncStatus.error;
      errorMessage = _safeError(error);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> disconnect() async {
    if (status == SyncStatus.resetting) return;
    _debounce?.cancel();
    _session?.close();
    _session = null;
    await _auth.disconnect();
    await _keyManager.clear();
    settings = settings.copyWith(enabled: false);
    await _settingsRepository.saveSyncSettings(settings);
    status = SyncStatus.disconnected;
    errorMessage = null;
    notifyListeners();
  }

  Future<void> setAutoSync(bool value) async {
    if (status == SyncStatus.resetting) return;
    settings = settings.copyWith(autoSync: value);
    await _settingsRepository.saveSyncSettings(settings);
    notifyListeners();
  }

  Future<void> syncNow({bool rethrowErrors = false}) async {
    if (status == SyncStatus.syncing || status == SyncStatus.resetting) return;
    if (_session == null && !await _restoreSession()) {
      notifyListeners();
      return;
    }
    final session = _session;
    final key = await _keyManager.read();
    if (session == null || key == null) {
      status = SyncStatus.disconnected;
      notifyListeners();
      return;
    }
    _session ??= session;
    status = SyncStatus.syncing;
    errorMessage = null;
    notifyListeners();
    try {
      SyncMergeResult result;
      try {
        result = await _engine.synchronize(
          remoteStore: _remoteStoreFactory(session.client),
          key: key,
        );
      } on DriveRemoteException catch (error) {
        if (error.status != 401) rethrow;
        session.close();
        _session = null;
        await _auth.invalidateCachedSession();
        if (!await _restoreSession() || _session == null) {
          throw const DriveAuthException(
            'A sessão Google expirou. Toque em Reconectar Google nas '
            'Configurações. Seus dados locais continuam seguros.',
          );
        }
        try {
          result = await _engine.synchronize(
            remoteStore: _remoteStoreFactory(_session!.client),
            key: key,
          );
        } on DriveRemoteException catch (retryError) {
          if (retryError.status != 401) rethrow;
          _session?.close();
          _session = null;
          await _auth.invalidateCachedSession();
          throw const DriveAuthException(
            'A sessão Google expirou. Toque em Reconectar Google nas '
            'Configurações. Seus dados locais continuam seguros.',
          );
        }
      }
      if (result.changed) await onRemoteDataChanged();
      status = result.conflicts > 0 ? SyncStatus.conflict : SyncStatus.synced;
      lastSyncAt = DateTime.now();
    } catch (error) {
      status = SyncStatus.error;
      errorMessage = _safeError(error);
      if (kDebugMode) {
        debugPrint('[DriveSync] ${error.runtimeType}: $errorMessage');
      }
      notifyListeners();
      if (rethrowErrors) rethrow;
      return;
    }
    notifyListeners();
  }

  void markLocalChange() {
    if (!settings.enabled) return;
    if (status == SyncStatus.resetting) return;
    if (status == SyncStatus.conflict) {
      notifyListeners();
      return;
    }
    status = SyncStatus.pending;
    notifyListeners();
    if (!settings.autoSync) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 2), syncNow);
  }

  Future<void> onResumed() async {
    if (settings.enabled &&
        status != SyncStatus.conflict &&
        status != SyncStatus.resetting) {
      await syncNow();
    }
  }

  void onPaused() {
    if (settings.enabled && status == SyncStatus.pending) {
      unawaited(syncNow());
    }
  }

  Future<void> resolveConflict(
    SyncConflictRecord conflict, {
    required bool useRemote,
  }) async {
    if (status == SyncStatus.resetting) return;
    await _localStore.resolveConflict(conflict, useRemote: useRemote);
    await onRemoteDataChanged();
    status = SyncStatus.pending;
    notifyListeners();
    await syncNow();
  }

  Future<List<SyncConflictRecord>> readConflicts() =>
      _localStore.readConflicts();

  Future<void> prepareFactoryReset() async {
    if (!settings.enabled) return;
    if (status == SyncStatus.syncing || status == SyncStatus.resetting) {
      throw const DriveAuthException(
        'Aguarde a sincronização atual terminar antes de resetar.',
      );
    }
    if (_session == null && !await _restoreSession()) {
      notifyListeners();
      throw const DriveAuthException(
        'Reconecte sua conta Google antes de resetar o aplicativo.',
      );
    }
    final key = await _keyManager.read();
    final session = _session;
    if (key == null || session == null) {
      throw const DriveAuthException(
        'A chave ou a sessão de sincronização não está disponível.',
      );
    }
    _debounce?.cancel();
    status = SyncStatus.resetting;
    errorMessage = null;
    notifyListeners();
    try {
      await _engine.resetRemote(
        remoteStore: _remoteStoreFactory(session.client),
        key: key,
      );
    } catch (error) {
      status = SyncStatus.error;
      errorMessage = _safeError(error);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> releaseAfterFactoryReset() async {
    _debounce?.cancel();
    _session?.close();
    _session = null;
    try {
      await _auth.disconnect();
    } catch (_) {
      // A limpeza explícita dos segredos ainda acontece no reset local.
    }
    await _keyManager.clear();
    settings = const SyncSettings();
    status = SyncStatus.disconnected;
    errorMessage = null;
    notifyListeners();
  }

  Future<bool> _restoreSession() async {
    final restored = await _auth.restore();
    if (restored == null) {
      status = SyncStatus.disconnected;
      errorMessage = 'Reconecte sua conta Google.';
      return false;
    }
    if (settings.accountEmail != null &&
        restored.accountEmail != null &&
        settings.accountEmail != restored.accountEmail) {
      restored.close();
      status = SyncStatus.error;
      errorMessage =
          'A conta Google mudou. Reconecte e confirme antes de mesclar.';
      return false;
    }
    _session?.close();
    _session = restored;
    return true;
  }

  String _safeError(Object error) {
    if (error is FormatException) return error.message;
    if (error is DriveAuthException) return error.message;
    if (error is DriveRemoteException) return error.message;
    if (error is SecretBoxAuthenticationError) {
      return 'Senha de sincronização incorreta ou arquivo adulterado.';
    }
    if (error is TimeoutException) return 'A sincronização expirou.';
    return 'Não foi possível sincronizar. Tente novamente.';
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _session?.close();
    super.dispose();
  }
}

class AccountChangeConfirmationRequired implements Exception {
  const AccountChangeConfirmationRequired(this.previous, this.next);
  final String previous;
  final String next;
}
