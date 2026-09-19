import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/app_dependencies.dart';
import 'package:flutter_application_1/core/database/app_database.dart';
import 'package:flutter_application_1/core/security/secret_store.dart';
import 'package:flutter_application_1/features/ai/domain/ai_provider.dart';
import 'package:flutter_application_1/features/ai/presentation/assistant_page.dart';
import 'package:flutter_application_1/features/settings/domain/app_settings.dart';
import 'package:flutter_application_1/features/onboarding/presentation/onboarding_page.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the finance dashboard without an animated app loader', (
    tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final dependencies = await AppDependencies.create(
      database: database,
      secretStore: _MemorySecretStore(),
      migrateLegacyData: false,
    );
    const profileName = 'Maria Silva';
    await dependencies.settingsRepository.saveDisplayName(profileName);

    await tester.pumpWidget(
      VerdeApp(initialDisplayName: profileName, dependencies: dependencies),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Maria'), findsOneWidget);
    expect(find.textContaining('Registrar'), findsWidgets);
    expect(find.byType(OnboardingPage), findsNothing);
  });

  testWidgets('opens onboarding immediately when there is no profile', (
    tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final dependencies = await AppDependencies.create(
      database: database,
      secretStore: _MemorySecretStore(),
      migrateLegacyData: false,
    );

    await tester.pumpWidget(
      VerdeApp(initialDisplayName: null, dependencies: dependencies),
    );

    expect(find.byType(OnboardingPage), findsOneWidget);
  });

  testWidgets('keeps an AI request running while another page is open', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 800);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final provider = _DelayedAIProvider();
    final secrets = _MemorySecretStore()
      ..values[SecretKeys.aiApiKey] = 'test-key';
    final dependencies = await AppDependencies.create(
      database: database,
      secretStore: secrets,
      aiProvider: provider,
      migrateLegacyData: false,
    );
    await dependencies.settingsRepository.saveDisplayName('Maria');

    await tester.pumpWidget(
      VerdeApp(initialDisplayName: 'Maria', dependencies: dependencies),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Assistente'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField),
      'Analise minhas finan\u00e7as',
    );
    await tester.testTextInput.receiveAction(TextInputAction.send);
    for (var attempt = 0; attempt < 10 && provider.requests == 0; attempt++) {
      await tester.pump();
    }
    expect(provider.requests, 1);

    await tester.tap(find.text('In\u00edcio'));
    await tester.pump();
    expect(find.textContaining('Ol\u00e1, Maria'), findsOneWidget);

    provider.finish();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Assistente'));
    await tester.pumpAndSettle();

    expect(
      find.text('An\u00e1lise conclu\u00edda em segundo plano.'),
      findsOneWidget,
    );
    final conversations = await dependencies.aiConversationRepository
        .readConversations();
    final messages = await dependencies.aiConversationRepository.readMessages(
      conversations.single.id,
    );
    expect(messages.map((message) => message.role), ['user', 'assistant']);
  });

  testWidgets('exposes the assistant directly in mobile navigation', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 800);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final dependencies = await AppDependencies.create(
      database: database,
      secretStore: _MemorySecretStore(),
      migrateLegacyData: false,
    );
    await dependencies.settingsRepository.saveDisplayName('Maria');

    await tester.pumpWidget(
      VerdeApp(initialDisplayName: 'Maria', dependencies: dependencies),
    );
    await tester.pumpAndSettle();

    expect(find.text('Assistente'), findsOneWidget);
    await tester.tap(find.text('Assistente'));
    await tester.pumpAndSettle();
    expect(find.byType(AssistantPage), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.hintText?.startsWith('Converse') == true,
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Mais'));
    await tester.pumpAndSettle();
    expect(find.text('Or\u00e7amento'), findsOneWidget);
    expect(find.text('Relat\u00f3rios'), findsOneWidget);
    expect(find.text('Configura\u00e7\u00f5es'), findsOneWidget);
  });
}

class _DelayedAIProvider implements AIProvider {
  final _response = Completer<AIProviderResponse>();
  int requests = 0;

  void finish() => _response.complete(
    const AIProviderResponse(
      content: 'An\u00e1lise conclu\u00edda em segundo plano.',
      toolCalls: [],
      assistantMessage: {
        'role': 'assistant',
        'content': 'An\u00e1lise conclu\u00edda em segundo plano.',
      },
    ),
  );

  @override
  Future<AIProviderResponse> complete({
    required AISettings settings,
    required String apiKey,
    required List<Map<String, dynamic>> messages,
    required List<AIToolDefinition> tools,
  }) {
    requests++;
    return _response.future;
  }

  @override
  Future<List<String>> listModels(AISettings settings, String apiKey) async =>
      const [];
}

class _MemorySecretStore implements SecretStore {
  final values = <String, String>{};

  @override
  Future<void> delete(String key) async => values.remove(key);

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
  }
}
