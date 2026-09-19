import 'finance_account.dart';
import 'finance_transaction.dart';

enum CardInvoiceStatus { untracked, open, closed, partiallyPaid, paid, overdue }

class CardInvoiceSummary {
  const CardInvoiceSummary({
    required this.card,
    required this.period,
    required this.closingDate,
    required this.dueDate,
    required this.trackingStart,
    required this.totalCents,
    required this.paidCents,
    required this.status,
    required this.payments,
  });

  final FinanceAccount card;
  final DateTime period;
  final DateTime closingDate;
  final DateTime dueDate;
  final DateTime trackingStart;
  final int totalCents;
  final int paidCents;
  final CardInvoiceStatus status;
  final List<FinanceTransaction> payments;

  bool get isTracked => status != CardInvoiceStatus.untracked;
  int get remainingCents => (totalCents - paidCents).clamp(0, totalCents);
  bool get canPay => isTracked && remainingCents > 0;
  double get total => totalCents / 100;
  double get paid => paidCents / 100;
  double get remaining => remainingCents / 100;
}

class InvoicePaymentDraft {
  const InvoicePaymentDraft({
    required this.cardId,
    required this.invoicePeriod,
    required this.sourceAccountId,
    required this.amountCents,
    required this.paymentDate,
    this.notes = '',
  });

  final String cardId;
  final DateTime invoicePeriod;
  final String sourceAccountId;
  final int amountCents;
  final DateTime paymentDate;
  final String notes;
}

class InvoicePaymentValidation {
  const InvoicePaymentValidation({
    this.sourceError,
    this.amountError,
    this.dateError,
    this.generalError,
    this.sourceBalanceCents = 0,
    this.resultingBalanceCents = 0,
  });

  final String? sourceError;
  final String? amountError;
  final String? dateError;
  final String? generalError;
  final int sourceBalanceCents;
  final int resultingBalanceCents;

  bool get isValid =>
      sourceError == null &&
      amountError == null &&
      dateError == null &&
      generalError == null;
  bool get requiresNegativeBalanceConfirmation =>
      isValid && resultingBalanceCents < 0;
}

enum InvoicePaymentFailure {
  invalidPayment,
  invalidCard,
  untrackedInvoice,
  invalidSource,
  invalidAmount,
  exceedsRemaining,
  futureDate,
  negativeBalanceNotConfirmed,
  purchaseWouldOverpay,
}

class InvoicePaymentException implements Exception {
  const InvoicePaymentException(this.failure, this.message);

  final InvoicePaymentFailure failure;
  final String message;

  @override
  String toString() => message;
}

DateTime cardInvoiceDueDate(FinanceAccount card, DateTime period) =>
    _clampedDate(period.year, period.month, card.dueDay);

DateTime cardInvoiceClosingDate(FinanceAccount card, DateTime period) {
  final closeMonth = card.dueDay <= card.closingDay
      ? DateTime(period.year, period.month - 1)
      : DateTime(period.year, period.month);
  return _clampedDate(closeMonth.year, closeMonth.month, card.closingDay);
}

DateTime _clampedDate(int year, int month, int day) {
  final lastDay = DateTime(year, month + 1, 0).day;
  return DateTime(year, month, day.clamp(1, lastDay));
}
