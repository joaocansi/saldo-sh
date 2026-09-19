import 'dart:convert';

import 'package:flutter_application_1/core/security/secret_store.dart';
import 'package:flutter_application_1/features/ai/application/ai_gateway.dart';
import 'package:flutter_application_1/features/ai/application/assistant_service.dart';
import 'package:flutter_application_1/features/ai/application/finance_tool_registry.dart';
import 'package:flutter_application_1/features/ai/domain/ai_conversation_context.dart';
import 'package:flutter_application_1/features/ai/domain/ai_provider.dart';
import 'package:flutter_application_1/features/finance/application/finance_controller.dart';
import 'package:flutter_application_1/features/finance/domain/models.dart';
import 'package:flutter_application_1/features/finance/domain/repositories/finance_repository.dart';
import 'package:flutter_application_1/features/settings/domain/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sends local context and prepares a card transaction by name', () async {
    final controller = await _controllerWithCard();
    final provider = _ScriptedAIProvider([
      const AIProviderResponse(
        content: '',
        toolCalls: [
          AIToolCall(
            id: 'call-1',
            name: 'prepare_transaction',
            arguments: {
              'name': 'Notebook',
              'amount_cents': 32000,
              'category': 'Compras',
              'type': 'expense',
              'account_ref': 'cartão Nubank',
              'purchase_date': '2026-09-08',
              'installments': 10,
            },
          ),
        ],
        assistantMessage: {
          'role': 'assistant',
          'content': null,
          'tool_calls': [],
        },
      ),
      const AIProviderResponse(
        content: 'Rascunho pronto para revisão.',
        toolCalls: [],
        assistantMessage: {
          'role': 'assistant',
          'content': 'Rascunho pronto para revisão.',
        },
      ),
    ]);
    final gateway = AIGateway(
      provider,
      FinanceToolRegistry(
        controller,
        clock: () => DateTime(2026, 9, 9, 14, 30),
      ),
      null,
      () => DateTime(2026, 9, 9, 14, 30),
    );
    final progress = <AIProgressEvent>[];

    final result = await gateway.ask(
      prompt: 'Comprei um notebook ontem em 10x de 320 no Nubank',
      settings: const AISettings(),
      apiKey: 'test-key',
      history: const [
        AIConversationMessage(role: 'user', content: 'Meu cartão é o Nubank.'),
        AIConversationMessage(
          role: 'assistant',
          content: 'Entendido, vou considerar esse cartão.',
        ),
      ],
      onProgress: progress.add,
    );

    expect(result.draft?.name, 'Notebook');
    expect(result.draft?.accountId, 'nubank-card');
    expect(result.draft?.date, DateTime(2026, 9, 8));
    expect(result.draft?.dueDate, DateTime(2026, 9, 20));
    expect(result.draft?.installmentCount, 10);
    expect(provider.requests, hasLength(1));
    expect(result.requestCount, 1);
    expect(provider.requests.first.first['content'], contains('2026-09-09'));
    expect(provider.requests.first.first['content'], contains('Nubank'));
    expect(
      provider.requests.first.any(
        (message) => message['content'] == 'Meu cartão é o Nubank.',
      ),
      isTrue,
    );
    expect(
      provider.tools.first.map((tool) => tool.name),
      contains('query_finances'),
    );
    expect(progress.map((event) => event.stage), [
      AIProgressStage.planning,
      AIProgressStage.toolsRequested,
      AIProgressStage.toolQueued,
      AIProgressStage.toolRunning,
      AIProgressStage.toolCompleted,
      AIProgressStage.preparingResponse,
    ]);
  });

  test(
    'sends resolved structured memory for a follow-up transaction',
    () async {
      final controller = await _controllerWithCard();
      final provider = _ScriptedAIProvider([
        _answer('Vou preparar a nova compra no mesmo cartão.'),
      ]);

      await AIGateway(provider, FinanceToolRegistry(controller)).ask(
        prompt: 'Crie outra transação de mercado por 80 reais',
        settings: const AISettings(),
        apiKey: 'test',
        conversationContext: AIConversationContext(
          recentTransactions: [
            AITransactionMemory(
              name: 'Notebook',
              amountCents: 32000,
              category: 'Compras',
              type: 'expense',
              accountId: 'nubank-card',
              purchaseDate: DateTime(2026, 9, 8),
              confirmed: true,
            ),
          ],
        ),
      );

      final systemPrompt = provider.requests.single.first['content'] as String;
      expect(systemPrompt, contains('Memória estruturada desta conversa'));
      expect(systemPrompt, contains('"account_ref":"Nubank"'));
      expect(systemPrompt, contains('"account_kind":"card"'));
      expect(systemPrompt, contains('"state":"confirmed"'));
      expect(systemPrompt, contains('não pergunte a conta novamente'));
    },
  );

  test('provider failure is reported without local interpretation', () async {
    final controller = await _controllerWithCard();
    final secrets = _MemorySecretStore()
      ..values[SecretKeys.aiApiKey] = 'secret-key';
    final service = AssistantService(
      AIGateway(_FailingAIProvider(), FinanceToolRegistry(controller)),
      secrets,
    );

    await expectLater(
      service.ask(
        prompt: 'Comprei notebook R\$ 320 no cartão Nubank ontem',
        settings: const AISettings(),
      ),
      throwsA(
        isA<AssistantUnavailableException>().having(
          (error) => error.message,
          'message',
          allOf(
            contains('Não foi possível consultar a IA'),
            contains('Nenhuma alteração foi feita'),
          ),
        ),
      ),
    );
  });

  test('prepares every transaction requested in the same message', () async {
    final controller = await _controllerWithCard();
    final provider = _ScriptedAIProvider([
      const AIProviderResponse(
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
              'account_ref': 'Nubank',
              'purchase_date': '2026-09-09',
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
              'account_ref': 'Nubank',
              'purchase_date': '2026-09-09',
            },
          ),
        ],
        assistantMessage: {'role': 'assistant', 'content': null},
      ),
    ]);

    final result =
        await AIGateway(
          provider,
          FinanceToolRegistry(controller, clock: () => DateTime(2026, 9, 9)),
          null,
          () => DateTime(2026, 9, 9),
        ).ask(
          prompt: 'Crie mercado de 180 e combustível de 250 no Nubank',
          settings: const AISettings(),
          apiKey: 'test-key',
        );

    expect(result.drafts.map((draft) => draft.name), [
      'Mercado',
      'Combustível',
    ]);
    expect(result.message, contains('2 lançamentos'));
    expect(provider.requests, hasLength(1));
  });

  test('invoice payment questions reach the model instead of being blocked as actions', () async {
    final controller = await _controllerWithCard();
    final provider = _ScriptedAIProvider([
      _answer('Vou consultar sua fatura.'),
    ]);
    final secrets = _MemorySecretStore()
      ..values[SecretKeys.aiApiKey] = 'test-key';
    final service = AssistantService(
      AIGateway(provider, FinanceToolRegistry(controller)),
      secrets,
    );
    final result = await service.ask(
      prompt: 'Quanto já paguei da fatura do Nubank?',
      settings: const AISettings(),
    );
    expect(provider.requests, hasLength(1));
    expect(result.draft, isNull);
  });

  test(
    'prepares a card in one request, tracks usage and leaves storage unchanged',
    () async {
      final controller = await _controllerWithCard();
      final provider = _ScriptedAIProvider([
        _toolResponse('prepare_account', {
          'name': 'Inter',
          'kind': 'card',
          'limit_cents': 300000,
          'closing_day': 2,
          'due_day': 9,
        }),
      ]);
      final result = await AIGateway(provider, FinanceToolRegistry(controller))
          .ask(
            prompt: 'Crie um cartão Inter limite 3000 fecha dia 2 vence dia 9',
            settings: const AISettings(),
            apiKey: 'test',
          );
      expect(result.accountDraft?.name, 'Inter');
      expect(result.usage?.inputTokens, 400);
      expect(result.usage?.outputTokens, 60);
      expect(provider.requests, hasLength(1));
      expect(controller.accounts, hasLength(1));
      expect(result.message, contains('confirme para salvar'));
    },
  );

  test(
    'savings query sends local calculation to the model and totals all usage',
    () async {
      final controller = await _controllerWithCard();
      await controller.addAccount(
        FinanceAccount(
          id: 'checking',
          name: 'Conta corrente',
          kind: 'account',
          openingBalance: 2500,
        ),
      );
      final provider = _ScriptedAIProvider([
        _toolBatchResponse([
          (
            'query_finances',
            {
              'operation': 'savings_plan',
              'month': '2026-09',
              'savings_target_cents': 100000,
              'monthly_income_cents': 500000,
            },
          ),
          ('query_finances', {'operation': 'balance'}),
        ]),
        _answer('Seu teto de gastos é R\$ 4.000, com base na renda informada.'),
      ]);
      final progress = <AIProgressEvent>[];
      final result =
          await AIGateway(
            provider,
            FinanceToolRegistry(controller, clock: () => DateTime(2026, 9, 1)),
          ).ask(
            prompt:
                'Ganho 5000 e quero guardar 1000 por mês. Quanto posso gastar?',
            settings: const AISettings(),
            apiKey: 'test',
            onProgress: progress.add,
          );
      final toolResults = provider.requests.last
          .where((message) => message['role'] == 'tool')
          .map((message) => jsonDecode(message['content'] as String))
          .toList();
      expect(
        toolResults.singleWhere(
          (result) => result['spending_ceiling_cents'] != null,
        )['spending_ceiling_cents'],
        400000,
      );
      expect(
        toolResults.singleWhere(
          (result) => result['total_cash_cents'] != null,
        )['total_cash_cents'],
        250000,
      );
      expect(
        progress
            .singleWhere(
              (event) => event.stage == AIProgressStage.toolsRequested,
            )
            .total,
        2,
      );
      expect(
        progress.where((event) => event.stage == AIProgressStage.toolCompleted),
        hasLength(2),
      );
      expect(result.usage?.inputTokens, 800);
      expect(result.usage?.outputTokens, 120);
      expect(result.requestCount, 2);
      expect(result.draft, isNull);
      expect(result.accountDraft, isNull);
    },
  );

  test(
    'reloads local data before every question so balances are current',
    () async {
      final repository = _MemoryFinanceRepository()
        ..accounts = [
          FinanceAccount(
            id: 'checking',
            name: 'Conta corrente',
            kind: 'account',
            openingBalance: 100,
          ),
        ];
      final controller = FinanceController(repository);
      await controller.initialize();
      repository.accounts = [
        FinanceAccount(
          id: 'checking',
          name: 'Conta corrente',
          kind: 'account',
          openingBalance: 987.65,
        ),
      ];
      final provider = _ScriptedAIProvider([
        _toolResponse('query_finances', {'operation': 'balance'}),
        _answer('O saldo atual é R\$ 987,65.'),
      ]);

      await AIGateway(provider, FinanceToolRegistry(controller)).ask(
        prompt: 'Qual é meu saldo atual?',
        settings: const AISettings(),
        apiKey: 'test',
      );

      final result = jsonDecode(
        provider.requests.last.singleWhere(
              (message) => message['role'] == 'tool',
            )['content']
            as String,
      );
      expect(result['total_cash_cents'], 98765);
      expect(result['as_of'], isNotEmpty);
    },
  );

  test(
    'context stays bounded with many accounts and a long conversation',
    () async {
      final controller = await _controllerWithCard();
      for (var i = 0; i < 100; i++) {
        await controller.addAccount(
          FinanceAccount(
            id: 'a$i',
            name: 'Conta $i',
            kind: 'account',
            openingBalance: 123456,
          ),
        );
      }
      final provider = _ScriptedAIProvider([
        _answer('Preciso consultar o mês.'),
      ]);
      await AIGateway(provider, FinanceToolRegistry(controller)).ask(
        prompt: 'E se eu guardar 700?',
        settings: const AISettings(),
        apiKey: 'test',
        history: [
          for (var i = 0; i < 40; i++)
            AIConversationMessage(
              role: i.isEven ? 'user' : 'assistant',
              content: 'Mensagem $i ${'x' * 1900}',
            ),
          const AIConversationMessage(
            role: 'user',
            content: 'Minha renda mensal é 5000.',
          ),
        ],
      );
      final sent = provider.requests.single;
      final recent = sent.skip(1).take(sent.length - 2).toList();
      expect(
        recent.fold<int>(0, (n, m) => n + (m['content'] as String).length),
        lessThanOrEqualTo(6000),
      );
      expect(recent.last['content'], contains('renda mensal é 5000'));
      expect(sent.first['content'], isNot(contains('123456')));
      expect(sent.first['content'], isNot(contains('Conta 99')));
      expect((sent.first['content'] as String).length, lessThan(4000));
      expect(provider.tools.single, hasLength(3));
    },
  );

  test('invalid card arguments are returned for clarification without creating a draft', () async {
    final controller = await _controllerWithCard();
    final provider = _ScriptedAIProvider([
      _toolResponse('prepare_account', {'name': 'Inter', 'kind': 'card'}),
      _answer('Qual o limite, fechamento e vencimento?'),
    ]);
    final result = await AIGateway(provider, FinanceToolRegistry(controller))
        .ask(
          prompt: 'Crie cartão Inter',
          settings: const AISettings(),
          apiKey: 'test',
        );
    expect(result.accountDraft, isNull);
    final error = jsonDecode(provider.requests.last.last['content']);
    expect(error['error']['code'], 'invalid_integer');
    expect(controller.accounts, hasLength(1));
  });

  test(
    'allows a final answer after six tools and rejects a seventh tool',
    () async {
      final controller = await _controllerWithCard();
      final queries = [
        for (var i = 0; i < 6; i++)
          _toolResponse('query_finances', {
            'operation': 'month_summary',
            'month': '2026-0${i + 1}',
          }),
      ];
      final provider = _ScriptedAIProvider([
        ...queries,
        _answer('Resumo pronto'),
      ]);
      await AIGateway(provider, FinanceToolRegistry(controller)).ask(
        prompt: 'Compare os meses',
        settings: const AISettings(),
        apiKey: 'test',
      );
      expect(provider.tools.last, isEmpty);
      final invalid = _ScriptedAIProvider([...queries, queries.first]);
      await expectLater(
        AIGateway(invalid, FinanceToolRegistry(controller)).ask(
          prompt: 'Compare os meses',
          settings: const AISettings(),
          apiKey: 'test',
        ),
        throwsA(isA<AIGatewayException>()),
      );
    },
  );

  test(
    'returns multiple local charts without sending chart metadata to the model',
    () async {
      final controller = await _controllerWithCard();
      final provider = _ScriptedAIProvider([
        _toolBatchResponse([
          (
            'query_finances',
            {
              'operation': 'compare_months',
              'month': '2026-09',
              'months': 2,
              'visualize': true,
            },
          ),
          (
            'query_finances',
            {
              'operation': 'invoices',
              'month': '2026-09',
              'months': 2,
              'visualize': true,
            },
          ),
        ]),
        _answer('Análise pronta.'),
      ]);

      final result =
          await AIGateway(
            provider,
            FinanceToolRegistry(controller, clock: () => DateTime(2026, 9, 12)),
          ).ask(
            prompt: 'Mostre dois gráficos',
            settings: const AISettings(),
            apiKey: 'test',
          );

      expect(result.charts, hasLength(2));
      expect(result.charts.map((chart) => chart.kind.name), [
        'incomeExpense',
        'invoiceEvolution',
      ]);
      final toolMessages = provider.requests.last
          .where((message) => message['role'] == 'tool')
          .toList();
      expect(toolMessages, hasLength(2));
      for (final message in toolMessages) {
        expect(message['content'], isNot(contains('schema_version')));
        expect(message['content'], isNot(contains('"series"')));
        expect(message, isNot(contains('charts')));
      }
    },
  );

  test(
    'missing API key blocks every assistant request without local parsing',
    () async {
      final controller = await _controllerWithCard();
      final service = AssistantService(
        AIGateway(_FailingAIProvider(), FinanceToolRegistry(controller)),
        _MemorySecretStore(),
      );
      for (final prompt in [
        'Crie um cartão de limite 5000',
        'Pretendo guardar 800 todo mês',
        'E se eu guardar 1200?',
      ]) {
        await expectLater(
          service.ask(prompt: prompt, settings: const AISettings()),
          throwsA(
            isA<AssistantUnavailableException>().having(
              (error) => error.message,
              'message',
              contains('Configure um provedor'),
            ),
          ),
        );
      }
    },
  );
}

