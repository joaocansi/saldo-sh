import '../../../core/security/secret_store.dart';
import '../../settings/domain/app_settings.dart';
import '../domain/ai_conversation_context.dart';
import 'ai_gateway.dart';

class AssistantService {
  const AssistantService(this._gateway, this._secretStore);

  final AIGateway _gateway;
  final SecretStore _secretStore;

  Future<AIGatewayResult> ask({
    required String prompt,
    required AISettings settings,
    List<AIConversationMessage> history = const [],
    AIConversationContext conversationContext = const AIConversationContext(),
    AIProgressCallback? onProgress,
  }) async {
    if (prompt.trim().length > 4000) {
      return const AIGatewayResult(
        'Envie uma mensagem de até 4000 caracteres.',
      );
    }

    final key = await _secretStore.read(SecretKeys.aiApiKey);
    if (key == null || key.isEmpty) {
      throw const AssistantUnavailableException(
        'Configure um provedor, modelo e API key em Configurações → '
        'Inteligência Artificial.',
      );
    }

    try {
      return await _gateway.ask(
        prompt: prompt,
        settings: settings,
        apiKey: key,
        history: history,
        conversationContext: conversationContext,
        onProgress: onProgress,
      );
    } catch (error) {
      throw AssistantUnavailableException(_providerFailureMessage(error, key));
    }
  }

  String _providerFailureMessage(Object error, String apiKey) {
    var detail = error.toString().replaceAll(apiKey, '[chave protegida]');
    detail = detail.replaceAll(RegExp(r'[\r\n]+'), ' ').trim();
    if (detail.length > 180) detail = '${detail.substring(0, 180)}…';
    if (detail.isEmpty) detail = 'erro desconhecido';
    return 'Não foi possível consultar a IA ($detail). Verifique a '
        'conexão e a configuração do modelo. Nenhuma alteração foi feita.';
  }
}

class AssistantUnavailableException implements Exception {
  const AssistantUnavailableException(this.message);

  final String message;

  @override
  String toString() => message;
}
