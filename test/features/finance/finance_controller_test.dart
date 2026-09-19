import 'package:saldo_sh/src/features/finance/application/finance_controller.dart';
import 'package:saldo_sh/src/features/finance/application/transaction_builder.dart';
import 'package:saldo_sh/src/features/finance/domain/models.dart';
import 'package:saldo_sh/src/features/finance/domain/repositories/finance_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FinanceController', () {
    test('loads empty local state without creating seed data', () async {
      final controller = FinanceController(_MemoryFinanceRepository());

      await controller.initialize();

      expect(controller.isLoading, isFalse);
      expect(controller.accounts, isEmpty);
      expect(controller.transactions, isEmpty);
      expect(controller.budgets, isEmpty);
    });

    test('calculates account balance from paid transactions', () async {
      final repository = _MemoryFinanceRepository();
      final controller = FinanceController(repository);
      await controller.initialize();
      final account = FinanceAccount(
        id: 'checking',
        name: 'Conta',
        kind: 'account',
        openingBalance: 100,
      );
      await controller.addAccount(account);
      await controller.saveTransaction(
        items: [
          _transaction(id: 'income', amount: 50, type: 'income'),
          _transaction(id: 'expense', amount: 30, type: 'expense'),
          _transaction(
            id: 'planned',
            amount: 80,
            type: 'expense',
            status: 'planned',
          ),
        ],
      );

      expect(controller.accountBalance(account), 120);
      expect(repository.transactions, hasLength(3));
    });

    test('does not delete an account referenced by a transaction', () async {
      final controller = FinanceController(_MemoryFinanceRepository());
      await controller.initialize();
      final account = FinanceAccount(
        id: 'checking',
        name: 'Conta',
        kind: 'account',
        openingBalance: 0,
      );
      await controller.addAccount(account);
      await controller.saveTransaction(
        items: [_transaction(id: 'expense', amount: 10, type: 'expense')],
      );

      expect(await controller.deleteAccount(account), isFalse);
      expect(controller.accounts, contains(account));
    });

    test(
      'confirmed account deletion also removes every linked transaction',
      () async {
        final repository = _MemoryFinanceRepository();
        final controller = FinanceController(repository);
        await controller.initialize();
        final checking = FinanceAccount(
          id: 'checking',
          name: 'Conta',
          kind: 'account',
          openingBalance: 0,
        );
        final savings = FinanceAccount(
          id: 'savings',
          name: 'Reserva',
          kind: 'account',
          openingBalance: 0,
        );
        await controller.addAccount(checking);
        await controller.addAccount(savings);
        await controller.saveTransaction(
          items: [
            _transaction(id: 'expense', amount: 10, type: 'expense'),
            FinanceTransaction(
              id: 'transfer',
              name: 'Transferência',
              category: 'Outros',
              amount: 20,
              date: DateTime(2026),
              dueDate: DateTime(2026),
              type: 'transfer',
              accountId: 'savings',
              targetAccountId: 'checking',
            ),
            FinanceTransaction(
              id: 'unrelated',
              name: 'Rendimento',
              category: 'Renda',
              amount: 5,
              date: DateTime(2026),
              dueDate: DateTime(2026),
              type: 'income',
              accountId: 'savings',
            ),
          ],
        );

        expect(controller.transactionsLinkedTo(checking), hasLength(2));
        expect(
          await controller.deleteAccount(
            checking,
            deleteLinkedTransactions: true,
          ),
          isTrue,
        );
        expect(controller.accounts.map((item) => item.id), ['savings']);
        expect(controller.transactions.map((item) => item.id), ['unrelated']);
        expect(repository.accounts.map((item) => item.id), ['savings']);
        expect(repository.transactions.map((item) => item.id), ['unrelated']);
      },
    );

    test(
      'series edits and deletions affect only the chosen future scope',
      () async {
        final repository = _MemoryFinanceRepository()
          ..accounts = [
            FinanceAccount(
              id: 'checking',
              name: 'Conta',
              kind: 'account',
              openingBalance: 0,
            ),
          ]
          ..transactions = [
            for (var installment = 1; installment <= 3; installment++)
              FinanceTransaction(
                id: 'part-$installment',
                name: 'Notebook',
                category: 'Compras',
                amount: 100,
                date: DateTime(2026, 9, 1),
                dueDate: DateTime(2026, 8 + installment, 10),
                type: 'expense',
                accountId: 'checking',
                installmentGroupId: 'series',
                installmentNumber: installment,
                installmentCount: 3,
              ),
          ];
        final controller = FinanceController(repository);
        await controller.initialize();
        final second = controller.transactions.firstWhere(
          (item) => item.id == 'part-2',
        );

        await controller.saveTransaction(
          items: [second.copyWith(name: 'Notebook ajustado', amount: 125)],
          editing: second,
          applyToFuture: true,
        );

        expect(
          controller.transactions
              .firstWhere((item) => item.id == 'part-1')
              .name,
          'Notebook',
        );
        expect(
          controller.transactions
              .where((item) => item.id != 'part-1')
              .every(
                (item) =>
                    item.name == 'Notebook ajustado' && item.amount == 125,
              ),
          isTrue,
        );

        await controller.deleteTransaction(second, futureGroup: true);
        expect(controller.transactions.map((item) => item.id), ['part-1']);
      },
    );

    test('supports partial invoice payments from different accounts', () async {
      final repository = _invoiceRepository();
      final controller = FinanceController(
        repository,
        clock: () => DateTime(2026, 9, 15),
      );
      await controller.initialize();
      final card = repository.accounts.firstWhere((item) => item.isCard);
      final checking = repository.accounts.firstWhere(
        (item) => item.id == 'checking',
      );
      final wallet = repository.accounts.firstWhere(
        (item) => item.id == 'wallet',
      );

      final first = await controller.saveInvoicePayment(
        InvoicePaymentDraft(
          cardId: card.id,
          invoicePeriod: DateTime(2026, 9),
          sourceAccountId: checking.id,
          amountCents: 4000,
          paymentDate: DateTime(2026, 9, 15),
        ),
      );

      var invoice = controller.invoiceSummary(card, DateTime(2026, 9));
      expect(first.isCardPayment, isTrue);
      expect(invoice.totalCents, 10000);
      expect(invoice.paidCents, 4000);
      expect(invoice.remainingCents, 6000);
      expect(invoice.status, CardInvoiceStatus.partiallyPaid);
      expect(controller.accountBalance(checking), 960);

      await controller.saveInvoicePayment(
        InvoicePaymentDraft(
          cardId: card.id,
          invoicePeriod: DateTime(2026, 9),
          sourceAccountId: wallet.id,
          amountCents: 6000,
          paymentDate: DateTime(2026, 9, 15),
        ),
      );

      invoice = controller.invoiceSummary(card, DateTime(2026, 9));
      expect(invoice.remainingCents, 0);
      expect(invoice.status, CardInvoiceStatus.paid);
      expect(controller.accountBalance(wallet), 440);
      expect(
        controller.transactions.where((item) => item.isExpense),
        hasLength(1),
      );
    });

    test('warns about negative balance and blocks excessive payment', () async {
      final repository = _invoiceRepository(checkingBalance: 20);
      final controller = FinanceController(
        repository,
        clock: () => DateTime(2026, 9, 15),
      );
      await controller.initialize();

      final negative = controller.validateInvoicePayment(
        InvoicePaymentDraft(
          cardId: 'card',
          invoicePeriod: DateTime(2026, 9),
          sourceAccountId: 'checking',
          amountCents: 4000,
          paymentDate: DateTime(2026, 9, 15),
        ),
      );
      expect(negative.isValid, isTrue);
      expect(negative.requiresNegativeBalanceConfirmation, isTrue);
      expect(negative.resultingBalanceCents, -2000);

      final excessive = controller.validateInvoicePayment(
        InvoicePaymentDraft(
          cardId: 'card',
          invoicePeriod: DateTime(2026, 9),
          sourceAccountId: 'checking',
          amountCents: 10001,
          paymentDate: DateTime(2026, 9, 15),
        ),
      );
      expect(excessive.isValid, isFalse);
      expect(excessive.amountError, isNotNull);

      final invalid = controller.validateInvoicePayment(
        InvoicePaymentDraft(
          cardId: 'card',
          invoicePeriod: DateTime(2026, 9),
          sourceAccountId: 'card',
          amountCents: 0,
          paymentDate: DateTime(2026, 9, 16),
        ),
      );
      expect(invalid.sourceError, isNotNull);
      expect(invalid.amountError, isNotNull);
      expect(invalid.dateError, isNotNull);
    });

    test('edits a payment and restores the previous source account', () async {
      final repository = _invoiceRepository();
      final controller = FinanceController(
        repository,
        clock: () => DateTime(2026, 9, 15),
      );
      await controller.initialize();
      final payment = await controller.saveInvoicePayment(
        InvoicePaymentDraft(
          cardId: 'card',
          invoicePeriod: DateTime(2026, 9),
          sourceAccountId: 'checking',
          amountCents: 4000,
          paymentDate: DateTime(2026, 9, 15),
        ),
      );

      await controller.saveInvoicePayment(
        InvoicePaymentDraft(
          cardId: 'card',
          invoicePeriod: DateTime(2026, 9),
          sourceAccountId: 'wallet',
          amountCents: 3000,
          paymentDate: DateTime(2026, 9, 14),
          notes: 'Corrigido',
        ),
        editing: payment,
      );

      final checking = repository.accounts.firstWhere(
        (item) => item.id == 'checking',
      );
      final wallet = repository.accounts.firstWhere(
        (item) => item.id == 'wallet',
      );
      expect(controller.accountBalance(checking), 1000);
      expect(controller.accountBalance(wallet), 470);
      expect(
        controller
            .invoiceSummary(
              repository.accounts.firstWhere((item) => item.id == 'card'),
              DateTime(2026, 9),
            )
            .paidCents,
        3000,
      );
    });

    test('blocks a purchase edit that would create an overpayment', () async {
      final repository = _invoiceRepository();
      final controller = FinanceController(
        repository,
        clock: () => DateTime(2026, 9, 15),
      );
      await controller.initialize();
      await controller.saveInvoicePayment(
        InvoicePaymentDraft(
          cardId: 'card',
          invoicePeriod: DateTime(2026, 9),
          sourceAccountId: 'checking',
          amountCents: 8000,
          paymentDate: DateTime(2026, 9, 15),
        ),
      );
      final purchase = controller.transactions.firstWhere(
        (item) => item.isExpense,
      );

      expect(
        () => controller.saveTransaction(
          items: [purchase.copyWith(amount: 70)],
          editing: purchase,
        ),
        throwsA(
          isA<InvoicePaymentException>().having(
            (error) => error.failure,
            'failure',
            InvoicePaymentFailure.purchaseWouldOverpay,
          ),
        ),
      );
    });

    test('keeps previous invoices untracked and restores card limit', () async {
      final repository = _invoiceRepository();
      repository.transactions.add(
        FinanceTransaction(
          id: 'future',
          name: 'Parcela futura',
          category: 'Compras',
          amount: 200,
          date: DateTime(2026, 9, 10),
          dueDate: DateTime(2026, 10, 20),
          type: 'expense',
          accountId: 'card',
          status: 'planned',
        ),
      );
      final controller = FinanceController(
        repository,
        clock: () => DateTime(2026, 9, 15),
      );
      await controller.initialize();
      final card = repository.accounts.firstWhere((item) => item.id == 'card');

      expect(
        controller.invoiceSummary(card, DateTime(2026, 8)).status,
        CardInvoiceStatus.untracked,
      );
      expect(controller.cardAvailableLimit(card), 700);

      await controller.saveInvoicePayment(
        InvoicePaymentDraft(
          cardId: card.id,
          invoicePeriod: DateTime(2026, 9),
          sourceAccountId: 'checking',
          amountCents: 4000,
          paymentDate: DateTime(2026, 9, 15),
        ),
      );
      expect(controller.cardAvailableLimit(card), 740);
    });

    test('derives open, closed and overdue invoice states', () async {
      final repository = _invoiceRepository();
      var now = DateTime(2026, 9, 5);
      final controller = FinanceController(repository, clock: () => now);
      await controller.initialize();
      final card = repository.accounts.firstWhere((item) => item.id == 'card');

      expect(
        controller.invoiceSummary(card, DateTime(2026, 9)).status,
        CardInvoiceStatus.open,
      );
      now = DateTime(2026, 9, 15);
      expect(
        controller.invoiceSummary(card, DateTime(2026, 9)).status,
        CardInvoiceStatus.closed,
      );
      now = DateTime(2026, 9, 21);
      expect(
        controller.invoiceSummary(card, DateTime(2026, 9)).status,
        CardInvoiceStatus.overdue,
      );
    });

    test(
      'stores a recurrence rule and materializes only due occurrences',
      () async {
        var now = DateTime(2026, 9, 14);
        final repository = _RecurringMemoryFinanceRepository()
          ..accounts = [
            FinanceAccount(
              id: 'checking',
              name: 'Conta',
              kind: 'account',
              openingBalance: 0,
            ),
          ];
        final controller = FinanceController(repository, clock: () => now);
        await controller.initialize();
        final draft = TransactionDraft(
          name: 'Aluguel',
          amount: 1500,
          category: 'Moradia',
          type: 'expense',
          accountId: 'checking',
          date: DateTime(2026, 10, 10),
          dueDate: DateTime(2026, 10, 10),
          status: 'pending',
          mode: 'recurring',
          recurrence: 'monthly',
          installmentCount: 1,
          initialInstallment: 1,
        );
        final items = const TransactionBuilder().build(
          draft,
          repository.accounts,
          generatedId: 'rent',
        );

        await controller.saveTransaction(items: items, draft: draft);

        expect(repository.recurrences, hasLength(1));
        expect(repository.transactions, isEmpty);
        expect(
          controller.transactions.any(
            (item) => item.isProjection && item.date == DateTime(2027, 11, 10),
          ),
          isTrue,
          reason: 'the recurrence must continue beyond the old 12-item cap',
        );
        final farFuture = controller.transactionsForMonth(DateTime(2126, 10));
        expect(farFuture, hasLength(1));
        expect(farFuture.single.date, DateTime(2126, 10, 10));
        expect(farFuture.single.isProjection, isTrue);

        now = DateTime(2026, 10, 10);
        await controller.reload();

        expect(repository.transactions, hasLength(1));
        expect(repository.transactions.single.isProjection, isFalse);
        expect(repository.transactions.single.status, 'pending');
      },
    );

    test('migrates the old finite recurring rows into one rule', () async {
      final repository = _RecurringMemoryFinanceRepository()
        ..accounts = [
          FinanceAccount(
            id: 'checking',
            name: 'Conta',
            kind: 'account',
            openingBalance: 0,
          ),
        ]
        ..transactions = [
          for (var index = 0; index < 12; index++)
            FinanceTransaction(
              id: 'legacy-$index',
              name: 'Assinatura',
              category: 'ServiÃ§os',
              amount: 25,
              date: DateTime(2026, 9 + index, 10),
              dueDate: DateTime(2026, 9 + index, 10),
              type: 'expense',
              accountId: 'checking',
              status: index == 0 ? 'paid' : 'planned',
              recurrence: 'monthly',
              seriesId: 'legacy-series',
            ),
        ];
      final controller = FinanceController(
        repository,
        clock: () => DateTime(2026, 9, 14),
      );

      await controller.initialize();

      expect(repository.recurrences, hasLength(1));
      expect(repository.transactions, hasLength(1));
      expect(repository.transactions.single.id, 'legacy-0');
      expect(
        controller.transactions.any(
          (item) => item.isProjection && item.date == DateTime(2027, 11, 10),
        ),
        isTrue,
      );
    });
  });
}

