import 'package:flutter/foundation.dart';

import '../../../core/security/secret_store.dart';
import '../../ai/domain/ai_provider.dart';
import '../domain/app_settings.dart';
import '../domain/settings_repository.dart';

class SettingsController extends ChangeNotifier {
  SettingsController(this._repository, this._secretStore, this._aiProvider);

  final SettingsRepository _repository;
  final SecretStore _secretStore;
  final AIProvider _aiProvider;

  AISettings ai = const AISettings();
  SyncSettings sync = const SyncSettings();
  String? displayName;
  bool hasAIKey = false;
  bool loading = true;
  String? aiStatus;

  Future<void> initialize() async {
    await reload();
    loading = false;
    notifyListeners();
  }

  Future<void> reload() async {
    displayName = await _repository.readDisplayName();
    ai = await _repository.readAISettings();
    sync = await _repository.readSyncSettings();
    hasAIKey =
        (await _secretStore.read(SecretKeys.aiApiKey))?.isNotEmpty == true;
    notifyListeners();
  }

  Future<void> saveDisplayName(String value) async {
    final normalized = value.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalized.isEmpty ||
        normalized.length > 60 ||
        RegExp(r'[\x00-\x1F\x7F]').hasMatch(normalized)) {
      throw const FormatException('Nome inválido.');
    }
    await _repository.saveDisplayName(normalized);
    displayName = normalized;
    notifyListeners();
  }

  Future<void> saveAI(AISettings value, {String? apiKey}) async {
    if (!{'openai', 'openrouter', 'custom'}.contains(value.provider) ||
        value.model.trim().isEmpty ||
        value.model.length > 200 ||
        value.endpoint.length > 2048) {
      throw const FormatException('Configuração de IA inválida.');
    }
    if (apiKey != null &&
        (apiKey.length > 10000 ||
            apiKey.contains('\n') ||
            apiKey.contains('\r'))) {
      throw const FormatException('API key inválida.');
    }
    _validateEndpoint(value.endpoint);
    ai = value;
    await _repository.saveAISettings(value);
    if (apiKey != null && apiKey.trim().isNotEmpty) {
      await _secretStore.write(SecretKeys.aiApiKey, apiKey.trim());
      hasAIKey = true;
    }
    aiStatus = null;
    notifyListeners();
  }

  Future<void> removeAIKey() async {
    await _secretStore.delete(SecretKeys.aiApiKey);
    hasAIKey = false;
    aiStatus = 'Chave removida';
    notifyListeners();
  }

  Future<bool> testAIConnection() async {
    final apiKey = await _secretStore.read(SecretKeys.aiApiKey);
    if (apiKey == null || apiKey.isEmpty) {
      aiStatus = 'Informe uma API key';
      notifyListeners();
      return false;
    }
    aiStatus = 'Testando…';
    notifyListeners();
    try {
      final response = await _aiProvider.complete(
        settings: ai,
        apiKey: apiKey,
        messages: const [
          {'role': 'system', 'content': 'Responda apenas com a palavra OK.'},
          {'role': 'user', 'content': 'Teste de conexão.'},
        ],
        tools: const [],
      );
      if (response.content.trim().isEmpty) {
        throw const FormatException('O modelo não retornou conteúdo.');
      }
      aiStatus = 'Modelo conectado';
      notifyListeners();
      return true;
    } catch (_) {
      aiStatus = 'Não foi possível conectar';
      notifyListeners();
      return false;
    }
  }

  Future<void> saveSync(SyncSettings value) async {
    sync = value;
    await _repository.saveSyncSettings(value);
    notifyListeners();
  }

  static void _validateEndpoint(String value) {
    final uri = Uri.tryParse(value.trim());
    final localhost = uri?.host == 'localhost' || uri?.host == '127.0.0.1';
    if (uri == null ||
        !uri.hasAuthority ||
        (uri.scheme != 'https' && !(kDebugMode && localhost))) {
      throw const FormatException('Use HTTPS (HTTP só é aceito em localhost).');
    }
  }
}