AIProviderResponse _toolResponse(String name, Map<String, dynamic> args) =>
    AIProviderResponse(
      content: '',
      toolCalls: [AIToolCall(id: 'call', name: name, arguments: args)],
      assistantMessage: {
        'role': 'assistant',
        'content': null,
        'tool_calls': [
          {
            'id': 'call',
            'type': 'function',
            'function': {'name': name, 'arguments': jsonEncode(args)},
          },
        ],
      },
      usage: const AITokenUsage(inputTokens: 400, outputTokens: 60),
    );

AIProviderResponse _toolBatchResponse(
  List<(String, Map<String, dynamic>)> requests,
) => AIProviderResponse(
  content: '',
  toolCalls: [
    for (final (index, request) in requests.indexed)
      AIToolCall(id: 'call-$index', name: request.$1, arguments: request.$2),
  ],
  assistantMessage: {
    'role': 'assistant',
    'content': null,
    'tool_calls': [
      for (final (index, request) in requests.indexed)
        {
          'id': 'call-$index',
          'type': 'function',
          'function': {'name': request.$1, 'arguments': jsonEncode(request.$2)},
        },
    ],
  },
  usage: const AITokenUsage(inputTokens: 400, outputTokens: 60),
);

AIProviderResponse _answer(String text) => AIProviderResponse(
  content: text,
  toolCalls: [],
  assistantMessage: {'role': 'assistant', 'content': text},
  usage: const AITokenUsage(inputTokens: 400, outputTokens: 60),
);

