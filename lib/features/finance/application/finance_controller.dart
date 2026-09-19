import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../domain/models.dart';
import '../domain/repositories/finance_repository.dart';
import 'financial_planning_service.dart';
import 'recurrence_service.dart';
import 'transaction_builder.dart';

class FinanceController extends ChangeNotifier {
  FinanceController(this._repository, {DateTime Function()? clock, Uuid? uuid})
    : _clock = clock ?? DateTime.now,
      _uuid = uuid ?? const Uuid() {
    _selectedMonth = monthStart(_clock());
  }

  final FinanceRepository _repository;
  final DateTime Function() _clock;
  final Uuid _uuid;
  static const _recurrenceService = RecurrenceService();

  List<FinanceTransaction> _transactions = [];
  List<FinanceRecurrence> _recurrences = [];
  List<FinanceAccount> _accounts = [];
  List<FinanceBudget> _budgets = [];
  Map<String, DateTime> _invoiceTrackingStarts = {};
  bool _isLoading = true;
  late DateTime _selectedMonth;

  List<FinanceTransaction> get transactions =>
      List.unmodifiable(_transactionsWithProjections());
  List<FinanceRecurrence> get recurrences => List.unmodifiable(_recurrences);
  List<FinanceAccount> get accounts => List.unmodifiable(_accounts);
  List<FinanceBudget> get budgets => List.unmodifiable(_budgets);
  bool get isLoading => _isLoading;
  DateTime get selectedMonth => _selectedMonth;

  List<CashFlowProjection> cashFlowProjection(
    DateTime fromMonth, {
    int months = 3,
    FinanceAccount? account,
  }) {
    if (months <= 0) return const [];
    final target = addMonths(monthStart(fromMonth), months - 1);
    final through = DateTime(target.year, target.month + 1, 0);
    final dates = <DateTime>[
      ..._transactions
          .where((item) => account == null || item.accountId == account.id)
          .map((item) => item.dueDate),
      ..._recurrences
          .where(
            (item) => account == null || item.template.accountId == account.id,
          )
          .map((item) => item.template.dueDate),
    ];
    final from = dates.isEmpty
        ? monthStart(fromMonth)
        : dates.reduce((left, right) => left.isBefore(right) ? left : right);
    return const FinancialPlanningService().cashFlowProjection(
      accounts: account == null ? _accounts : [account],
      transactions: transactionsForRange(
        from,
        through,
      ).where((item) => account == null || item.accountId == account.id),
      fromMonth: fromMonth,
      months: months,
    );
  }

