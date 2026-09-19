import 'package:saldo_sh/src/features/finance/application/transaction_builder.dart';
import 'package:saldo_sh/src/features/finance/application/finance_intent_guards.dart';
import 'package:saldo_sh/src/features/finance/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('builds installments starting from the selected installment', () {
    const builder = TransactionBuilder();
    final account = FinanceAccount(
      id: 'card',
      name: 'Cartão',
      kind: 'card',
      openingBalance: 0,
      closingDay: 10,
      dueDay: 20,
    );
    final draft = TransactionDraft(
      name: 'Notebook',
      amount: 300,
      category: 'Compras',
      type: 'expense',
      accountId: account.id,
      date: DateTime(2026, 9, 15),
      dueDate: DateTime(2026, 9, 15),
      status: 'paid',
      mode: 'installment',
      recurrence: 'monthly',
      installmentCount: 4,
      initialInstallment: 2,
    );

    final result = builder.build(draft, [account], generatedId: 'series');

    expect(result, hasLength(3));
    expect(result.first.installmentNumber, 2);
    expect(result.last.installmentNumber, 4);
    expect(result.first.dueDate, DateTime(2026, 10, 20));
    expect(result[1].status, 'planned');
  });

  test('moves the due month after a closing day later than the due day', () {
    const builder = TransactionBuilder();
    final card = FinanceAccount(
      id: 'card',
      name: 'Card',
      kind: 'card',
      openingBalance: 0,
      closingDay: 25,
      dueDay: 5,
    );

    expect(
      builder.dueDateFor(_draft(card.id, DateTime(2026, 9, 20)), [card]),
      DateTime(2026, 10, 5),
    );
    expect(
      builder.dueDateFor(_draft(card.id, DateTime(2026, 9, 26)), [card]),
      DateTime(2026, 11, 5),
    );
  });

  test('keeps a purchase on the closing day in the current cycle', () {
    const builder = TransactionBuilder();
    final card = FinanceAccount(
      id: 'card',
      name: 'Card',
      kind: 'card',
      openingBalance: 0,
      closingDay: 10,
      dueDay: 20,
    );

    expect(
      builder.dueDateFor(_draft(card.id, DateTime(2026, 9, 10)), [card]),
      DateTime(2026, 9, 20),
    );
    expect(
      builder.dueDateFor(_draft(card.id, DateTime(2026, 12, 11)), [card]),
      DateTime(2027, 1, 20),
    );
  });

  test('builds only a template occurrence for a recurring transaction', () {
    const builder = TransactionBuilder();
    final draft = TransactionDraft(
      name: 'Aluguel',
      amount: 1500,
      category: 'Moradia',
      type: 'expense',
      accountId: 'checking',
      date: DateTime(2026, 9, 10),
      dueDate: DateTime(2026, 9, 10),
      status: 'pending',
      mode: 'recurring',
      recurrence: 'monthly',
      installmentCount: 1,
      initialInstallment: 1,
    );

    final result = builder.build(draft, const [], generatedId: 'rent');

    expect(result, hasLength(1));
    expect(result.single.seriesId, 'rent');
    expect(result.single.recurrence, 'monthly');
  });

  test('recognizes invoice payment wording as a dedicated intent', () {
    expect(isInvoicePaymentIntent('Paguei a fatura do Nubank'), isTrue);
    expect(isInvoicePaymentIntent('Quanto esta a fatura do Nubank?'), isFalse);
    expect(isInvoicePaymentIntent('Paguei mercado no Nubank'), isFalse);
  });

  test('clamps invoice closing and due dates at month boundaries', () {
    final card = FinanceAccount(
      id: 'card',
      name: 'Card',
      kind: 'card',
      openingBalance: 0,
      closingDay: 31,
      dueDay: 5,
    );

    expect(
      cardInvoiceClosingDate(card, DateTime(2028, 3)),
      DateTime(2028, 2, 29),
    );
    expect(cardInvoiceDueDate(card, DateTime(2028, 3)), DateTime(2028, 3, 5));
  });
}

TransactionDraft _draft(String accountId, DateTime date) => TransactionDraft(
  name: 'Compra',
  amount: 10,
  category: 'Compras',
  type: 'expense',
  accountId: accountId,
  date: date,
  dueDate: date,
  status: 'paid',
  mode: 'single',
  recurrence: 'none',
  installmentCount: 1,
  initialInstallment: 1,
);
