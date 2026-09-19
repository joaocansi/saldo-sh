import 'package:flutter/material.dart';

import '../../../app/app_dependencies.dart';
import '../../../core/presentation/widgets/saldo_mark.dart';
import '../../ai/application/ai_gateway.dart';
import '../../ai/application/assistant_service.dart';
import '../../ai/application/finance_tool_registry.dart';
import '../../ai/presentation/assistant_page.dart';
import '../../settings/application/settings_controller.dart';
import '../../settings/presentation/settings_page.dart';
import '../../sync/application/drive_sync_controller.dart';
import '../../sync/domain/sync_models.dart';
import '../application/finance_controller.dart';
import '../application/account_draft.dart';
import '../application/transaction_builder.dart';
import '../domain/models.dart';
import 'pages/accounts_page.dart';
import 'pages/budgets_page.dart';
import 'pages/card_account_details_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/reports_page.dart';
import 'pages/transactions_page.dart';
import 'widgets/navigation.dart';
import 'widgets/invoice_payment_sheet.dart';
import 'widgets/transaction_editor.dart';
import 'widgets/account_editor.dart';

class FinanceShell extends StatefulWidget {
  const FinanceShell({
    super.key,
    required this.dark,
    required this.displayName,
    required this.onTheme,
    required this.onSyncedTheme,
    required this.onFactoryReset,
    required this.dependencies,
  });

  final bool dark;
  final String displayName;
  final VoidCallback onTheme;
  final ValueChanged<bool> onSyncedTheme;
  final VoidCallback onFactoryReset;
  final AppDependencies dependencies;

  @override
  State<FinanceShell> createState() => _FinanceShellState();
}