_MemoryFinanceRepository _invoiceRepository({double checkingBalance = 1000}) {
  final repository = _MemoryFinanceRepository();
  repository.accounts = [
    FinanceAccount(
      id: 'checking',
      name: 'Conta',
      kind: 'account',
      openingBalance: checkingBalance,
    ),
    FinanceAccount(
      id: 'wallet',
      name: 'Carteira',
      kind: 'cash',
      openingBalance: 500,
    ),
    FinanceAccount(
      id: 'card',
      name: 'Cartao',
      kind: 'card',
      openingBalance: 0,
      limit: 1000,
      closingDay: 10,
      dueDay: 20,
    ),
  ];
  repository.transactions = [
    FinanceTransaction(
      id: 'purchase',
      name: 'Compra',
      category: 'Compras',
      amount: 100,
      date: DateTime(2026, 9, 5),
      dueDate: DateTime(2026, 9, 20),
      type: 'expense',
      accountId: 'card',
    ),
  ];
  repository.trackingStarts['card'] = DateTime(2026, 9);
  return repository;
}

FinanceTransaction _transaction({
  required String id,
  required double amount,
  required String type,
  String status = 'paid',
}) => FinanceTransaction(
  id: id,
  name: 'Teste',
  category: 'Outros',
  amount: amount,
  date: DateTime(2026),
  dueDate: DateTime(2026),
  type: type,
  accountId: 'checking',
  status: status,
);