  Future<void> initialize() async {
    await reload();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> reload() async {
    final loadedAccounts = await _repository.readAccounts();
    var loadedTransactions = await _repository.readTransactions();
    final loadedBudgets = await _repository.readBudgets();
    final trackingStarts = await _repository.readCardInvoiceTrackingStarts();
    final recurrenceRepository = _recurrenceRepository;
    var loadedRecurrences = recurrenceRepository == null
        ? <FinanceRecurrence>[]
        : await recurrenceRepository.readRecurrences();

    final accountIdsByLegacyName = {
      for (final account in loadedAccounts) account.name: account.id,
    };
    loadedTransactions = loadedTransactions.map((transaction) {
      final accountId =
          accountIdsByLegacyName[transaction.accountId] ??
          transaction.accountId;
      return accountId == transaction.accountId
          ? transaction
          : transaction.copyWith(accountId: accountId);
    }).toList();

    final defaultTrackingStart = monthStart(_clock());
    for (final card in loadedAccounts.where((account) => account.isCard)) {
      if (trackingStarts.containsKey(card.id)) continue;
      trackingStarts[card.id] = defaultTrackingStart;
      await _repository.saveCardInvoiceTrackingStart(
        card.id,
        defaultTrackingStart,
      );
    }

    if (recurrenceRepository != null) {
      final migration = _migrateLegacyRecurrences(
        loadedTransactions,
        loadedRecurrences,
      );
      loadedTransactions = migration.transactions;
      loadedRecurrences = migration.recurrences;
      if (migration.changed) {
        await recurrenceRepository.saveRecurrences(loadedRecurrences);
        await _repository.saveTransactions(loadedTransactions);
      }
      final materialized = _materializeDueOccurrences(
        loadedRecurrences,
        loadedTransactions,
      );
      if (materialized.length != loadedTransactions.length) {
        loadedTransactions = materialized;
        await _repository.saveTransactions(loadedTransactions);
      }
    }

    _accounts = loadedAccounts;
    _transactions = loadedTransactions;
    _recurrences = loadedRecurrences;
    _budgets = loadedBudgets;
    _invoiceTrackingStarts = trackingStarts;
    notifyListeners();
  }

  void selectMonth(DateTime month) {
    _selectedMonth = monthStart(month);
    notifyListeners();
  }

  Future<void> saveTransaction({
    required List<FinanceTransaction> items,
    TransactionDraft? draft,
    FinanceTransaction? editing,
    bool applyToFuture = false,
  }) async {
    if (items.isEmpty) return;
    if (editing == null &&
        draft?.mode == 'recurring' &&
        _recurrenceRepository != null) {
      await _createRecurrence(items.first);
      return;
    }
    if (editing?.isRecurring == true && _recurrenceRepository != null) {
      await _saveRecurringTransaction(
        items.first,
        editing: editing!,
        applyToFuture: applyToFuture,
      );
      return;
    }
    var next = List<FinanceTransaction>.of(_transactions);
    if (editing == null) {
      next.addAll(items);
    } else if (applyToFuture &&
        (editing.seriesId != null || editing.installmentGroupId != null)) {
      final groupId = editing.seriesId ?? editing.installmentGroupId;
      final template = items.first;
      next = next.map((transaction) {
        final sameGroup =
            (transaction.seriesId ?? transaction.installmentGroupId) == groupId;
        if (!sameGroup || transaction.dueDate.isBefore(editing.dueDate)) {
          return transaction;
        }
        return transaction.copyWith(
          name: template.name,
          category: template.category,
          amount: template.amount,
          type: template.type,
          accountId: template.accountId,
          targetAccountId: template.targetAccountId,
          clearTargetAccountId: template.targetAccountId == null,
          status: template.status,
          notes: template.notes,
        );
      }).toList();
    } else {
      next = next
          .map(
            (transaction) =>
                transaction.id == editing.id ? items.first : transaction,
          )
          .toList();
    }
    _assertNoInvoiceOverpayment(next);
    next.sort((a, b) => b.dueDate.compareTo(a.dueDate));
    _transactions = next;
    notifyListeners();
    await _repository.saveTransactions(_transactions);
  }

  Future<void> deleteTransaction(
    FinanceTransaction transaction, {
    bool futureGroup = false,
  }) async {
    if (transaction.isRecurring && _recurrenceRepository != null) {
      await _deleteRecurringTransaction(transaction, futureGroup: futureGroup);
      return;
    }
    final next = List<FinanceTransaction>.of(_transactions);
    if (futureGroup &&
        (transaction.seriesId != null ||
            transaction.installmentGroupId != null)) {
      final groupId = transaction.seriesId ?? transaction.installmentGroupId;
      next.removeWhere(
        (item) =>
            (item.seriesId ?? item.installmentGroupId) == groupId &&
            !item.dueDate.isBefore(transaction.dueDate),
      );
    } else {
      next.removeWhere((item) => item.id == transaction.id);
    }
    _assertNoInvoiceOverpayment(next);
    _transactions = next;
    notifyListeners();
    await _repository.saveTransactions(_transactions);
  }

  Future<void> markAsPaid(FinanceTransaction transaction) async {
    if (transaction.isProjection) {
      _transactions.add(transaction.copyWith(status: 'paid', projected: false));
      _transactions.sort((a, b) => b.dueDate.compareTo(a.dueDate));
      notifyListeners();
      await _repository.saveTransactions(_transactions);
      return;
    }
    _transactions = _transactions
        .map(
          (item) =>
              item.id == transaction.id ? item.copyWith(status: 'paid') : item,
        )
        .toList();
    notifyListeners();
    await _repository.saveTransactions(_transactions);
  }

  Future<void> addAccount(FinanceAccount account) async {
    _accounts.add(account);
    if (account.isCard) {
      final trackingStart = monthStart(_clock());
      _invoiceTrackingStarts[account.id] = trackingStart;
      await _repository.saveCardInvoiceTrackingStart(account.id, trackingStart);
    }
    notifyListeners();
    await _repository.saveAccounts(_accounts);
  }

  List<FinanceTransaction> transactionsLinkedTo(FinanceAccount account) =>
      transactions
          .where(
            (transaction) =>
                transaction.accountId == account.id ||
                transaction.targetAccountId == account.id,
          )
          .toList(growable: false);

  Future<bool> deleteAccount(
    FinanceAccount account, {
    bool deleteLinkedTransactions = false,
  }) async {
    final hasTransactions =
        _transactions.any(
          (transaction) =>
              transaction.accountId == account.id ||
              transaction.targetAccountId == account.id,
        ) ||
        _recurrences.any(
          (rule) =>
              rule.template.accountId == account.id ||
              rule.template.targetAccountId == account.id,
        );
    if (hasTransactions && !deleteLinkedTransactions) return false;

    if (deleteLinkedTransactions) {
      _transactions.removeWhere(
        (transaction) =>
            transaction.accountId == account.id ||
            transaction.targetAccountId == account.id,
      );
      await _repository.saveTransactions(_transactions);
      _recurrences.removeWhere(
        (rule) =>
            rule.template.accountId == account.id ||
            rule.template.targetAccountId == account.id,
      );
      await _recurrenceRepository?.saveRecurrences(_recurrences);
    }
    _accounts.removeWhere((item) => item.id == account.id);
    _invoiceTrackingStarts.remove(account.id);
    notifyListeners();
    await _repository.saveAccounts(_accounts);
    return true;
  }

  Future<void> saveBudget(FinanceBudget budget) async {
    _budgets.removeWhere((item) => item.category == budget.category);
    _budgets.add(budget);
    notifyListeners();
    await _repository.saveBudgets(_budgets);
  }

  Future<void> deleteBudget(FinanceBudget budget) async {
    _budgets.removeWhere((item) => item.id == budget.id);
    notifyListeners();
    await _repository.saveBudgets(_budgets);
  }

  double accountBalance(FinanceAccount account) =>
      accountBalanceCents(account) / 100;

  int accountBalanceCents(FinanceAccount account) {
    if (account.isCard) {
      return -invoiceSummary(account, _selectedMonth).remainingCents;
    }
    var balance = _toCents(account.openingBalance);
    for (final transaction in _transactions.where(
      (item) => item.status == 'paid',
    )) {
      final amount = _toCents(transaction.amount);
      if (transaction.accountId == account.id) {
        if (transaction.isIncome) balance += amount;
        if (transaction.isExpense ||
            transaction.isTransfer ||
            transaction.isCardPayment) {
          balance -= amount;
        }
      }
      if (transaction.isTransfer && transaction.targetAccountId == account.id) {
        balance += amount;
      }
    }
    return balance;
  }

  DateTime invoiceTrackingStartFor(FinanceAccount card) =>
      _invoiceTrackingStarts[card.id] ?? monthStart(_clock());

  CardInvoiceSummary invoiceSummary(FinanceAccount card, DateTime month) {
    if (!card.isCard) {
      throw ArgumentError.value(
        card.id,
        'card',
        'A conta precisa ser um cart\u00e3o.',
      );
    }
    final period = monthStart(month);
    final trackingStart = invoiceTrackingStartFor(card);
    final visibleTransactions = transactionsForRange(
      period,
      DateTime(period.year, period.month + 1, 0),
    );
    final purchases = visibleTransactions.where(
      (transaction) =>
          transaction.accountId == card.id &&
          transaction.isExpense &&
          sameMonth(transaction.dueDate, period),
    );
    final payments =
        visibleTransactions
            .where(
              (transaction) =>
                  transaction.isCardPayment &&
                  transaction.targetAccountId == card.id &&
                  sameMonth(transaction.dueDate, period),
            )
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
    final totalCents = purchases.fold<int>(
      0,
      (total, transaction) => total + _toCents(transaction.amount),
    );
    final paidCents = payments.fold<int>(
      0,
      (total, transaction) => total + _toCents(transaction.amount),
    );
    final closingDate = cardInvoiceClosingDate(card, period);
    final dueDate = cardInvoiceDueDate(card, period);
    final status = _invoiceStatus(
      period: period,
      trackingStart: trackingStart,
      closingDate: closingDate,
      dueDate: dueDate,
      totalCents: totalCents,
      paidCents: paidCents,
    );
    return CardInvoiceSummary(
      card: card,
      period: period,
      closingDate: closingDate,
      dueDate: dueDate,
      trackingStart: trackingStart,
      totalCents: totalCents,
      paidCents: paidCents,
      status: status,
      payments: List.unmodifiable(payments),
    );
  }

  double invoiceTotal(FinanceAccount account, DateTime month) =>
      account.isCard ? invoiceSummary(account, month).remaining : 0;

  double invoiceGrossTotal(FinanceAccount account, DateTime month) =>
      account.isCard ? invoiceSummary(account, month).total : 0;

  double cardAvailableLimit(FinanceAccount card) {
    if (!card.isCard) return accountBalance(card);
    final trackingStart = invoiceTrackingStartFor(card);
    final visibleTransactions = transactions;
    final purchases = visibleTransactions
        .where(
          (item) =>
              item.accountId == card.id &&
              item.isExpense &&
              !item.isProjection &&
              !_isMonthBefore(item.dueDate, trackingStart),
        )
        .fold<int>(0, (sum, item) => sum + _toCents(item.amount));
    final payments = visibleTransactions
        .where(
          (item) =>
              item.isCardPayment &&
              item.targetAccountId == card.id &&
              !_isMonthBefore(item.dueDate, trackingStart),
        )
        .fold<int>(0, (sum, item) => sum + _toCents(item.amount));
    final used = (purchases - payments).clamp(0, purchases);
    return (_toCents(card.limit) - used) / 100;
  }

  InvoicePaymentValidation validateInvoicePayment(
    InvoicePaymentDraft draft, {
    FinanceTransaction? editing,
  }) {
    final card = _accounts
        .where((account) => account.id == draft.cardId && account.isCard)
        .firstOrNull;
    if (card == null) {
      return const InvoicePaymentValidation(
        generalError: 'O cart\u00e3o informado n\u00e3o existe.',
      );
    }
    if (editing != null &&
        (!editing.isCardPayment ||
            editing.targetAccountId != card.id ||
            !sameMonth(editing.dueDate, draft.invoicePeriod))) {
      return const InvoicePaymentValidation(
        generalError: 'O pagamento n\u00e3o pertence a esta fatura.',
      );
    }
    final summary = invoiceSummary(card, draft.invoicePeriod);
    if (!summary.isTracked) {
      return const InvoicePaymentValidation(
        generalError:
            'Esta fatura faz parte do hist\u00f3rico n\u00e3o rastreado.',
      );
    }

    final source = _accounts
        .where(
          (account) =>
              account.id == draft.sourceAccountId &&
              !account.isCard &&
              !account.archived,
        )
        .firstOrNull;
    final sourceError = source == null
        ? 'Selecione uma conta ou carteira v\u00e1lida.'
        : null;
    String? amountError;
    if (draft.amountCents <= 0) {
      amountError = 'Informe um valor maior que zero.';
    } else {
      final editableAmount = editing == null ? 0 : _toCents(editing.amount);
      final maximum = summary.remainingCents + editableAmount;
      if (draft.amountCents > maximum) {
        amountError = 'O valor n\u00e3o pode ultrapassar o restante da fatura.';
      }
    }
    final today = _dateOnly(_clock());
    final paymentDate = _dateOnly(draft.paymentDate);
    final dateError = paymentDate.isAfter(today)
        ? 'A data do pagamento n\u00e3o pode estar no futuro.'
        : null;
    var sourceBalance = source == null ? 0 : accountBalanceCents(source);
    if (source != null && editing?.accountId == source.id) {
      sourceBalance += _toCents(editing!.amount);
    }
    return InvoicePaymentValidation(
      sourceError: sourceError,
      amountError: amountError,
      dateError: dateError,
      sourceBalanceCents: sourceBalance,
      resultingBalanceCents: sourceBalance - draft.amountCents,
    );
  }

  Future<FinanceTransaction> saveInvoicePayment(
    InvoicePaymentDraft draft, {
    FinanceTransaction? editing,
    bool negativeBalanceConfirmed = false,
  }) async {
    final validation = validateInvoicePayment(draft, editing: editing);
    if (!validation.isValid) throw _validationException(validation);
    if (validation.requiresNegativeBalanceConfirmation &&
        !negativeBalanceConfirmed) {
      throw const InvoicePaymentException(
        InvoicePaymentFailure.negativeBalanceNotConfirmed,
        'Confirme o saldo negativo antes de continuar.',
      );
    }
    final card = _accounts.firstWhere((account) => account.id == draft.cardId);
    final payment = FinanceTransaction(
      id: editing?.id ?? _uuid.v4(),
      name: 'Pagamento de fatura - ${card.name}',
      category: 'Pagamento de fatura',
      amount: draft.amountCents / 100,
      date: _dateOnly(draft.paymentDate),
      dueDate: cardInvoiceDueDate(card, monthStart(draft.invoicePeriod)),
      type: 'cardPayment',
      accountId: draft.sourceAccountId,
      targetAccountId: card.id,
      status: 'paid',
      notes: draft.notes.trim(),
    );
    final next = List<FinanceTransaction>.of(_transactions);
    if (editing == null) {
      next.add(payment);
    } else {
      final index = next.indexWhere((item) => item.id == editing.id);
      if (index < 0) {
        throw const InvoicePaymentException(
          InvoicePaymentFailure.invalidPayment,
          'O pagamento n\u00e3o foi encontrado.',
        );
      }
      next[index] = payment;
    }
    _assertNoInvoiceOverpayment(next);
    next.sort((a, b) => b.dueDate.compareTo(a.dueDate));
    _transactions = next;
    notifyListeners();
    await _repository.saveTransactions(_transactions);
    return payment;
  }

  Future<void> deleteInvoicePayment(FinanceTransaction payment) async {
    if (!payment.isCardPayment) {
      throw const InvoicePaymentException(
        InvoicePaymentFailure.invalidPayment,
        'O lan\u00e7amento informado n\u00e3o \u00e9 um pagamento de fatura.',
      );
    }
    _transactions.removeWhere((item) => item.id == payment.id);
    notifyListeners();
    await _repository.saveTransactions(_transactions);
  }

  RecurrenceRepository? get _recurrenceRepository {
    final repository = _repository;
    return repository is RecurrenceRepository
        ? repository as RecurrenceRepository
        : null;
  }

  List<FinanceTransaction> transactionsForRange(
    DateTime from,
    DateTime through,
  ) {
    final result = _transactions
        .where(
          (item) =>
              !item.dueDate.isBefore(from) && !item.dueDate.isAfter(through),
        )
        .toList();
    for (final rule in _recurrences) {
      result.addAll(
        _recurrenceService.projectDueBetween(
          rule,
          from: from,
          through: through,
          persisted: _transactions,
        ),
      );
    }
    result.sort((a, b) => b.dueDate.compareTo(a.dueDate));
    return List.unmodifiable(result);
  }

  List<FinanceTransaction> transactionsForMonth(DateTime month) {
    final start = monthStart(month);
    final result = transactionsForRange(
      start,
      DateTime(start.year, start.month + 1, 0),
    ).where((item) => !item.isCardPayment).toList();
    result.addAll(
      _transactions.where(
        (item) => item.isCardPayment && sameMonth(item.date, start),
      ),
    );
    result.sort((a, b) {
      final left = a.isCardPayment ? a.date : a.dueDate;
      final right = b.isCardPayment ? b.date : b.dueDate;
      return right.compareTo(left);
    });
    return List.unmodifiable(result);
  }

  List<FinanceTransaction> _transactionsWithProjections() {
    if (_recurrences.isEmpty) {
      return List<FinanceTransaction>.of(_transactions);
    }
    final nowMonth = monthStart(_clock());
    final windows = <({DateTime from, DateTime through})>[
      (
        from: addMonths(nowMonth, -12),
        through: DateTime(
          addMonths(nowMonth, 24).year,
          addMonths(nowMonth, 24).month + 1,
          0,
        ),
      ),
      (
        from: addMonths(_selectedMonth, -6),
        through: DateTime(
          addMonths(_selectedMonth, 12).year,
          addMonths(_selectedMonth, 12).month + 1,
          0,
        ),
      ),
    ];
    final result = List<FinanceTransaction>.of(_transactions);
    final ids = result.map((item) => item.id).toSet();
    for (final rule in _recurrences) {
      for (final window in windows) {
        for (final projection in _recurrenceService.project(
          rule,
          from: window.from,
          through: window.through,
          persisted: _transactions,
        )) {
          if (ids.add(projection.id)) result.add(projection);
        }
      }
    }
    result.sort((a, b) => b.dueDate.compareTo(a.dueDate));
    return result;
  }

  Future<void> _createRecurrence(FinanceTransaction first) async {
    final repository = _recurrenceRepository!;
    final ruleId = first.seriesId ?? _uuid.v4();
    final rule = FinanceRecurrence(
      id: ruleId,
      template: _recurrenceTemplate(first, ruleId),
      frequency: first.recurrence,
      startsOn: _dateOnly(first.date),
    );
    _recurrences.removeWhere((item) => item.id == ruleId);
    _recurrences.add(rule);
    await repository.saveRecurrences(_recurrences);

    final materialized = _materializeDueOccurrences([rule], _transactions);
    if (materialized.length != _transactions.length) {
      _transactions = materialized;
      await _repository.saveTransactions(_transactions);
    }
    notifyListeners();
  }

  Future<void> _saveRecurringTransaction(
    FinanceTransaction replacement, {
    required FinanceTransaction editing,
    required bool applyToFuture,
  }) async {
    final repository = _recurrenceRepository!;
    final ruleIndex = _recurrences.indexWhere(
      (rule) => rule.id == editing.seriesId,
    );
    if (ruleIndex < 0) {
      final normalized = replacement.copyWith(projected: false);
      final index = _transactions.indexWhere((item) => item.id == editing.id);
      if (index < 0) {
        _transactions.add(normalized);
      } else {
        _transactions[index] = normalized;
      }
      _transactions.sort((a, b) => b.dueDate.compareTo(a.dueDate));
      await _repository.saveTransactions(_transactions);
      notifyListeners();
      return;
    }

    if (applyToFuture) {
      final rule = _recurrences[ruleIndex];
      final updatedRule = rule.copyWith(
        template: _recurrenceTemplate(replacement, rule.id),
        startsOn: _dateOnly(replacement.date),
        clearEndsOn: true,
      );
      _recurrences[ruleIndex] = updatedRule;
      _transactions = _transactions.map((item) {
        if (item.seriesId != rule.id || item.date.isBefore(editing.date)) {
          return item;
        }
        return item.copyWith(
          name: replacement.name,
          category: replacement.category,
          amount: replacement.amount,
          type: replacement.type,
          accountId: replacement.accountId,
          targetAccountId: replacement.targetAccountId,
          clearTargetAccountId: replacement.targetAccountId == null,
          status: replacement.status,
          notes: replacement.notes,
          projected: false,
        );
      }).toList();
      await repository.saveRecurrences(_recurrences);
    } else {
      final normalized = replacement.copyWith(projected: false);
      final index = _transactions.indexWhere((item) => item.id == editing.id);
      if (index < 0) {
        _transactions.add(normalized);
      } else {
        _transactions[index] = normalized;
      }
    }
    _transactions.sort((a, b) => b.dueDate.compareTo(a.dueDate));
    _assertNoInvoiceOverpayment(_transactions);
    await _repository.saveTransactions(_transactions);
    notifyListeners();
  }

  Future<void> _deleteRecurringTransaction(
    FinanceTransaction transaction, {
    required bool futureGroup,
  }) async {
    final repository = _recurrenceRepository!;
    final index = _recurrences.indexWhere(
      (rule) => rule.id == transaction.seriesId,
    );
    if (index < 0) return;
    final rule = _recurrences[index];
    if (futureGroup) {
      if (!transaction.date.isAfter(rule.startsOn)) {
        _recurrences.removeAt(index);
      } else {
        _recurrences[index] = rule.copyWith(
          endsOn: transaction.date.subtract(const Duration(days: 1)),
        );
      }
      _transactions.removeWhere(
        (item) =>
            item.seriesId == rule.id && !item.date.isBefore(transaction.date),
      );
    } else {
      final excluded = Set<String>.of(rule.excludedOccurrenceKeys)
        ..add(FinanceRecurrence.occurrenceKey(transaction.date));
      _recurrences[index] = rule.copyWith(excludedOccurrenceKeys: excluded);
      _transactions.removeWhere(
        (item) =>
            item.id == transaction.id ||
            (item.seriesId == rule.id &&
                sameMonth(item.date, transaction.date) &&
                item.date.day == transaction.date.day),
      );
    }
    _assertNoInvoiceOverpayment(_transactions);
    await repository.saveRecurrences(_recurrences);
    await _repository.saveTransactions(_transactions);
    notifyListeners();
  }

  ({
    List<FinanceTransaction> transactions,
    List<FinanceRecurrence> recurrences,
    bool changed,
  })
  _migrateLegacyRecurrences(
    List<FinanceTransaction> transactions,
    List<FinanceRecurrence> recurrences,
  ) {
    final nextTransactions = List<FinanceTransaction>.of(transactions);
    final nextRecurrences = List<FinanceRecurrence>.of(recurrences);
    final existingRuleIds = nextRecurrences.map((item) => item.id).toSet();
    final groups = <String, List<FinanceTransaction>>{};
    for (final item in transactions.where(
      (item) => item.seriesId != null && item.recurrence != 'none',
    )) {
      groups.putIfAbsent(item.seriesId!, () => []).add(item);
    }
    var changed = false;
    for (final entry in groups.entries) {
      if (existingRuleIds.contains(entry.key)) continue;
      final occurrences = entry.value..sort((a, b) => a.date.compareTo(b.date));
      final anchor = occurrences.first;
      final latest = occurrences.lastWhere(
        (item) => !item.date.isAfter(_clock()),
        orElse: () => anchor,
      );
      nextRecurrences.add(
        FinanceRecurrence(
          id: entry.key,
          template: _recurrenceTemplate(
            FinanceTransaction(
              id: anchor.id,
              name: latest.name,
              category: latest.category,
              amount: latest.amount,
              date: anchor.date,
              dueDate: anchor.dueDate,
              type: latest.type,
              accountId: latest.accountId,
              targetAccountId: latest.targetAccountId,
              status: anchor.status,
              notes: latest.notes,
              recurrence: anchor.recurrence,
              seriesId: entry.key,
            ),
            entry.key,
          ),
          frequency: anchor.recurrence,
          startsOn: _dateOnly(anchor.date),
        ),
      );
      nextTransactions.removeWhere(
        (item) =>
            item.seriesId == entry.key &&
            item.status == 'planned' &&
            item.date.isAfter(_dateOnly(_clock())),
      );
      changed = true;
    }
    return (
      transactions: nextTransactions,
      recurrences: nextRecurrences,
      changed: changed,
    );
  }

  List<FinanceTransaction> _materializeDueOccurrences(
    Iterable<FinanceRecurrence> recurrences,
    List<FinanceTransaction> persisted,
  ) {
    final result = List<FinanceTransaction>.of(persisted);
    final today = _dateOnly(_clock());
    for (final rule in recurrences) {
      final due = _recurrenceService.project(
        rule,
        from: rule.startsOn,
        through: today,
        persisted: result,
      );
      for (final occurrence in due) {
        final first = occurrence.date == rule.startsOn;
        result.add(
          occurrence.copyWith(
            status: first ? rule.template.status : 'pending',
            projected: false,
          ),
        );
      }
    }
    result.sort((a, b) => b.dueDate.compareTo(a.dueDate));
    return result;
  }

  FinanceTransaction _recurrenceTemplate(
    FinanceTransaction source,
    String ruleId,
  ) => FinanceTransaction(
    id: '$ruleId-template',
    name: source.name,
    category: source.category,
    amount: source.amount,
    date: _dateOnly(source.date),
    dueDate: _dateOnly(source.dueDate),
    type: source.type,
    accountId: source.accountId,
    targetAccountId: source.targetAccountId,
    status: source.status,
    notes: source.notes,
    recurrence: source.recurrence,
    seriesId: ruleId,
  );

  CardInvoiceStatus _invoiceStatus({
    required DateTime period,
    required DateTime trackingStart,
    required DateTime closingDate,
    required DateTime dueDate,
    required int totalCents,
    required int paidCents,
  }) {
    if (_isMonthBefore(period, trackingStart)) {
      return CardInvoiceStatus.untracked;
    }
    if (totalCents > 0 && paidCents >= totalCents) {
      return CardInvoiceStatus.paid;
    }
    final today = _dateOnly(_clock());
    if (totalCents > paidCents && dueDate.isBefore(today)) {
      return CardInvoiceStatus.overdue;
    }
    if (paidCents > 0) return CardInvoiceStatus.partiallyPaid;
    if (!today.isBefore(closingDate)) return CardInvoiceStatus.closed;
    return CardInvoiceStatus.open;
  }

  void _assertNoInvoiceOverpayment(List<FinanceTransaction> transactions) {
    final totals = <String, int>{};
    final payments = <String, int>{};
    for (final item in transactions) {
      if (item.isExpense) {
        final account = _accounts
            .where((candidate) => candidate.id == item.accountId)
            .firstOrNull;
        if (account == null || !account.isCard) continue;
        final period = monthStart(item.dueDate);
        if (_isMonthBefore(period, invoiceTrackingStartFor(account))) continue;
        final key = '${account.id}:${_monthKey(period)}';
        totals[key] = (totals[key] ?? 0) + _toCents(item.amount);
      } else if (item.isCardPayment && item.targetAccountId != null) {
        final card = _accounts
            .where((candidate) => candidate.id == item.targetAccountId)
            .firstOrNull;
        if (card == null || !card.isCard) continue;
        final period = monthStart(item.dueDate);
        if (_isMonthBefore(period, invoiceTrackingStartFor(card))) continue;
        final key = '${card.id}:${_monthKey(period)}';
        payments[key] = (payments[key] ?? 0) + _toCents(item.amount);
      }
    }
    for (final entry in payments.entries) {
      if (entry.value <= (totals[entry.key] ?? 0)) continue;
      throw const InvoicePaymentException(
        InvoicePaymentFailure.purchaseWouldOverpay,
        'A altera\u00e7\u00e3o deixaria uma fatura com pagamento excedente. '
        'Ajuste o pagamento da fatura primeiro.',
      );
    }
  }

  InvoicePaymentException _validationException(
    InvoicePaymentValidation validation,
  ) {
    if (validation.sourceError != null) {
      return InvoicePaymentException(
        InvoicePaymentFailure.invalidSource,
        validation.sourceError!,
      );
    }
    if (validation.amountError != null) {
      final exceeds = validation.amountError!.contains('ultrapassar');
      return InvoicePaymentException(
        exceeds
            ? InvoicePaymentFailure.exceedsRemaining
            : InvoicePaymentFailure.invalidAmount,
        validation.amountError!,
      );
    }
    if (validation.dateError != null) {
      return InvoicePaymentException(
        InvoicePaymentFailure.futureDate,
        validation.dateError!,
      );
    }
    final message = validation.generalError ?? 'Pagamento inv\u00e1lido.';
    return InvoicePaymentException(
      message.contains('Hist')
          ? InvoicePaymentFailure.untrackedInvoice
          : InvoicePaymentFailure.invalidCard,
      message,
    );
  }

  static int _toCents(double value) => (value * 100).round();
  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
  static String _monthKey(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}';
  static bool _isMonthBefore(DateTime value, DateTime other) =>
      value.year < other.year ||
      (value.year == other.year && value.month < other.month);
}
