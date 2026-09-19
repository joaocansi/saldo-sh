import 'dart:convert';

import 'package:saldo_sh/src/features/ai/data/openai_compatible_provider.dart';
import 'package:saldo_sh/src/features/settings/domain/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('reads provider usage and preserves tool metadata for compatible providers', () async {
    final provider = OpenAICompatibleProvider(
      client: MockClient((request) async {
        expect(request.url.path, '/v1beta/openai/chat/completions');
        expect(request.headers['authorization'], 'Bearer test-key');
        return http.Response(
          jsonEncode({
            'choices': [
              {
                'message': {
                  'role': 'assistant',
                  'content': null,
                  'tool_calls': [
                    {
                      'id': 'c1',
                      'type': 'function',
                      'function': {
                        'name': 'query_finances',
                        'arguments': '{"operation":"balance"}',
                      },
                      'extra_content': {
                        'google': {'thought_signature': 'test-signature'},
                      },
                    },
                  ],
                },
              },
            ],
            'usage': {'prompt_tokens': 420, 'completion_tokens': 80},
          }),
          200,
        );
      }),
    );
    final result = await provider.complete(
      settings: const AISettings(
        endpoint: 'https://generativelanguage.googleapis.com/v1beta/openai',
      ),
      apiKey: 'test-key',
      messages: [],
      tools: [],
    );
    expect(result.usage?.totalTokens, 500);
    expect(result.toolCalls.single.arguments['operation'], 'balance');
    expect(
      result
          .assistantMessage['tool_calls'][0]['extra_content']['google']['thought_signature'],
      'test-signature',
    );
  });

  test(
    'missing usage stays unknown, rather than reporting zero consumption',
    () async {
      final provider = OpenAICompatibleProvider(
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({
              'choices': [
                {
                  'message': {'role': 'assistant', 'content': 'Olá'},
                },
              ],
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          ),
        ),
      );
      final result = await provider.complete(
        settings: const AISettings(),
        apiKey: 'test-key',
        messages: [],
        tools: [],
      );
      expect(result.usage, isNull);
    },
  );

  test(
    'excessive tool batches are rejected instead of silently truncated',
    () async {
      final provider = OpenAICompatibleProvider(
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({
              'choices': [
                {
                  'message': {
                    'role': 'assistant',
                    'content': null,
                    'tool_calls': List.filled(7, {}),
                  },
                },
              ],
            }),
            200,
          ),
        ),
      );
      await expectLater(
        provider.complete(
          settings: const AISettings(),
          apiKey: 'test-key',
          messages: [],
          tools: [],
        ),
        throwsA(isA<AIProviderException>()),
      );
    },
  );
}
