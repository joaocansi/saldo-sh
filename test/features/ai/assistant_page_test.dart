import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter/services.dart';
import 'package:saldo_sh/src/core/security/secret_store.dart';
import 'package:saldo_sh/src/features/ai/application/ai_gateway.dart';
import 'package:saldo_sh/src/features/ai/application/assistant_service.dart';
import 'package:saldo_sh/src/features/ai/application/finance_tool_registry.dart';
import 'package:saldo_sh/src/features/ai/domain/ai_chart.dart';
import 'package:saldo_sh/src/features/ai/domain/ai_provider.dart';
import 'package:saldo_sh/src/features/ai/domain/ai_conversation.dart';
import 'package:saldo_sh/src/features/ai/presentation/assistant_page.dart';
import 'package:saldo_sh/src/features/ai/presentation/widgets/ai_chart_card.dart';
import 'package:saldo_sh/src/features/finance/application/finance_controller.dart';
import 'package:saldo_sh/src/features/finance/application/transaction_builder.dart';
import 'package:saldo_sh/src/features/finance/domain/models.dart';
import 'package:saldo_sh/src/features/finance/domain/repositories/finance_repository.dart';
import 'package:saldo_sh/src/features/finance/presentation/widgets/account_editor.dart';
import 'package:saldo_sh/src/features/settings/application/settings_controller.dart';
import 'package:saldo_sh/src/features/settings/domain/app_settings.dart';
import 'package:saldo_sh/src/features/settings/domain/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Enter sends once and Shift+Enter keeps editing', (tester) async {
    final provider = _RecordingProvider();
    final secrets = _MemorySecretStore()
      ..values[SecretKeys.aiApiKey] = 'test-key';
    final settings = SettingsController(
      _MemorySettingsRepository(),
      secrets,
      provider,
    );
    await settings.initialize();
    final finance = FinanceController(_MemoryFinanceRepository());
    await finance.initialize();
    final service = AssistantService(
      AIGateway(provider, FinanceToolRegistry(finance)),
      secrets,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AssistantPage(
            service: service,
            settings: settings,
            historyRepository: _MemoryAIConversationRepository(),
            onDraft: (_) async => false,
            onAccountDraft: (_) async => null,
            onOpenSettings: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final input = find.byType(TextField);
    await tester.enterText(input, 'Qual é meu saldo?');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(provider.requests, hasLength(1));
    expect(find.text('Resposta pronta.'), findsOneWidget);

    await tester.tap(input);
    await tester.enterText(input, 'linha um');
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pump();

    expect(provider.requests, hasLength(1));
  });

  testWidgets(
    'card proposal opens a prefilled form and saves only after review',
    (tester) async {
      final provider = _RecordingProvider(
        response: const AIProviderResponse(
          content: '',
          toolCalls: [
            AIToolCall(
              id: 'card',
              name: 'prepare_account',
              arguments: {
                'name': 'Inter',
                'kind': 'card',
                'limit_cents': 300000,
                'closing_day': 4,
                'due_day': 10,
              },
            ),
          ],
          assistantMessage: {'role': 'assistant', 'content': null},
          usage: AITokenUsage(inputTokens: 400, outputTokens: 60),
        ),
      );
      final secrets = _MemorySecretStore()
        ..values[SecretKeys.aiApiKey] = 'test-key';
      final settings = SettingsController(
        _MemorySettingsRepository(),
        secrets,
        provider,
      );
      await settings.initialize();
      final finance = FinanceController(_MemoryFinanceRepository());
      await finance.initialize();
      FinanceAccount? savedAccount;
      final service = AssistantService(
        AIGateway(provider, FinanceToolRegistry(finance)),
        secrets,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: AssistantPage(
                service: service,
                settings: settings,
                historyRepository: _MemoryAIConversationRepository(),
                onDraft: (_) async => false,
                onOpenSettings: () {},
                onAccountDraft: (draft) async {
                  savedAccount = await showAccountEditor(
                    context,
                    initialDraft: draft,
                  );
                  return savedAccount;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField),
        'Crie cartão Inter limite 3000 fecha 4 vence 10',
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(savedAccount, isNull);
      expect(provider.requests, hasLength(1));
      expect(find.textContaining('400 tokens de entrada'), findsOneWidget);
      await tester.tap(find.text('Revisar cartão'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextFormField, 'Inter'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, '3000,00'), findsOneWidget);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(savedAccount, isNull);
      await tester.tap(find.text('Revisar cartão'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Inter'),
        'Inter Black',
      );
      await tester.enterText(find.widgetWithText(TextFormField, '4'), '32');
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();
      expect(find.text('Informe um dia de 1 a 31.'), findsOneWidget);
      expect(savedAccount, isNull);
      await tester.enterText(find.widgetWithText(TextFormField, '32'), '4');
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();
      expect(savedAccount?.name, 'Inter Black');
      expect(savedAccount?.limit, 3000);
      expect(savedAccount?.closingDay, 4);
      expect(savedAccount?.dueDay, 10);
      expect(find.text('Cadastro salvo'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'O que eu cadastrei?');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(
        provider.requests.last.any(
          (m) =>
              m['role'] == 'assistant' &&
              (m['content'] as String).contains('Inter Black'),
        ),
        isTrue,
      );
    },
  );

  testWidgets(
    'shows every requested tool and renders the final Markdown table',
    (tester) async {
      final provider = _ToolFlowProvider();
      final secrets = _MemorySecretStore()
        ..values[SecretKeys.aiApiKey] = 'test-key';
      final settings = SettingsController(
        _MemorySettingsRepository(),
        secrets,
        provider,
      );
      await settings.initialize();
      final finance = FinanceController(_MemoryFinanceRepository());
      await finance.initialize();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AssistantPage(
              service: AssistantService(
                AIGateway(provider, FinanceToolRegistry(finance)),
                secrets,
              ),
              settings: settings,
              historyRepository: _MemoryAIConversationRepository(),
              onDraft: (_) async => false,
              onAccountDraft: (_) async => null,
              onOpenSettings: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField),
        'Quanto posso gastar guardando R\$ 500 por mês?',
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      for (var i = 0; i < 20 && provider.requests < 2; i++) {
        await tester.pump();
      }

      expect(
        find.text('A IA solicitou 2 ferramentas para coletar dados.'),
        findsOneWidget,
      );
      expect(
        find.text('Calculando o limite de gastos para a meta'),
        findsOneWidget,
      );
      expect(find.text('Atualizando os saldos das contas'), findsOneWidget);

      provider.finish();
      await tester.pumpAndSettle();
      final markdown = tester.widget<MarkdownBody>(find.byType(MarkdownBody));
      expect(markdown.data, contains('**Resumo financeiro**'));
      expect(markdown.data, contains('| Item | Valor |'));
      expect(find.byType(Table), findsOneWidget);
      expect(find.text('Processo da resposta'), findsOneWidget);
    },
  );

  testWidgets('shows a separate review action for every prepared transaction', (
    tester,
  ) async {
    final provider = _RecordingProvider(
      response: const AIProviderResponse(
        content: '',
        toolCalls: [
          AIToolCall(
            id: 'first',
            name: 'prepare_transaction',
            arguments: {
              'name': 'Mercado',
              'amount_cents': 18000,
              'category': 'Alimentação',
              'type': 'expense',
              'account_ref': 'Conta corrente',
              'purchase_date': '2026-09-12',
            },
          ),
          AIToolCall(
            id: 'second',
            name: 'prepare_transaction',
            arguments: {
              'name': 'Combustível',
              'amount_cents': 25000,
              'category': 'Transporte',
              'type': 'expense',
              'account_ref': 'Conta corrente',
              'purchase_date': '2026-09-12',
            },
          ),
        ],
        assistantMessage: {'role': 'assistant', 'content': null},
      ),
    );
    final secrets = _MemorySecretStore()
      ..values[SecretKeys.aiApiKey] = 'test-key';
    final settings = SettingsController(
      _MemorySettingsRepository(),
      secrets,
      provider,
    );
    await settings.initialize();
    final finance = FinanceController(_MemoryFinanceRepository());
    await finance.initialize();
    await finance.addAccount(
      FinanceAccount(
        id: 'checking',
        name: 'Conta corrente',
        kind: 'account',
        openingBalance: 1000,
      ),
    );
    final reviewed = <TransactionDraft>[];
    final history = _MemoryAIConversationRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AssistantPage(
            service: AssistantService(
              AIGateway(provider, FinanceToolRegistry(finance)),
              secrets,
            ),
            settings: settings,
            historyRepository: history,
            onDraft: (draft) async {
              reviewed.add(draft);
              return true;
            },
            onAccountDraft: (_) async => null,
            onOpenSettings: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    const prompt = 'Crie mercado de 180 e combustível de 250';
    await tester.enterText(find.byType(TextField), prompt);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    final first = find.text('Revisar 1: Mercado');
    final second = find.text('Revisar 2: Combustível');
    expect(first, findsOneWidget);
    expect(second, findsOneWidget);
    await tester.ensureVisible(first);
    await tester.tap(first);
    await tester.pump();
    expect(find.text('Lançamento 1 salvo'), findsOneWidget);
    await tester.ensureVisible(second);
    await tester.tap(second);
    await tester.pump();

    expect(reviewed.map((draft) => draft.name), ['Mercado', 'Combustível']);
    expect(find.text('Lançamento 2 salvo'), findsOneWidget);
    final confirmedButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Lançamento 1 salvo'),
    );
    expect(
      confirmedButton.style?.backgroundColor?.resolve({WidgetState.disabled}),
      const Color(0xff4D755F),
    );
    final storedAssistant = history.messages.values.single.last;
    expect(storedAssistant.metadata['drafts'], hasLength(2));
    expect(storedAssistant.metadata['saved_drafts'], [true, true]);

    await tester.tap(find.byTooltip('Nova conversa'));
    await tester.pump();
    await tester.tap(find.byTooltip('Histórico de conversas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(prompt));
    await tester.pumpAndSettle();
    expect(find.text('Lançamento 1 salvo'), findsOneWidget);
    expect(find.text('Lançamento 2 salvo'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Crie outra por 90 reais');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    final followUpSystem = provider.requests.last.first['content'] as String;
    expect(followUpSystem, contains('"account_ref":"Conta corrente"'));
    expect(followUpSystem, contains('"state":"confirmed"'));
  });

  testWidgets('creates a new chat and reopens a previous conversation', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final provider = _RecordingProvider();
    final history = _MemoryAIConversationRepository();
    final secrets = _MemorySecretStore()
      ..values[SecretKeys.aiApiKey] = 'test-key';
    final settings = SettingsController(
      _MemorySettingsRepository(),
      secrets,
      provider,
    );
    await settings.initialize();
    final finance = FinanceController(_MemoryFinanceRepository());
    await finance.initialize();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AssistantPage(
            service: AssistantService(
              AIGateway(provider, FinanceToolRegistry(finance)),
              secrets,
            ),
            settings: settings,
            historyRepository: history,
            onDraft: (_) async => false,
            onAccountDraft: (_) async => null,
            onOpenSettings: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final panel = tester.getRect(
      find.byKey(const Key('assistant-conversation-panel')),
    );
    expect(panel.top, 16);
    expect(panel.bottom, 784);

    const firstPrompt = 'Primeiro papo sobre a fatura';
    await tester.enterText(find.byType(TextField), firstPrompt);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(history.conversations, hasLength(1));
    expect(history.messages.values.single, hasLength(2));

    await tester.tap(find.text('Nova conversa'));
    await tester.pump();
    const secondPrompt = 'Segundo papo sobre orçamento';
    await tester.enterText(find.byType(TextField), secondPrompt);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(history.conversations, hasLength(2));

    await tester.tap(find.text(firstPrompt));
    await tester.pumpAndSettle();
    expect(find.text(firstPrompt), findsNWidgets(2));
    expect(find.text(secondPrompt), findsOneWidget);
  });

  testWidgets('reopens the exact chart snapshot stored with a conversation', (
    tester,
  ) async {
    final generatedAt = DateTime.utc(2026, 9, 12, 14);
    final snapshot = AIChartSnapshot(
      kind: AIChartKind.incomeExpense,
      title: 'Entradas e saídas históricas',
      subtitle: 'Fotografia de setembro',
      generatedAt: generatedAt,
      periodStart: '2026-09',
      periodEnd: '2026-09',
      series: const [
        AIChartSeries(
          label: 'Entradas',
          role: 'income',
          points: [AIChartPoint(label: '2026-09', valueCents: 500000)],
        ),
        AIChartSeries(
          label: 'Saídas',
          role: 'expense',
          points: [AIChartPoint(label: '2026-09', valueCents: 200000)],
        ),
      ],
    );
    final history = _MemoryAIConversationRepository()
      ..conversations.add(
        AIConversation(
          id: 'history',
          title: 'Análise de setembro',
          createdAt: generatedAt,
          updatedAt: generatedAt,
        ),
      )
      ..messages['history'] = [
        AIStoredMessage(
          id: 'answer',
          conversationId: 'history',
          role: 'assistant',
          content: 'Esta é a fotografia calculada naquele momento.',
          createdAt: generatedAt,
          metadata: {
            'charts': [snapshot.toJson()],
          },
        ),
      ];
    final provider = _RecordingProvider();
    final secrets = _MemorySecretStore()
      ..values[SecretKeys.aiApiKey] = 'test-key';
    final settings = SettingsController(
      _MemorySettingsRepository(),
      secrets,
      provider,
    );
    await settings.initialize();
    final finance = FinanceController(_MemoryFinanceRepository());
    await finance.initialize();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AssistantPage(
            service: AssistantService(
              AIGateway(provider, FinanceToolRegistry(finance)),
              secrets,
            ),
            settings: settings,
            historyRepository: history,
            onDraft: (_) async => false,
            onAccountDraft: (_) async => null,
            onOpenSettings: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Entradas e saídas históricas'), findsOneWidget);
    final restored = tester.widget<AIChartCard>(find.byType(AIChartCard));
    expect(restored.snapshot.generatedAt, generatedAt);
    expect(restored.snapshot.series.first.points.single.valueCents, 500000);
    expect(provider.requests, isEmpty);
  });
}

class _RecordingProvider implements AIProvider {
  _RecordingProvider({this.response});
  final AIProviderResponse? response;
  final requests = <List<Map<String, dynamic>>>[];

  @override
  Future<AIProviderResponse> complete({
    required AISettings settings,
    required String apiKey,
    required List<Map<String, dynamic>> messages,
    required List<AIToolDefinition> tools,
  }) async {
    requests.add(messages);
    return response ??
        const AIProviderResponse(
          content: 'Resposta pronta.',
          toolCalls: [],
          assistantMessage: {
            'role': 'assistant',
            'content': 'Resposta pronta.',
          },
        );
  }

  @override
  Future<List<String>> listModels(AISettings settings, String apiKey) async =>
      const [];
}

class _ToolFlowProvider implements AIProvider {
  final _finalResponse = Completer<AIProviderResponse>();
  int requests = 0;

  void finish() => _finalResponse.complete(
    const AIProviderResponse(
      content: '**Resumo financeiro**\n\n| Item | Valor |\n| --- | ---: |\n| Meta mensal | R\$ 500 |',
      toolCalls: [],
      assistantMessage: {
        'role': 'assistant',
        'content': '**Resumo financeiro**\n\n| Item | Valor |\n| --- | ---: |\n| Meta mensal | R\$ 500 |',
      },
    ),
  );

  @override
  Future<AIProviderResponse> complete({
    required AISettings settings,
    required String apiKey,
    required List<Map<String, dynamic>> messages,
    required List<AIToolDefinition> tools,
  }) async {
    requests++;
    if (requests > 1) return _finalResponse.future;
    return const AIProviderResponse(
      content: '',
      toolCalls: [
        AIToolCall(
          id: 'plan',
          name: 'query_finances',
          arguments: {
            'operation': 'savings_plan',
            'savings_target_cents': 50000,
            'monthly_income_cents': 500000,
          },
        ),
        AIToolCall(
          id: 'balance',
          name: 'query_finances',
          arguments: {'operation': 'balance'},
        ),
      ],
      assistantMessage: {'role': 'assistant', 'content': null},
    );
  }

  @override
  Future<List<String>> listModels(AISettings settings, String apiKey) async =>
      const [];
}

class _MemoryAIConversationRepository implements AIConversationRepository {
  final List<AIConversation> conversations = [];
  final Map<String, List<AIStoredMessage>> messages = {};
  var _nextId = 0;

  @override
  Future<AIConversation> createConversation(String title) async {
    final now = DateTime.now();
    final conversation = AIConversation(
      id: 'conversation-${_nextId++}',
      title: title,
      createdAt: now,
      updatedAt: now,
    );
    conversations.insert(0, conversation);
    return conversation;
  }

  @override
  Future<void> addMessage(AIStoredMessage message) async {
    messages.putIfAbsent(message.conversationId, () => []).add(message);
    final index = conversations.indexWhere(
      (conversation) => conversation.id == message.conversationId,
    );
    if (index < 0) return;
    final current = conversations[index];
    conversations[index] = AIConversation(
      id: current.id,
      title: current.title,
      createdAt: current.createdAt,
      updatedAt: message.createdAt,
    );
  }

  @override
  Future<void> updateMessageMetadata(
    String messageId,
    Map<String, dynamic> metadata,
  ) async {
    for (final entries in messages.values) {
      final index = entries.indexWhere((message) => message.id == messageId);
      if (index < 0) continue;
      final current = entries[index];
      entries[index] = AIStoredMessage(
        id: current.id,
        conversationId: current.conversationId,
        role: current.role,
        content: current.content,
        createdAt: current.createdAt,
        metadata: Map<String, dynamic>.from(metadata),
      );
      return;
    }
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    conversations.removeWhere(
      (conversation) => conversation.id == conversationId,
    );
    messages.remove(conversationId);
  }

  @override
  Future<List<AIConversation>> readConversations() async {
    final result = List<AIConversation>.of(conversations)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return result;
  }

  @override
  Future<List<AIStoredMessage>> readMessages(String conversationId) async =>
      List.of(messages[conversationId] ?? const []);
}

class _MemorySettingsRepository implements SettingsRepository {
  AISettings ai = const AISettings();
  SyncSettings sync = const SyncSettings();
  String? name;

  @override
  Future<AISettings> readAISettings() async => ai;

  @override
  Future<String?> readDisplayName() async => name;

  @override
  Future<SyncSettings> readSyncSettings() async => sync;

  @override
  Future<void> saveAISettings(AISettings settings) async => ai = settings;

  @override
  Future<void> saveDisplayName(String name) async => this.name = name;

  @override
  Future<void> saveSyncSettings(SyncSettings settings) async => sync = settings;
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

class _MemoryFinanceRepository implements FinanceRepository {
  List<FinanceAccount> accounts = [];

  @override
  Future<List<FinanceAccount>> readAccounts() async => List.of(accounts);

  @override
  Future<List<FinanceBudget>> readBudgets() async => const [];

  @override
  Future<bool> readDarkTheme() async => false;

  @override
  Future<List<FinanceTransaction>> readTransactions() async => const [];

  @override
  Future<Map<String, DateTime>> readCardInvoiceTrackingStarts() async => {};

  @override
  Future<void> saveAccounts(List<FinanceAccount> items) async =>
      accounts = List.of(items);

  @override
  Future<void> saveBudgets(List<FinanceBudget> items) async {}

  @override
  Future<void> saveCardInvoiceTrackingStart(
    String cardId,
    DateTime month,
  ) async {}

  @override
  Future<void> saveDarkTheme(bool value) async {}

  @override
  Future<void> saveTransactions(List<FinanceTransaction> items) async {}
}
