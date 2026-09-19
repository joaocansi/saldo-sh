import 'account_reference_resolver.dart';

/// Protects invoice settlement from being represented as another expense.
/// This safety guard does not extract transaction fields.
bool isInvoicePaymentIntent(String text) {
  final normalized = normalizeFinanceText(text);
  if (!normalized.contains('fatura')) return false;
  return RegExp(
    r'\b(?:pagar|paguei|paga|pago|pagamento|quitar|quitei|quitacao)\b',
  ).hasMatch(normalized);
}
