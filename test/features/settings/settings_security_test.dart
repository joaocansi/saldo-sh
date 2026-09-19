import 'dart:convert';

import 'package:drift/native.dart';
import 'package:saldo_sh/src/core/database/app_database.dart';
import 'package:saldo_sh/src/core/database/device_identity.dart';
import 'package:saldo_sh/src/core/security/secret_store.dart';
import 'package:saldo_sh/src/features/ai/domain/ai_provider.dart';
import 'package:saldo_sh/src/features/settings/application/settings_controller.dart';
import 'package:saldo_sh/src/features/settings/data/drift_settings_repository.dart';
import 'package:saldo_sh/src/features/settings/domain/app_settings.dart';
import 'package:saldo_sh/src/features/sync/data/sync_snapshot_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('API keys never appear in SQLite snapshots', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final identity = DeviceIdentity(database);
    final settings = DriftSettingsRepository(database, identity);
    final secrets = _MemorySecretStore();
    const apiKey = 'sk-segredo-que-nao-pode-sincronizar';

    await settings.saveAISettings(
      const AISettings(
        provider: 'openrouter',
        endpoint: 'https://openrouter.ai/api/v1',
        model: 'modelo-teste',
      ),
    );
    await secrets.write(SecretKeys.aiApiKey, apiKey);
    final snapshot = await SyncSnapshotStore(
      database,
      identity,
    ).exportSnapshot();
    final encoded = jsonEncode(snapshot);

    expect(encoded, contains('openrouter.ai'));
    expect(encoded, contains('modelo-teste'));
    expect(encoded, isNot(contains(apiKey)));
    expect(await secrets.read(SecretKeys.aiApiKey), apiKey);
  });

  test('rejects malformed AI settings before storing secrets', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final secrets = _MemorySecretStore();
    final controller = SettingsController(
      DriftSettingsRepository(database, DeviceIdentity(database)),
      secrets,
      _FakeAIProvider(),
    );

    await expectLater(
      controller.saveAI(
        const AISettings(
          provider: 'unknown',
          endpoint: 'https://example.com/v1',
          model: 'model',
        ),
      ),
      throwsFormatException,
    );
    await expectLater(
      controller.saveAI(
        const AISettings(
          provider: 'custom',
          endpoint: 'http://example.com/v1',
          model: 'model',
        ),
      ),
      throwsFormatException,
    );
    await expectLater(
      controller.saveAI(
        const AISettings(
          provider: 'custom',
          endpoint: 'https://example.com/v1',
          model: 'model',
        ),
        apiKey: 'invalid\nkey',
      ),
      throwsFormatException,
    );

    expect(await secrets.read(SecretKeys.aiApiKey), isNull);
  });

  test(
    'tests the configured chat model instead of only listing models',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final secrets = _MemorySecretStore();
      final provider = _FakeAIProvider();
      final controller = SettingsController(
        DriftSettingsRepository(database, DeviceIdentity(database)),
        secrets,
        provider,
      );
      await controller.initialize();
      await secrets.write(SecretKeys.aiApiKey, 'key');
      await controller.reload();

      expect(await controller.testAIConnection(), isTrue);
      expect(provider.completeCalls, 1);
      expect(provider.listModelCalls, 0);
      expect(controller.aiStatus, 'Modelo conectado');
    },
  );
}

class _FakeAIProvider implements AIProvider {
  int completeCalls = 0;
  int listModelCalls = 0;

  @override
  Future<AIProviderResponse> complete({
    required AISettings settings,
    required String apiKey,
    required List<Map<String, dynamic>> messages,
    required List<AIToolDefinition> tools,
  }) async {
    completeCalls++;
    return const AIProviderResponse(
      content: 'OK',
      toolCalls: [],
      assistantMessage: {'role': 'assistant', 'content': 'OK'},
    );
  }

  @override
  Future<List<String>> listModels(AISettings settings, String apiKey) async {
    listModelCalls++;
    return const [];
  }
}

class _MemorySecretStore implements SecretStore {
  final values = <String, String>{};

  @override
  Future<void> delete(String key) async => values.remove(key);
  @override
  Future<String?> read(String key) async => values[key];
  @override
  Future<void> write(String key, String value) async => values[key] = value;
}
