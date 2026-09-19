import '../../settings/domain/app_settings.dart';

class AIToolDefinition {
  const AIToolDefinition({
    required this.name,
    required this.description,
    required this.parameters,
  });

  final String name;
  final String description;
  final Map<String, dynamic> parameters;

  Map<String, dynamic> toJson() => {
    'type': 'function',
    'function': {
      'name': name,
      'description': description,
      'parameters': parameters,
    },
  };
}

class AIToolCall {
  const AIToolCall({
    required this.id,
    required this.name,
    required this.arguments,
  });

  final String id;
  final String name;
  final Map<String, dynamic> arguments;
}

class AIProviderResponse {
  const AIProviderResponse({
    required this.content,
    required this.toolCalls,
    required this.assistantMessage,
    this.usage,
  });

  final String content;
  final List<AIToolCall> toolCalls;
  final Map<String, dynamic> assistantMessage;
  final AITokenUsage? usage;
}

class AITokenUsage {
  const AITokenUsage({this.inputTokens = 0, this.outputTokens = 0});
  final int inputTokens;
  final int outputTokens;
  int get totalTokens => inputTokens + outputTokens;

  AITokenUsage operator +(AITokenUsage other) => AITokenUsage(
    inputTokens: inputTokens + other.inputTokens,
    outputTokens: outputTokens + other.outputTokens,
  );
}

abstract interface class AIProvider {
  Future<AIProviderResponse> complete({
    required AISettings settings,
    required String apiKey,
    required List<Map<String, dynamic>> messages,
    required List<AIToolDefinition> tools,
  });

  Future<List<String>> listModels(AISettings settings, String apiKey);
}
