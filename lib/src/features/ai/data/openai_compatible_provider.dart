import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../settings/domain/app_settings.dart';
import '../domain/ai_provider.dart';

class OpenAICompatibleProvider implements AIProvider {
  OpenAICompatibleProvider({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  @override
  Future<AIProviderResponse> complete({
    required AISettings settings,
    required String apiKey,
    required List<Map<String, dynamic>> messages,
    required List<AIToolDefinition> tools,
  }) async {
    final response = await _client
        .post(
          _endpoint(settings.endpoint, 'chat/completions'),
          headers: {
            'authorization': 'Bearer $apiKey',
            'content-type': 'application/json',
            if (settings.provider == 'openrouter') ...{
              'HTTP-Referer': 'https://saldo-sh.local',
              'X-Title': 'saldo.sh',
            },
          },
          body: jsonEncode({
            'model': settings.model,
            'messages': messages,
            if (tools.isNotEmpty)
              'tools': tools.map((tool) => tool.toJson()).toList(),
            if (tools.isNotEmpty) 'tool_choice': 'auto',
            'temperature': 0.1,
          }),
        )
        .timeout(const Duration(seconds: 45));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AIProviderException(_responseError(response));
    }
    if (response.bodyBytes.length > 2 * 1024 * 1024) {
      throw const AIProviderException('Resposta do provedor acima do limite.');
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    final choices = decoded is Map ? decoded['choices'] : null;
    if (choices is! List || choices.isEmpty) {
      throw const AIProviderException('Resposta inválida do provedor.');
    }
    final rawMessage = Map<String, dynamic>.from(
      Map<dynamic, dynamic>.from(choices.first['message'] as Map),
    );
    final rawCalls = rawMessage['tool_calls'];
    final calls = <AIToolCall>[];
    if (rawCalls is List) {
      if (rawCalls.length > 6) {
        throw const AIProviderException('O provedor excedeu seis ferramentas.');
      }
      for (final raw in rawCalls) {
        final call = Map<String, dynamic>.from(raw as Map);
        final function = Map<String, dynamic>.from(call['function'] as Map);
        final rawArguments = function['arguments'];
        final arguments = rawArguments is Map
            ? rawArguments
            : jsonDecode(rawArguments as String? ?? '{}');
        if (arguments is! Map) continue;
        calls.add(
          AIToolCall(
            id: call['id'] as String? ?? 'tool-${calls.length}',
            name: function['name'] as String? ?? '',
            arguments: Map<String, dynamic>.from(arguments),
          ),
        );
      }
    }
    return AIProviderResponse(
      content: _contentText(rawMessage['content']),
      toolCalls: calls,
      assistantMessage: rawMessage,
      usage: _usage(decoded is Map ? decoded['usage'] : null),
    );
  }

  AITokenUsage? _usage(Object? raw) {
    if (raw is! Map) return null;
    final input = raw['prompt_tokens'];
    final output = raw['completion_tokens'];
    if (input is! int || output is! int || input < 0 || output < 0) return null;
    return AITokenUsage(inputTokens: input, outputTokens: output);
  }

  @override
  Future<List<String>> listModels(AISettings settings, String apiKey) async {
    final response = await _client
        .get(
          _endpoint(settings.endpoint, 'models'),
          headers: {'authorization': 'Bearer $apiKey'},
        )
        .timeout(const Duration(seconds: 20));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AIProviderException(_responseError(response));
    }
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    final data = decoded is Map ? decoded['data'] : null;
    if (data is! List) return [];
    final models =
        data
            .whereType<Map>()
            .map((item) => item['id']?.toString() ?? '')
            .where((id) => id.isNotEmpty)
            .toList()
          ..sort();
    return models;
  }

  Uri _endpoint(String baseUrl, String path) {
    final base = baseUrl.trim().replaceAll(RegExp(r'/+$'), '');
    final uri = Uri.parse('$base/$path');
    final localhost = uri.host == 'localhost' || uri.host == '127.0.0.1';
    if (!uri.hasAuthority ||
        (uri.scheme != 'https' && !(kDebugMode && localhost))) {
      throw const AIProviderException('O endpoint da IA deve usar HTTPS.');
    }
    return uri;
  }

  String _contentText(Object? content) {
    if (content is String) return content;
    if (content is List) {
      return content
          .whereType<Map>()
          .map((part) => part['text']?.toString() ?? '')
          .where((part) => part.isNotEmpty)
          .join('\n');
    }
    return content?.toString() ?? '';
  }

  String _responseError(http.Response response) {
    var detail = '';
    if (response.bodyBytes.length <= 64 * 1024) {
      try {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        if (decoded is Map) {
          final error = decoded['error'];
          if (error is Map) {
            detail = error['message']?.toString() ?? '';
          } else {
            detail = error?.toString() ?? decoded['message']?.toString() ?? '';
          }
        }
      } catch (_) {
        // A resposta pode não ser JSON. O status HTTP ainda é informativo.
      }
    }
    detail = detail.replaceAll(RegExp(r'[\r\n]+'), ' ').trim();
    if (detail.length > 240) detail = '${detail.substring(0, 240)}…';
    return detail.isEmpty
        ? 'O provedor retornou HTTP ${response.statusCode}.'
        : 'O provedor retornou HTTP ${response.statusCode}: $detail';
  }
}

class AIProviderException implements Exception {
  const AIProviderException(this.message);
  final String message;
  @override
  String toString() => message;
}
