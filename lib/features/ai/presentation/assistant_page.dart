import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../../../app/app_theme.dart';
import '../../finance/application/transaction_builder.dart';
import '../../finance/application/account_draft.dart';
import '../../finance/domain/entities/finance_account.dart';
import '../../settings/application/settings_controller.dart';
import '../application/ai_gateway.dart';
import '../application/assistant_service.dart';
import '../domain/ai_chart.dart';
import '../domain/ai_conversation_context.dart';
import '../domain/ai_provider.dart';
import '../domain/ai_conversation.dart';
import 'widgets/ai_chart_card.dart';

class AssistantPage extends StatefulWidget {
  const AssistantPage({
    super.key,
    required this.service,
    required this.settings,
    required this.onDraft,
    required this.onAccountDraft,
    required this.onOpenSettings,
    required this.historyRepository,
  });

  final AssistantService service;
  final SettingsController settings;
  final Future<bool> Function(TransactionDraft) onDraft;
  final Future<FinanceAccount?> Function(AccountDraft) onAccountDraft;
  final VoidCallback onOpenSettings;
  final AIConversationRepository historyRepository;

  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> {
  static const _uuid = Uuid();
  final _input = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatEntry> _history = [];
  bool _sending = false;
  List<AIProgressEvent> _progress = [];
  List<AIConversation> _conversations = [];
  String? _activeConversationId;
  bool _loadingHistory = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final conversations = await widget.historyRepository.readConversations();
      final active = conversations.firstOrNull;
      final messages = active == null
          ? const <AIStoredMessage>[]
          : await widget.historyRepository.readMessages(active.id);
      if (!mounted) return;
      setState(() {
        _conversations = conversations;
        _activeConversationId = active?.id;
        _history
          ..clear()
          ..addAll(messages.map(_ChatEntry.fromStored));
        _loadingHistory = false;
      });
      _scrollToBottom();
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingHistory = false);
      _showHistoryError('Não foi possível carregar o histórico local.');
    }
  }

  Future<void> _openConversation(AIConversation conversation) async {
    if (_sending || conversation.id == _activeConversationId) return;
    setState(() => _loadingHistory = true);
    try {
      final messages = await widget.historyRepository.readMessages(
        conversation.id,
      );
      if (!mounted) return;
      setState(() {
        _activeConversationId = conversation.id;
        _history
          ..clear()
          ..addAll(messages.map(_ChatEntry.fromStored));
        _progress = [];
        _loadingHistory = false;
      });
      _scrollToBottom();
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingHistory = false);
      _showHistoryError('Não foi possível abrir esta conversa.');
    }
  }

  void _startNewConversation() {
    if (_sending) return;
    setState(() {
      _activeConversationId = null;
      _history.clear();
      _progress = [];
      _input.clear();
    });
  }

  Future<void> _deleteConversation(AIConversation conversation) async {
    if (_sending) return;
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Excluir conversa?'),
            content: Text(
              '“${conversation.title}” será removida somente deste dispositivo.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Excluir'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;
    try {
      await widget.historyRepository.deleteConversation(conversation.id);
      final conversations = await widget.historyRepository.readConversations();
      if (!mounted) return;
      if (_activeConversationId == conversation.id) {
        final next = conversations.firstOrNull;
        final messages = next == null
            ? const <AIStoredMessage>[]
            : await widget.historyRepository.readMessages(next.id);
        if (!mounted) return;
        setState(() {
          _conversations = conversations;
          _activeConversationId = next?.id;
          _history
            ..clear()
            ..addAll(messages.map(_ChatEntry.fromStored));
          _progress = [];
          _input.clear();
        });
      } else {
        setState(() => _conversations = conversations);
      }
    } catch (_) {
      _showHistoryError('Não foi possível excluir a conversa.');
    }
  }

  Future<String> _ensureConversation(String prompt) async {
    if (_activeConversationId case final id?) return id;
    final conversation = await widget.historyRepository.createConversation(
      _conversationTitle(prompt),
    );
    if (mounted) {
      setState(() {
        _activeConversationId = conversation.id;
        _conversations = [conversation, ..._conversations];
      });
    }
    return conversation.id;
  }

  Future<void> _refreshConversationList() async {
    final conversations = await widget.historyRepository.readConversations();
    if (mounted) setState(() => _conversations = conversations);
  }

  String _conversationTitle(String prompt) {
    final title = prompt.trim().replaceAll(RegExp(r'\s+'), ' ');
    return title.length <= 52 ? title : '${title.substring(0, 49)}…';
  }

  void _showHistoryError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  void dispose() {
    _input.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final prompt = _input.text.trim();
    if (prompt.isEmpty || _sending) return;
    final conversation = [
      for (final entry in _history)
        AIConversationMessage(
          role: entry.user ? 'user' : 'assistant',
          content: _conversationContent(entry),
        ),
    ];
    setState(() {
      _history.add(_ChatEntry(prompt, user: true));
      _input.clear();
      _sending = true;
      _progress = [];
    });
    _scrollToBottom();
    String? conversationId;
    AIGatewayResult? result;
    try {
      conversationId = await _ensureConversation(prompt);
      await widget.historyRepository.addMessage(
        AIStoredMessage(
          id: _uuid.v4(),
          conversationId: conversationId,
          role: 'user',
          content: prompt,
          createdAt: DateTime.now(),
        ),
      );
    } catch (_) {
      result = const AIGatewayResult(
        'Não foi possível salvar a conversa localmente. Tente novamente.',
      );
    }
    if (result == null) {
      try {
        result = await widget.service.ask(
          prompt: prompt,
          settings: widget.settings.ai,
          history: conversation,
          conversationContext: _conversationContext(),
          onProgress: (event) {
            if (!mounted) return;
            setState(() {
              final index = event.isTool
                  ? _progress.indexWhere(
                      (item) => item.toolCallId == event.toolCallId,
                    )
                  : -1;
              if (index == -1) {
                _progress = [..._progress, event];
              } else {
                _progress = [..._progress]..[index] = event;
              }
            });
            _scrollToBottom();
          },
        );
      } on AssistantUnavailableException catch (error) {
        result = AIGatewayResult(error.message, progress: List.of(_progress));
      } catch (_) {
        result = AIGatewayResult(
          'Não foi possível consultar a IA. Verifique a configuração e tente '
          'novamente. Nenhuma alteração foi feita.',
          progress: List.of(_progress),
        );
      }
    }
    if (!mounted) return;
    final assistantMessageId = _uuid.v4();
    final assistantEntry = _ChatEntry(
      result.message,
      messageId: assistantMessageId,
      drafts: result.drafts,
      accountDrafts: result.accountDrafts,
      notice: result.notice,
      usage: result.usage,
      requestCount: result.requestCount,
      progress: result.progress.isEmpty ? List.of(_progress) : result.progress,
      charts: result.charts,
    );
    var historyWriteFailed = false;
    if (conversationId != null) {
      try {
        await widget.historyRepository.addMessage(
          AIStoredMessage(
            id: assistantMessageId,
            conversationId: conversationId,
            role: 'assistant',
            content: result.message,
            createdAt: DateTime.now(),
            metadata: assistantEntry.storageMetadata,
          ),
        );
        await _refreshConversationList();
      } catch (_) {
        historyWriteFailed = true;
      }
    }
    if (!mounted) return;
    setState(() {
      _history.add(assistantEntry);
      _sending = false;
      _progress = [];
    });
    _scrollToBottom();
    if (historyWriteFailed) {
      _showHistoryError('A resposta não pôde ser adicionada ao histórico.');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  String _conversationContent(_ChatEntry entry) {
    final text = entry.text.length > 1000
        ? '${entry.text.substring(0, 1000)}…'
        : entry.text;
    final details = <String>[];
    for (var index = 0; index < entry.accountDrafts.length; index++) {
      final account = entry.accountDrafts[index];
      final saved = entry.savedAccounts[index];
      details.add(
        'Cadastro ${index + 1} ${saved == null ? 'apenas preparado, ainda não salvo' : 'confirmado e salvo com os campos revisados'}: '
        '${jsonEncode(saved?.toJson() ?? account.toJson())}',
      );
    }
    for (var index = 0; index < entry.drafts.length; index++) {
      details.add(_draftConversationSummary(entry.drafts[index], index));
    }
    if (details.isEmpty) return text;
    return '$text\n${details.join('\n')}';
  }

  AIConversationContext _conversationContext() {
    final transactions = <AITransactionMemory>[];
    final accounts = <AIAccountMemory>[];
    for (final entry in _history.reversed) {
      for (var index = entry.drafts.length - 1; index >= 0; index--) {
        final draft = entry.drafts[index];
        transactions.add(
          AITransactionMemory(
            name: draft.name,
            amountCents: (draft.amount * 100).round(),
            category: draft.category,
            type: draft.type,
            accountId: draft.accountId,
            targetAccountId: draft.targetAccountId,
            purchaseDate: draft.date,
            confirmed: entry.savedDrafts[index],
          ),
        );
        if (transactions.length == 3) break;
      }
      for (var index = entry.accountDrafts.length - 1; index >= 0; index--) {
        final draft = entry.accountDrafts[index];
        final saved = entry.savedAccounts[index];
        accounts.add(
          AIAccountMemory(
            name: saved?.name ?? draft.name,
            kind: saved?.kind ?? draft.kind,
            confirmed: saved != null,
            accountId: saved?.id,
          ),
        );
        if (accounts.length == 3) break;
      }
      if (transactions.length >= 3 && accounts.length >= 3) break;
    }
    return AIConversationContext(
      recentTransactions: transactions.take(3).toList(growable: false),
      recentAccounts: accounts.take(3).toList(growable: false),
    );
  }

  String _draftConversationSummary(TransactionDraft draft, int index) {
    final date =
        '${draft.date.year.toString().padLeft(4, '0')}-'
        '${draft.date.month.toString().padLeft(2, '0')}-'
        '${draft.date.day.toString().padLeft(2, '0')}';
    return 'Rascunho ${index + 1}: name=${draft.name}; '
        'amount_cents=${(draft.amount * 100).round()}; '
        'category=${draft.category}; type=${draft.type}; '
        'account_id=${draft.accountId}; purchase_date=$date; '
        'status=${draft.status}; mode=${draft.mode}; '
        'installments=${draft.installmentCount}; '
        'initial_installment=${draft.initialInstallment}; '
        'recurrence=${draft.recurrence}.';
  }

  Future<void> _reviewDraft(_ChatEntry entry, int index) async {
    if (_sending ||
        entry.reviewingDrafts.contains(index) ||
        entry.savedDrafts[index]) {
      return;
    }
    setState(() => entry.reviewingDrafts.add(index));
    var saved = false;
    try {
      saved = await widget.onDraft(entry.drafts[index]);
    } catch (_) {
      _showHistoryError('Não foi possível salvar o lançamento.');
    } finally {
      if (mounted) {
        setState(() {
          entry.reviewingDrafts.remove(index);
          entry.savedDrafts[index] = saved;
        });
      }
    }
    if (saved) await _persistEntryState(entry);
  }

  Future<void> _reviewAccount(_ChatEntry entry, int index) async {
    if (_sending ||
        entry.reviewingAccounts.contains(index) ||
        entry.savedAccounts[index] != null) {
      return;
    }
    setState(() => entry.reviewingAccounts.add(index));
    FinanceAccount? saved;
    try {
      saved = await widget.onAccountDraft(entry.accountDrafts[index]);
    } finally {
      if (mounted) {
        setState(() {
          entry.reviewingAccounts.remove(index);
          entry.savedAccounts[index] = saved;
        });
      }
    }
    if (saved != null) await _persistEntryState(entry);
  }

  Future<void> _persistEntryState(_ChatEntry entry) async {
    if (entry.messageId case final messageId?) {
      try {
        await widget.historyRepository.updateMessageMetadata(
          messageId,
          entry.storageMetadata,
        );
      } catch (_) {
        _showHistoryError(
          'O item foi salvo, mas o contexto da conversa não pôde ser atualizado.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final chat = _buildChat();
      if (constraints.maxWidth >= 820) {
        return Row(
          children: [
            _buildDesktopHistory(),
            Expanded(child: chat),
          ],
        );
      }
      return Column(
        children: [
          _buildMobileHeader(),
          Expanded(child: chat),
        ],
      );
    },
  );

  Widget _buildDesktopHistory() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
    child: Container(
      key: const Key('assistant-conversation-panel'),
      width: 270,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Text(
              'Conversas',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: FilledButton.tonalIcon(
              onPressed: _sending ? null : _startNewConversation,
              icon: const Icon(Icons.add_comment_outlined),
              label: const Text('Nova conversa'),
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          Expanded(child: _buildHistoryList()),
        ],
      ),
    ),
  );

  Widget _buildMobileHeader() => Container(
    padding: const EdgeInsets.fromLTRB(16, 8, 10, 8),
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            _activeConversation?.title ?? 'Nova conversa',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        IconButton(
          tooltip: 'Histórico de conversas',
          onPressed: _sending ? null : _openHistorySheet,
          icon: const Icon(Icons.history_rounded),
        ),
        IconButton(
          tooltip: 'Nova conversa',
          onPressed: _sending ? null : _startNewConversation,
          icon: const Icon(Icons.add_comment_outlined),
        ),
      ],
    ),
  );

  Widget _buildHistoryList({BuildContext? sheetContext}) {
    if (_loadingHistory) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_conversations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Text(
            'Suas conversas aparecerão aqui.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _conversations.length,
      itemBuilder: (context, index) {
        final conversation = _conversations[index];
        return _ConversationTile(
          conversation: conversation,
          selected: conversation.id == _activeConversationId,
          enabled: !_sending,
          onOpen: () {
            if (sheetContext != null) Navigator.pop(sheetContext);
            _openConversation(conversation);
          },
          onDelete: () {
            if (sheetContext != null) Navigator.pop(sheetContext);
            _deleteConversation(conversation);
          },
        );
      },
    );
  }

  Future<void> _openHistorySheet() async {
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (sheetContext) => FractionallySizedBox(
        heightFactor: 0.72,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Histórico de conversas',
                      style: Theme.of(sheetContext).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Fechar',
                    onPressed: () => Navigator.pop(sheetContext),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FilledButton.tonalIcon(
                onPressed: () {
                  Navigator.pop(sheetContext);
                  _startNewConversation();
                },
                icon: const Icon(Icons.add_comment_outlined),
                label: const Text('Nova conversa'),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(child: _buildHistoryList(sheetContext: sheetContext)),
          ],
        ),
      ),
    );
  }

  AIConversation? get _activeConversation => _conversations
      .where((conversation) => conversation.id == _activeConversationId)
      .firstOrNull;

  Widget _buildChat() => Column(
    children: [
      if (!widget.settings.hasAIKey)
        MaterialBanner(
          content: const Text(
            'IA não configurada. Configure um modelo e uma API key para usar '
            'o Assistente.',
          ),
          actions: [
            TextButton(
              onPressed: widget.onOpenSettings,
              child: const Text('Configurar'),
            ),
          ],
        ),
      Expanded(
        child: _loadingHistory
            ? const Center(child: CircularProgressIndicator())
            : _history.isEmpty
            ? _AssistantEmptyState(
                onSuggestion: (text) {
                  _input.text = text;
                  _input.selection = TextSelection.collapsed(
                    offset: text.length,
                  );
                },
              )
            : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                itemCount: _history.length + (_sending ? 1 : 0),
                itemBuilder: (_, index) {
                  if (index == _history.length) {
                    return _ProgressBubble(
                      events: _progress,
                      model: widget.settings.ai.model,
                    );
                  }
                  return _MessageBubble(
                    entry: _history[index],
                    onDraft: (draftIndex) =>
                        _reviewDraft(_history[index], draftIndex),
                    onAccountDraft: (draftIndex) =>
                        _reviewAccount(_history[index], draftIndex),
                    busy: _sending,
                  );
                },
              ),
      ),
      SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
          child: Row(
            children: [
              Expanded(
                child: CallbackShortcuts(
                  bindings: {
                    const SingleActivator(LogicalKeyboardKey.enter): _send,
                    const SingleActivator(LogicalKeyboardKey.numpadEnter):
                        _send,
                  },
                  child: TextField(
                    controller: _input,
                    enabled: !_loadingHistory,
                    minLines: 1,
                    maxLines: 4,
                    maxLength: 4000,
                    textInputAction:
                        defaultTargetPlatform == TargetPlatform.android
                        ? TextInputAction.send
                        : TextInputAction.newline,
                    onSubmitted: (_) => _send(),
                    decoration: const InputDecoration(
                      hintText: 'Converse sobre gastos, metas ou cadastros…',
                      counterText: '',
                      prefixIcon: Icon(Icons.auto_awesome_rounded),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _sending || _loadingHistory ? null : _send,
                icon: _sending
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.conversation,
    required this.selected,
    required this.enabled,
    required this.onOpen,
    required this.onDelete,
  });

  final AIConversation conversation;
  final bool selected;
  final bool enabled;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Material(
      type: MaterialType.transparency,
      child: ListTile(
        selected: selected,
        enabled: enabled,
        selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: const Icon(Icons.chat_bubble_outline_rounded, size: 19),
        title: Text(
          conversation.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          _formatConversationDate(conversation.updatedAt),
          style: const TextStyle(fontSize: 11),
        ),
        trailing: IconButton(
          tooltip: 'Excluir conversa',
          onPressed: enabled ? onDelete : null,
          icon: const Icon(Icons.delete_outline_rounded, size: 18),
        ),
        onTap: enabled ? onOpen : null,
      ),
    ),
  );
}

String _formatConversationDate(DateTime date) {
  final local = date.toLocal();
  final now = DateTime.now();
  final time =
      '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';
  if (local.year == now.year &&
      local.month == now.month &&
      local.day == now.day) {
    return 'Hoje, $time';
  }
  return '${local.day.toString().padLeft(2, '0')}/'
      '${local.month.toString().padLeft(2, '0')}/${local.year} · $time';
}

class _ProgressBubble extends StatelessWidget {
  const _ProgressBubble({required this.events, required this.model});

  final List<AIProgressEvent> events;
  final String model;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Container(
      constraints: const BoxConstraints(maxWidth: 680),
      margin: const EdgeInsets.only(bottom: 10),
      child: _ExecutionPanel(events: events, model: model, live: true),
    ),
  );
}

class _ExecutionPanel extends StatelessWidget {
  const _ExecutionPanel({
    required this.events,
    required this.model,
    required this.live,
  });

  final List<AIProgressEvent> events;
  final String model;
  final bool live;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final tools = <AIProgressEvent>[];
    for (final event in events.where((event) => event.isTool)) {
      final index = tools.indexWhere(
        (item) => item.toolCallId == event.toolCallId,
      );
      if (index == -1) {
        tools.add(event);
      } else {
        tools[index] = event;
      }
    }
    final planning = events.where(
      (event) => event.stage == AIProgressStage.planning,
    );
    final preparing = events.where(
      (event) => event.stage == AIProgressStage.preparingResponse,
    );
    final hasAdvancedPastPlanning = tools.isNotEmpty || preparing.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: live
            ? colors.surfaceContainerHigh
            : colors.surfaceContainer.withValues(alpha: 0.72),
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                live ? Icons.auto_awesome_rounded : Icons.fact_check_outlined,
                size: 17,
                color: colors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  live ? 'Processando com $model' : 'Processo da resposta',
                  style: Theme.of(context).textTheme.labelLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              if (live)
                const SizedBox.square(
                  dimension: 15,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 9),
          if (events.isEmpty)
            _ProgressRow(
              message: 'Enviando a pergunta para o modelo…',
              state: _ProgressRowState.running,
            )
          else ...[
            if (planning.isNotEmpty)
              _ProgressRow(
                message: planning.last.message,
                state: live && !hasAdvancedPastPlanning
                    ? _ProgressRowState.running
                    : _ProgressRowState.completed,
              ),
            if (tools.isNotEmpty) ...[
              const SizedBox(height: 5),
              Text(
                tools.length == 1
                    ? 'A IA solicitou 1 ferramenta para coletar dados.'
                    : 'A IA solicitou ${tools.length} ferramentas para coletar dados.',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              for (final tool in tools)
                _ProgressRow(
                  message: tool.message,
                  state: switch (tool.stage) {
                    AIProgressStage.toolQueued => _ProgressRowState.queued,
                    AIProgressStage.toolRunning => _ProgressRowState.running,
                    AIProgressStage.toolFailed => _ProgressRowState.failed,
                    _ => _ProgressRowState.completed,
                  },
                ),
            ],
            if (preparing.isNotEmpty) ...[
              const SizedBox(height: 3),
              _ProgressRow(
                message: preparing.last.message,
                state: live
                    ? _ProgressRowState.running
                    : _ProgressRowState.completed,
              ),
            ],
          ],
        ],
      ),
    );
  }
}

