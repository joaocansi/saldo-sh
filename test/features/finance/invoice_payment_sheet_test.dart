import 'package:flutter/material.dart';
import 'package:saldo_sh/src/features/finance/domain/models.dart';
import 'package:saldo_sh/src/features/finance/presentation/widgets/invoice_payment_sheet.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final card = FinanceAccount(
    id: 'card',
    name: 'Cartao',
    kind: 'card',
    openingBalance: 0,
    limit: 1000,
    closingDay: 10,
    dueDay: 20,
  );
  final checking = FinanceAccount(
    id: 'checking',
    name: 'Conta',
    kind: 'account',
    openingBalance: 1000,
  );
  final summary = CardInvoiceSummary(
    card: card,
    period: DateTime(2026, 9),
    closingDate: DateTime(2026, 9, 10),
    dueDate: DateTime(2026, 9, 20),
    trackingStart: DateTime(2026, 9),
    totalCents: 10000,
    paidCents: 0,
    status: CardInvoiceStatus.closed,
    payments: const [],
  );

  testWidgets('returns a partial invoice payment draft', (tester) async {
    InvoicePaymentSaveResult? saved;
    await tester.pumpWidget(
      _host(
        summary: summary,
        checking: checking,
        validate: (draft) => InvoicePaymentValidation(
          sourceBalanceCents: 100000,
          resultingBalanceCents: 100000 - draft.amountCents,
        ),
        onSaved: (result) => saved = result,
      ),
    );

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    final amount = find.byType(TextFormField);
    expect(amount, findsOneWidget);
    await tester.enterText(amount, '40,00');
    await tester.tap(find.text('Confirmar pagamento'));
    await tester.pumpAndSettle();

    expect(saved?.draft.amountCents, 4000);
    expect(saved?.draft.sourceAccountId, 'checking');
    expect(saved?.negativeBalanceConfirmed, isFalse);
  });

  testWidgets('requires confirmation when the source becomes negative', (
    tester,
  ) async {
    InvoicePaymentSaveResult? saved;
    await tester.pumpWidget(
      _host(
        summary: summary,
        checking: checking,
        validate: (draft) => InvoicePaymentValidation(
          sourceBalanceCents: 5000,
          resultingBalanceCents: 5000 - draft.amountCents,
        ),
        onSaved: (result) => saved = result,
      ),
    );

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmar pagamento'));
    await tester.pumpAndSettle();

    expect(find.text('Saldo ficara negativo'), findsNothing);
    expect(find.textContaining('Saldo ficar'), findsOneWidget);
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    expect(saved?.negativeBalanceConfirmed, isTrue);
  });
}

Widget _host({
  required CardInvoiceSummary summary,
  required FinanceAccount checking,
  required InvoicePaymentValidation Function(InvoicePaymentDraft) validate,
  required ValueChanged<InvoicePaymentSaveResult> onSaved,
}) => MaterialApp(
  home: Builder(
    builder: (context) => Scaffold(
      body: Center(
        child: FilledButton(
          onPressed: () async {
            final result = await showModalBottomSheet<InvoicePaymentSaveResult>(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              backgroundColor: Colors.transparent,
              builder: (_) => InvoicePaymentSheet(
                summary: summary,
                accounts: [checking, summary.card],
                validate: validate,
              ),
            );
            if (result != null) onSaved(result);
          },
          child: const Text('Abrir'),
        ),
      ),
    ),
  ),
);