class _MemoryFinanceRepository implements FinanceRepository {
  List<FinanceTransaction> transactions = [];
  List<FinanceAccount> accounts = [];
  List<FinanceBudget> budgets = [];
  final Map<String, DateTime> trackingStarts = {};
  bool darkTheme = false;

  @override
  Future<List<FinanceAccount>> readAccounts() async => List.of(accounts);

  @override
  Future<List<FinanceBudget>> readBudgets() async => List.of(budgets);

  @override
  Future<List<FinanceTransaction>> readTransactions() async =>
      List.of(transactions);

  @override
  Future<Map<String, DateTime>> readCardInvoiceTrackingStarts() async =>
      Map.of(trackingStarts);

  @override
  Future<bool> readDarkTheme() async => darkTheme;

  @override
  Future<void> saveAccounts(List<FinanceAccount> items) async {
    accounts = List.of(items);
  }

  @override
  Future<void> saveBudgets(List<FinanceBudget> items) async {
    budgets = List.of(items);
  }

  @override
  Future<void> saveCardInvoiceTrackingStart(
    String cardId,
    DateTime month,
  ) async {
    trackingStarts[cardId] = DateTime(month.year, month.month);
  }

  @override
  Future<void> saveDarkTheme(bool value) async {
    darkTheme = value;
  }

  @override
  Future<void> saveTransactions(List<FinanceTransaction> items) async {
    transactions = List.of(items);
  }
}

class _RecurringMemoryFinanceRepository extends _MemoryFinanceRepository
    implements RecurrenceRepository {
  List<FinanceRecurrence> recurrences = [];

  @override
  Future<List<FinanceRecurrence>> readRecurrences() async =>
      List.of(recurrences);

  @override
  Future<void> saveRecurrences(List<FinanceRecurrence> items) async {
    recurrences = List.of(items);
  }
}