enum _ProgressRowState { queued, running, completed, failed }

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({required this.message, required this.state});

  final String message;
  final _ProgressRowState state;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = state == _ProgressRowState.failed
        ? colors.error
        : state == _ProgressRowState.queued
        ? colors.onSurfaceVariant
        : colors.primary;
    final icon = switch (state) {
      _ProgressRowState.queued => const Icon(Icons.schedule_rounded, size: 15),
      _ProgressRowState.running => const SizedBox.square(
        dimension: 13,
        child: CircularProgressIndicator(strokeWidth: 1.8),
      ),
      _ProgressRowState.completed => const Icon(
        Icons.check_circle_outline_rounded,
        size: 15,
      ),
      _ProgressRowState.failed => const Icon(Icons.error_outline, size: 15),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: IconTheme(
              data: IconThemeData(color: color),
              child: icon,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: state == _ProgressRowState.failed
                    ? colors.error
                    : colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatEntry {
  _ChatEntry(
    this.text, {
    this.messageId,
    this.user = false,
    this.drafts = const [],
    this.accountDrafts = const [],
    this.notice,
    this.usage,
    this.requestCount = 0,
    this.progress = const [],
    this.charts = const [],
    List<bool>? savedDraftState,
    List<FinanceAccount?>? savedAccountState,
  }) : savedDrafts = savedDraftState?.length == drafts.length
           ? List.of(savedDraftState!)
           : List.filled(drafts.length, false),
       savedAccounts = savedAccountState?.length == accountDrafts.length
           ? List.of(savedAccountState!)
           : List.filled(accountDrafts.length, null);

  factory _ChatEntry.fromStored(AIStoredMessage message) {
    final metadata = message.metadata;
    final usageJson = metadata['usage'];
    final storedNotice = metadata['notice'] as String?;
    final hadPendingDraft = metadata['had_pending_draft'] == true;
    final draftNotice = hadPendingDraft
        ? 'O rascunho original não é reaberto pelo histórico. Peça à IA para prepará-lo novamente.'
        : null;
    final progressJson = metadata['progress'];
    final chartsJson = metadata['charts'];
    final draftsJson = metadata['drafts'];
    final accountDraftsJson = metadata['account_drafts'];
    final drafts = draftsJson is List
        ? draftsJson
              .map(TransactionDraft.tryFromJson)
              .whereType<TransactionDraft>()
              .toList(growable: false)
        : const <TransactionDraft>[];
    final accountDrafts = accountDraftsJson is List
        ? accountDraftsJson
              .map(AccountDraft.tryFromJson)
              .whereType<AccountDraft>()
              .toList(growable: false)
        : const <AccountDraft>[];
    final savedDraftsJson = metadata['saved_drafts'];
    final savedAccountsJson = metadata['saved_accounts'];
    final notices = [
      if (storedNotice != null && storedNotice.isNotEmpty) storedNotice,
      ?draftNotice,
    ];
    return _ChatEntry(
      message.content,
      messageId: message.id,
      user: message.role == 'user',
      drafts: drafts,
      accountDrafts: accountDrafts,
      notice: notices.isEmpty ? null : notices.join(' '),
      usage: usageJson is Map
          ? AITokenUsage(
              inputTokens: (usageJson['input_tokens'] as num?)?.toInt() ?? 0,
              outputTokens: (usageJson['output_tokens'] as num?)?.toInt() ?? 0,
            )
          : null,
      requestCount: (metadata['request_count'] as num?)?.toInt() ?? 0,
      progress: progressJson is List
          ? progressJson
                .map(AIProgressEvent.tryFromJson)
                .whereType<AIProgressEvent>()
                .toList()
          : const [],
      charts: chartsJson is List
          ? chartsJson
                .map(AIChartSnapshot.tryFromJson)
                .whereType<AIChartSnapshot>()
                .toList(growable: false)
          : const [],
      savedDraftState: savedDraftsJson is List
          ? savedDraftsJson.map((value) => value == true).toList()
          : null,
      savedAccountState: savedAccountsJson is List
          ? savedAccountsJson
                .map(
                  (value) => value is Map
                      ? FinanceAccount.fromJson(
                          Map<String, dynamic>.from(value),
                        )
                      : null,
                )
                .toList()
          : null,
    );
  }

  final String text;
  final String? messageId;
  final bool user;
  final List<TransactionDraft> drafts;
  final List<AccountDraft> accountDrafts;
  final String? notice;
  final AITokenUsage? usage;
  final int requestCount;
  final List<AIProgressEvent> progress;
  final List<AIChartSnapshot> charts;
  final List<bool> savedDrafts;
  final Set<int> reviewingDrafts = {};
  final List<FinanceAccount?> savedAccounts;
  final Set<int> reviewingAccounts = {};

  Map<String, dynamic> get storageMetadata => {
    if (notice != null && notice!.isNotEmpty) 'notice': notice,
    if (usage case final value?)
      'usage': {
        'input_tokens': value.inputTokens,
        'output_tokens': value.outputTokens,
      },
    if (requestCount > 0) 'request_count': requestCount,
    if (progress.isNotEmpty)
      'progress': progress.map((event) => event.toJson()).toList(),
    if (charts.isNotEmpty)
      'charts': charts.map((chart) => chart.toJson()).toList(),
    if (drafts.isNotEmpty) ...{
      'drafts': drafts.map((draft) => draft.toJson()).toList(),
      'saved_drafts': savedDrafts,
    },
    if (accountDrafts.isNotEmpty) ...{
      'account_drafts': accountDrafts.map((draft) => draft.toJson()).toList(),
      'saved_accounts': savedAccounts
          .map((account) => account?.toJson())
          .toList(),
    },
    if (drafts.isNotEmpty || accountDrafts.isNotEmpty)
      'had_pending_draft':
          savedDrafts.any((saved) => !saved) ||
          savedAccounts.any((saved) => saved == null),
  };
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.entry,
    required this.onDraft,
    required this.onAccountDraft,
    required this.busy,
  });
  final _ChatEntry entry;
  final ValueChanged<int> onDraft;
  final ValueChanged<int> onAccountDraft;
  final bool busy;

  @override
  Widget build(BuildContext context) => Align(
    alignment: entry.user ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      constraints: const BoxConstraints(maxWidth: 680),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: entry.user
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!entry.user && entry.progress.isNotEmpty) ...[
            _ExecutionPanel(events: entry.progress, model: '', live: false),
            const SizedBox(height: 12),
          ],
          if (entry.notice case final notice?) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 18,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    notice,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
          ],
          if (entry.user)
            SelectableText(entry.text)
          else
            MarkdownBody(
              data: entry.text,
              selectable: true,
              softLineBreak: true,
              fitContent: false,
              styleSheet: _markdownStyle(context),
            ),
          if (!entry.user && entry.charts.isNotEmpty)
            for (final chart in entry.charts) AIChartCard(snapshot: chart),
          if (entry.drafts.isNotEmpty) ...[
            const SizedBox(height: 10),
            for (var index = 0; index < entry.drafts.length; index++)
              Padding(
                padding: EdgeInsets.only(
                  bottom: index < entry.drafts.length - 1 ? 7 : 0,
                ),
                child: FilledButton.tonalIcon(
                  style: _confirmedStyle(context, entry.savedDrafts[index]),
                  onPressed:
                      busy ||
                          entry.reviewingDrafts.contains(index) ||
                          entry.savedDrafts[index]
                      ? null
                      : () => onDraft(index),
                  icon: Icon(
                    entry.savedDrafts[index]
                        ? Icons.check_rounded
                        : Icons.edit_note_rounded,
                  ),
                  label: Text(
                    entry.savedDrafts[index]
                        ? entry.drafts.length == 1
                              ? 'Lançamento salvo'
                              : 'Lançamento ${index + 1} salvo'
                        : entry.drafts.length == 1
                        ? 'Revisar rascunho'
                        : 'Revisar ${index + 1}: ${entry.drafts[index].name}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
          ],
          if (entry.accountDrafts.isNotEmpty) ...[
            const SizedBox(height: 10),
            for (var index = 0; index < entry.accountDrafts.length; index++)
              Padding(
                padding: EdgeInsets.only(
                  bottom: index < entry.accountDrafts.length - 1 ? 7 : 0,
                ),
                child: FilledButton.tonalIcon(
                  style: _confirmedStyle(
                    context,
                    entry.savedAccounts[index] != null,
                  ),
                  onPressed:
                      busy ||
                          entry.reviewingAccounts.contains(index) ||
                          entry.savedAccounts[index] != null
                      ? null
                      : () => onAccountDraft(index),
                  icon: Icon(
                    entry.savedAccounts[index] != null
                        ? Icons.check_rounded
                        : Icons.credit_card_rounded,
                  ),
                  label: Text(
                    entry.savedAccounts[index] != null
                        ? entry.accountDrafts.length == 1
                              ? 'Cadastro salvo'
                              : 'Cadastro ${index + 1} salvo'
                        : entry.accountDrafts.length == 1
                        ? entry.accountDrafts[index].kind == 'card'
                              ? 'Revisar cartão'
                              : 'Revisar conta'
                        : 'Revisar ${index + 1}: ${entry.accountDrafts[index].name}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
          ],
          if (entry.usage case final usage?) ...[
            const SizedBox(height: 8),
            Text(
              '${usage.inputTokens} tokens de entrada · ${usage.outputTokens} de saída · ${entry.requestCount} chamada(s)',
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    ),
  );

  ButtonStyle? _confirmedStyle(BuildContext context, bool confirmed) {
    if (!confirmed) return null;
    final color =
        Theme.of(context).extension<FinanceColors>()?.income ??
        const Color(0xff4D755F);
    final foreground =
        ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : const Color(0xff171B20);
    return FilledButton.styleFrom(
      backgroundColor: color,
      foregroundColor: foreground,
      disabledBackgroundColor: color,
      disabledForegroundColor: foreground,
    );
  }

  MarkdownStyleSheet _markdownStyle(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final base = MarkdownStyleSheet.fromTheme(theme);
    return base.copyWith(
      p: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
      h1: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      h2: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
      h3: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800),
      strong: const TextStyle(fontWeight: FontWeight.w800),
      blockSpacing: 10,
      tableColumnWidth: const IntrinsicColumnWidth(),
      tableScrollbarThumbVisibility: true,
      tableBorder: TableBorder.all(color: colors.outlineVariant),
      tableCellsPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),
      tableHeadCellsDecoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
      ),
      codeblockPadding: const EdgeInsets.all(12),
      codeblockDecoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      blockquotePadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      blockquoteDecoration: BoxDecoration(
        color: colors.surfaceContainer,
        border: Border(left: BorderSide(color: colors.primary, width: 3)),
      ),
    );
  }
}

class _AssistantEmptyState extends StatelessWidget {
  const _AssistantEmptyState({required this.onSuggestion});
  final ValueChanged<String> onSuggestion;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome_rounded, size: 54),
            const SizedBox(height: 14),
            const Text(
              'Assistente financeiro',
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Planeje quanto guardar, entenda seus gastos e acompanhe faturas. '
              'Contas, cartões e lançamentos passam pela sua confirmação.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                for (final suggestion in const [
                  'Quanto posso gastar se guardar R\$ 500 neste mês?',
                  'Compare meus gastos dos últimos 3 meses.',
                  'Quais faturas ainda estão em aberto?',
                  'Quero cadastrar um cartão de crédito.',
                ])
                  ActionChip(
                    label: Text(suggestion, softWrap: true),
                    onPressed: () => onSuggestion(suggestion),
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