Future<FinanceController> _controllerWithCard() async {
  final controller = FinanceController(_MemoryFinanceRepository());
  await controller.initialize();
  await controller.addAccount(
    FinanceAccount(
      id: 'nubank-card',
      name: 'Nubank',
      kind: 'card',
      openingBalance: 0,
      limit: 5000,
      closingDay: 10,
      dueDay: 20,
    ),
  );
  return controller;
}

class _ScriptedAIProvider implements AIProvider {
  _ScriptedAIProvider(this.responses);

  final List<AIProviderResponse> responses;
  final List<List<Map<String, dynamic>>> requests = [];
  final List<List<AIToolDefinition>> tools = [];
  var _index = 0;

  @override
  Future<AIProviderResponse> complete({
    required AISettings settings,
    required String apiKey,
    required List<Map<String, dynamic>> messages,
    required List<AIToolDefinition> tools,
  }) async {
    requests.add(messages.map(Map<String, dynamic>.from).toList());
    this.tools.add(List.of(tools));
    return responses[_index++];
  }

  @override
  Future<List<String>> listModels(AISettings settings, String apiKey) async =>
      const [];
}

class _FailingAIProvider implements AIProvider {
  @override
  Future<AIProviderResponse> complete({
    required AISettings settings,
    required String apiKey,
    required List<Map<String, dynamic>> messages,
    required List<AIToolDefinition> tools,
  }) => throw StateError('modelo indisponível');

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
  Future<void> write(String key, String value) async => values[key] = value;
}

class _MemoryFinanceRepository implements FinanceRepository {
  List<FinanceTransaction> transactions = [];
  List<FinanceAccount> accounts = [];
  List<FinanceBudget> budgets = [];

  @override
  Future<List<FinanceAccount>> readAccounts() async => List.of(accounts);

  @override
  Future<List<FinanceBudget>> readBudgets() async => List.of(budgets);

  @override
  Future<List<FinanceTransaction>> readTransactions() async =>
      List.of(transactions);

  @override
  Future<Map<String, DateTime>> readCardInvoiceTrackingStarts() async => {};

  @override
  Future<bool> readDarkTheme() async => false;

  @override
  Future<void> saveAccounts(List<FinanceAccount> items) async =>
      accounts = List.of(items);

  @override
  Future<void> saveBudgets(List<FinanceBudget> items) async =>
      budgets = List.of(items);

  @override
  Future<void> saveCardInvoiceTrackingStart(
    String cardId,
    DateTime month,
  ) async {}

  @override
  Future<void> saveDarkTheme(bool value) async {}

  @override
  Future<void> saveTransactions(List<FinanceTransaction> items) async =>
      transactions = List.of(items);
}
