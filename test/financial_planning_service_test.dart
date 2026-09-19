import 'package:flutter_application_1/features/finance/application/financial_planning_service.dart';
import 'package:flutter_application_1/features/finance/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = FinancialPlanningService();
  final month = DateTime(2026, 9);
  final today = DateTime(2026, 9, 11);
  final transactions = [
    _transaction('salary', 'income', 5000),
    _transaction('rent', 'expense', 1500, status: 'pending'),
    _transaction(
      'card-purchase',
      'expense',
      1000,
      card: true,
      installments: 10,
    ),
    _transaction('partial-payment', 'cardPayment', 400),
    _transaction('transfer', 'transfer', 500),
    _transaction('future-installment', 'expense', 1000, month: 10, card: true),
  ];

  test(
    'savings plan subtracts purchases once and includes planned commitments',
    () {
      final result = service.savingsPlan(
        transactions: transactions,
        month: month,
        today: today,
        savingsTargetCents: 100000,
      );
      expect(result['income_cents'], 500000);
      expect(result['expense_cents'], 250000);
      expect(result['planned_expense_cents'], 150000);
      expect(result['installment_expense_cents'], 100000);
      expect(result['spending_ceiling_cents'], 400000);
      expect(result['remaining_margin_cents'], 150000);
      expect(result['additional_spending_cents'], 150000);
      expect(result['days_remaining'], 20);
      expect(result['daily_spending_cents'], 7500);
    },
  );

  test('income scenario replaces rather than adds to recorded income', () {
    final result = service.savingsPlan(
      transactions: transactions,
      month: month,
      today: today,
      savingsTargetCents: 100000,
      monthlyIncomeCents: 300000,
    );
    expect(result['monthly_income_cents'], 300000);
    expect(result['income_cents'], 500000);
    expect(result['remaining_margin_cents'], -50000);
    expect(result['shortfall_cents'], 50000);
    expect(result['additional_spending_cents'], 0);
    expect(result['daily_spending_cents'], 0);
  });

  test(
    'missing income prompts confirmation instead of fabricating a budget',
    () {
      final result = service.savingsPlan(
        transactions: [],
        month: month,
        today: today,
        savingsTargetCents: 100000,
      );
      expect(result['needs_income_confirmation'], true);
      expect(result['monthly_income_cents'], isNull);
      expect(result['spending_ceiling_cents'], isNull);
      expect(result['additional_spending_cents'], isNull);
      expect(result['daily_spending_cents'], isNull);
    },
  );

  test(
    'explicit zero income and closed months do not invent a daily allowance',
    () {
      final result = service.savingsPlan(
        transactions: [],
        month: DateTime(2026, 8),
        today: today,
        savingsTargetCents: 50000,
        monthlyIncomeCents: 0,
      );
      expect(result['needs_income_confirmation'], false);
      expect(result['shortfall_cents'], 50000);
      expect(result['daily_spending_cents'], isNull);
      expect(result['days_remaining'], 0);
    },
  );

  test('future month uses its own records, without projecting salary automatically', () {
    final result = service.savingsPlan(
      transactions: transactions,
      month: DateTime(2026, 10),
      today: today,
      savingsTargetCents: 50000,
    );
    expect(result['expense_cents'], 100000);
    expect(result['needs_income_confirmation'], true);
    expect(result['days_remaining'], 31);
  });

  test('cash flow projection accumulates the result of each month', () {
    final projection = service.cashFlowProjection(
      accounts: [
        FinanceAccount(
          id: 'checking',
          name: 'Conta corrente',
          kind: 'account',
          openingBalance: 0,
        ),
      ],
      transactions: [
        _transaction('salary-sep', 'income', 5000),
        _transaction('expenses-sep', 'expense', 2000),
        _transaction('salary-oct', 'income', 5000, month: 10),
        _transaction('expenses-oct', 'expense', 2000, month: 10),
        _transaction('internal-transfer', 'transfer', 900, month: 10),
        _transaction('card-payment', 'cardPayment', 2000, month: 10),
      ],
      fromMonth: DateTime(2026, 9),
      months: 2,
    );

    expect(projection, hasLength(2));
    expect(projection.first.endingBalanceCents, 300000);
    expect(projection.last.endingBalanceCents, 600000);
    expect(projection.last.incomeCents, 500000);
    expect(projection.last.expenseCents, 200000);
  });
}

FinanceTransaction _transaction(
  String id,
  String type,
  double amount, {
  String status = 'paid',
  bool card = false,
  int month = 9,
  int installments = 1,
}) => FinanceTransaction(
  id: id,
  name: id,
  category: 'Outros',
  amount: amount,
  date: DateTime(2026, 9, 1),
  dueDate: DateTime(2026, month, 10),
  type: type,
  accountId: card ? 'card' : 'checking',
  targetAccountId: type == 'cardPayment' ? 'card' : null,
  status: status,
  installmentCount: installments,
);