class _FinanceShellState extends State<FinanceShell>
    with WidgetsBindingObserver {
  late final FinanceController _controller;
  late final SettingsController _settings;
  late final DriveSyncController _sync;
  late final AssistantService _assistant;
  late final AssistantPage _assistantPage;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = FinanceController(widget.dependencies.financeRepository)
      ..addListener(_onChanged);
    _settings = SettingsController(
      widget.dependencies.settingsRepository,
      widget.dependencies.secretStore,
      widget.dependencies.aiProvider,
    )..addListener(_onChanged);
    _sync = widget.dependencies.createSyncController(
      _controller,
      onRemoteDataChanged: _reloadAfterSync,
    )..addListener(_onChanged);
    _assistant = AssistantService(
      AIGateway(
        widget.dependencies.aiProvider,
        FinanceToolRegistry(_controller),
        widget.dependencies.aiToolAudit,
      ),
      widget.dependencies.secretStore,
    );
    _assistantPage = AssistantPage(
      service: _assistant,
      settings: _settings,
      historyRepository: widget.dependencies.aiConversationRepository,
      onDraft: (draft) => _openTransaction(null, draft),
      onAccountDraft: _openAccountDraft,
      onOpenSettings: () => _selectPage(6),
    );
    _initialize();
  }

  Future<void> _initialize() async {
    await Future.wait([_controller.initialize(), _settings.initialize()]);
    await _sync.initialize();
  }

  Future<void> _reloadAfterSync() async {
    await Future.wait([_controller.reload(), _settings.reload()]);
    final remoteDark = await widget.dependencies.financeRepository
        .readDarkTheme();
    if (remoteDark != widget.dark) widget.onSyncedTheme(remoteDark);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller
      ..removeListener(_onChanged)
      ..dispose();
    _settings
      ..removeListener(_onChanged)
      ..dispose();
    _sync
      ..removeListener(_onChanged)
      ..dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _sync.onResumed();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      _sync.onPaused();
    }
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  void _selectPage(int page) => setState(() => _page = page);

  int get _mobileNavigationIndex => switch (_page) {
    0 => 0,
    1 => 1,
    2 => 2,
    5 => 3,
    _ => 4,
  };

  Future<void> _onMobileDestination(int index) async {
    if (index < 3) {
      _selectPage(index);
      return;
    }
    if (index == 3) {
      _selectPage(5);
      return;
    }
    final selected = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.pie_chart_rounded),
              title: const Text('Or\u00e7amento'),
              selected: _page == 3,
              onTap: () => Navigator.pop(context, 3),
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart_rounded),
              title: const Text('Relat\u00f3rios'),
              selected: _page == 4,
              onTap: () => Navigator.pop(context, 4),
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Configura\u00e7\u00f5es'),
              selected: _page == 6,
              onTap: () => Navigator.pop(context, 6),
            ),
          ],
        ),
      ),
    );
    if (selected != null && mounted) _selectPage(selected);
  }

  Future<bool> _openTransaction([
    FinanceTransaction? editing,
    TransactionDraft? initialDraft,
  ]) async {
    if (!_allowMutation()) return false;
    if (editing?.isCardPayment == true) {
      final card = _controller.accounts
          .where((account) => account.id == editing!.targetAccountId)
          .firstOrNull;
      if (card == null) {
        _showFinanceError(
          'O cart\u00e3o associado ao pagamento n\u00e3o foi encontrado.',
        );
        return false;
      }
      await _openInvoicePayment(
        _controller.invoiceSummary(card, editing!.dueDate),
        editing: editing,
      );
      return false;
    }
    if (editing == null && _controller.accounts.isEmpty) {
      _selectPage(2);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Crie uma conta ou cartão antes do primeiro lançamento.',
          ),
        ),
      );
      return false;
    }
    final result = await showModalBottomSheet<TransactionSaveResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TransactionEditor(
        accounts: _controller.accounts,
        editing: editing,
        initialDraft: initialDraft,
      ),
    );
    if (result == null || result.items.isEmpty) return false;
    var applyToFuture = false;
    if (editing != null && (editing.isInstallment || editing.isRecurring)) {
      final scope = await _askTransactionEditScope(editing);
      if (scope == null) return false;
      applyToFuture = scope;
    }
    try {
      await _controller.saveTransaction(
        items: result.items,
        draft: result.draft,
        editing: editing,
        applyToFuture: applyToFuture,
      );
    } on InvoicePaymentException catch (error) {
      _showFinanceError(error.message);
      return false;
    }
    _sync.markLocalChange();
    if (!mounted) return true;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lançamento salvo localmente.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return true;
  }

  Future<void> _deleteTransaction(
    FinanceTransaction transaction,
    bool futureGroup,
  ) async {
    if (!_allowMutation()) return;
    if (transaction.isCardPayment) {
      await _deleteInvoicePayment(transaction);
      return;
    }
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              futureGroup
                  ? 'Excluir esta e as próximas?'
                  : 'Excluir transação?',
            ),
            content: Text(
              futureGroup
                  ? '“${transaction.name}” e todas as ocorrências posteriores desta série serão excluídas. Esta ação não pode ser desfeita.'
                  : '“${transaction.name}” será excluída somente desta data. Esta ação não pode ser desfeita.',
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
      await _controller.deleteTransaction(
        transaction,
        futureGroup: futureGroup,
      );
    } on InvoicePaymentException catch (error) {
      _showFinanceError(error.message);
      return;
    }
    _sync.markLocalChange();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            futureGroup
                ? 'Esta ocorrência e as próximas foram excluídas.'
                : 'Transação excluída.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<bool?> _askTransactionEditScope(FinanceTransaction transaction) =>
      showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Aplicar alteração'),
          content: Text(
            transaction.isInstallment
                ? 'Esta transação faz parte de um parcelamento. Onde deseja aplicar as alterações?'
                : 'Esta transação faz parte de uma recorrência. Onde deseja aplicar as alterações?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Somente esta'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Esta e as próximas'),
            ),
          ],
        ),
      );

  Future<void> _openInvoicePayment(
    CardInvoiceSummary summary, {
    FinanceTransaction? editing,
  }) async {
    if (!_allowMutation()) return;
    final result = await showModalBottomSheet<InvoicePaymentSaveResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => InvoicePaymentSheet(
        summary: summary,
        accounts: _controller.accounts,
        editing: editing,
        validate: (draft) =>
            _controller.validateInvoicePayment(draft, editing: editing),
      ),
    );
    if (result == null) return;
    try {
      await _controller.saveInvoicePayment(
        result.draft,
        editing: editing,
        negativeBalanceConfirmed: result.negativeBalanceConfirmed,
      );
    } on InvoicePaymentException catch (error) {
      _showFinanceError(error.message);
      return;
    }
    _sync.markLocalChange();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          editing == null
              ? 'Pagamento registrado localmente.'
              : 'Pagamento atualizado localmente.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _deleteInvoicePayment(FinanceTransaction payment) async {
    if (!_allowMutation()) return;
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Estornar pagamento?'),
            content: Text(
              'O valor de ${money(payment.amount)} voltar\u00e1 para a conta de '
              'origem e a fatura ser\u00e1 reaberta.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Estornar'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;
    await _controller.deleteInvoicePayment(payment);
    _sync.markLocalChange();
  }

  void _showFinanceError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _deleteAccount(FinanceAccount account) async {
    if (!_allowMutation()) return;
    final linked = _controller.transactionsLinkedTo(account);
    final entity = account.isCard ? 'cartão' : 'conta';
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Excluir $entity?'),
            content: Text(
              linked.isEmpty
                  ? '“${account.name}” será excluído permanentemente.'
                  : '“${account.name}” possui ${linked.length} ${linked.length == 1 ? 'transação vinculada' : 'transações vinculadas'}. Ao continuar, elas também serão excluídas, incluindo transferências ou pagamentos relacionados. Esta ação não pode ser desfeita.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(linked.isEmpty ? 'Excluir' : 'Excluir tudo'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !mounted) return;
    final deleted = await _controller.deleteAccount(
      account,
      deleteLinkedTransactions: linked.isNotEmpty,
    );
    if (!deleted) return;
    _sync.markLocalChange();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          linked.isEmpty
              ? 'O cadastro “${account.name}” foi excluído.'
              : 'O cadastro “${account.name}” e seus lançamentos foram excluídos.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _markAsPaid(FinanceTransaction transaction) async {
    if (!_allowMutation()) return;
    await _controller.markAsPaid(transaction);
    _sync.markLocalChange();
  }

  Future<void> _addAccount(FinanceAccount account) async {
    if (!_allowMutation()) return;
    await _controller.addAccount(account);
    _sync.markLocalChange();
  }

  Future<FinanceAccount?> _openAccountDraft(AccountDraft draft) async {
    if (!_allowMutation()) return null;
    final account = await showAccountEditor(context, initialDraft: draft);
    if (!mounted || account == null || !_allowMutation()) return null;
    try {
      await _addAccount(account);
      return account;
    } catch (_) {
      if (mounted) {
        _showFinanceError('Não foi possível salvar a conta. Tente novamente.');
      }
      return null;
    }
  }

  Future<void> _saveBudget(FinanceBudget budget) async {
    if (!_allowMutation()) return;
    await _controller.saveBudget(budget);
    _sync.markLocalChange();
  }

  Future<void> _deleteBudget(FinanceBudget budget) async {
    if (!_allowMutation()) return;
    await _controller.deleteBudget(budget);
    _sync.markLocalChange();
  }

  Future<void> _factoryReset() async {
    await widget.dependencies.factoryResetService.execute(_sync);
    widget.onFactoryReset();
  }

  void _toggleTheme() {
    if (!_allowMutation()) return;
    widget.onTheme();
    _sync.markLocalChange();
  }

  bool _allowMutation() {
    if (_sync.status != SyncStatus.resetting) return true;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Aguarde o reset do aplicativo terminar.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 920;
    final loading = _controller.isLoading || _settings.loading;
    return Scaffold(
      body: SafeArea(
        child: loading
            ? const Center(child: SaldoMark(size: 52))
            : Row(
                children: [
                  if (desktop)
                    FinanceSidebar(
                      selected: _page,
                      dark: widget.dark,
                      displayName: widget.displayName,
                      onTheme: _toggleTheme,
                      onSelect: _selectPage,
                    ),
                  Expanded(
                    child: Column(
                      children: [
                        if (!desktop)
                          FinanceTopBar(
                            desktop: false,
                            dark: widget.dark,
                            onTheme: _toggleTheme,
                            onPage: _selectPage,
                          ),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: _sync.syncNow,
                            child: _buildPageHost(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: desktop
          ? null
          : NavigationBar(
              selectedIndex: _mobileNavigationIndex,
              onDestinationSelected: _onMobileDestination,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.grid_view_rounded),
                  label: 'Início',
                ),
                NavigationDestination(
                  icon: Icon(Icons.receipt_long_rounded),
                  label: 'Transações',
                ),
                NavigationDestination(
                  icon: Icon(Icons.credit_card_rounded),
                  label: 'Contas',
                ),
                NavigationDestination(
                  icon: Icon(Icons.auto_awesome_outlined),
                  selectedIcon: Icon(Icons.auto_awesome_rounded),
                  label: 'Assistente',
                ),
                NavigationDestination(
                  icon: Icon(Icons.more_horiz_rounded),
                  label: 'Mais',
                ),
              ],
            ),
      floatingActionButton: loading || _page >= 5
          ? null
          : FloatingActionButton.extended(
              onPressed: _openTransaction,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Registrar'),
            ),
    );
  }

  Widget _buildPageHost() => Stack(
    fit: StackFit.expand,
    children: [
      if (_page != 5) _buildPage(),
      Offstage(
        offstage: _page != 5,
        child: TickerMode(enabled: _page == 5, child: _assistantPage),
      ),
    ],
  );

  Widget _buildPage() => switch (_page) {
    0 => DashboardPage(
      displayName: widget.displayName,
      month: _controller.selectedMonth,
      transactions: _controller.transactionsForMonth(_controller.selectedMonth),
      accounts: _controller.accounts,
      budgets: _controller.budgets,
      cashFlowProjections: _controller.cashFlowProjection(
        _controller.selectedMonth,
      ),
      balanceFor: _controller.accountBalance,
      invoiceSummaryFor: _controller.invoiceSummary,
      availableFor: _controller.cardAvailableLimit,
      onMonth: _controller.selectMonth,
      onTransactions: () => _selectPage(1),
      onAccount: _openAccount,
    ),
    1 => TransactionsPage(
      transactions: _controller.transactions,
      transactionsForMonth: _controller.transactionsForMonth,
      accounts: _controller.accounts,
      onEdit: _openTransaction,
      onDelete: _deleteTransaction,
      onPaid: _markAsPaid,
    ),
    2 => AccountsPage(
      accounts: _controller.accounts,
      balanceFor: _controller.accountBalance,
      invoiceSummaryFor: _controller.invoiceSummary,
      availableFor: _controller.cardAvailableLimit,
      onAdd: _addAccount,
      onDelete: _deleteAccount,
      onOpen: _openAccount,
    ),
    3 => BudgetsPage(
      budgets: _controller.budgets,
      transactions: _controller.transactions,
      onSave: _saveBudget,
      onDelete: _deleteBudget,
    ),
    4 => ReportsPage(transactions: _controller.transactions),
    5 => const SizedBox.shrink(),
    _ => SettingsPage(
      controller: _settings,
      sync: _sync,
      dark: widget.dark,
      onTheme: _toggleTheme,
      onFactoryReset: _factoryReset,
    ),
  };

  void _openAccount(FinanceAccount account) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => account.isCard
            ? CardAccountDetailsPage(
                account: account,
                controller: _controller,
                onEditPurchase: _openTransaction,
                onPay: _openInvoicePayment,
                onDeletePayment: _deleteInvoicePayment,
              )
            : AccountDetailsPage(
                account: account,
                transactions: _controller.transactions,
                transactionsForMonth: _controller.transactionsForMonth,
                invoiceFor: _controller.invoiceTotal,
                balanceFor: _controller.accountBalance,
                onEdit: _openTransaction,
              ),
      ),
    );
  }
}
