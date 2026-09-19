import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/app_theme.dart';
import 'package:flutter_application_1/features/finance/domain/models.dart';
import 'package:flutter_application_1/features/finance/presentation/pages/dashboard_page.dart';
import 'package:flutter_application_1/features/finance/presentation/pages/accounts_page.dart';
import 'package:flutter_application_1/features/finance/presentation/pages/reports_page.dart';
import 'package:flutter_application_1/features/finance/presentation/pages/transactions_page.dart';
import 'package:flutter_application_1/features/finance/presentation/widgets/form_fields.dart';
import 'package:flutter_application_1/features/finance/presentation/widgets/transaction_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final account = FinanceAccount(
    id: 'account-1',
    name: 'Conta principal com nome longo',
    kind: 'account',
    openingBalance: 1500,
  );
  final transaction = FinanceTransaction(
    id: 'transaction-1',
    name: 'Compra com uma descrição bastante longa',
    category: 'Alimentação',
    amount: 1234567.89,
    date: DateTime(2026, 9, 10),
    dueDate: DateTime(2026, 9, 10),
    type: 'expense',
    accountId: 'account-1',
    status: 'pending',
    installmentNumber: 10,
    installmentCount: 12,
  );
  CardInvoiceSummary invoiceFor(FinanceAccount account, DateTime month) =>
      CardInvoiceSummary(
        card: account,
        period: monthStart(month),
        closingDate: DateTime(month.year, month.month, 4),
        dueDate: DateTime(month.year, month.month, 10),
        trackingStart: DateTime(2026, 9),
        totalCents: 0,
        paidCents: 0,
        status: CardInvoiceStatus.open,
        payments: const [],
      );

  Widget app(Widget child) => MaterialApp(
    theme: AppTheme.build(Brightness.light),
    home: MediaQuery(
      data: const MediaQueryData(textScaler: TextScaler.linear(1.25)),
      child: Scaffold(body: child),
    ),
  );

  testWidgets('dashboard and reports fit a narrow viewport', (tester) async {
    await tester.binding.setSurfaceSize(const Size(340, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      app(
        DashboardPage(
          displayName: 'João Guilherme',
          month: DateTime(2026, 9),
          transactions: const [],
          accounts: [account],
          budgets: const [],
          cashFlowProjections: const [],
          balanceFor: (_) => 1234567.89,
          invoiceSummaryFor: invoiceFor,
          availableFor: (_) => 0,
          onMonth: (_) {},
          onTransactions: () {},
          onAccount: (_) {},
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(app(const ReportsPage(transactions: [])));
    await tester.pump();
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      app(
        AccountsPage(
          accounts: [account],
          balanceFor: (_) => 1234567.89,
          invoiceSummaryFor: invoiceFor,
          availableFor: (_) => 0,
          onAdd: (_) {},
          onDelete: (_) {},
          onOpen: (_) {},
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      app(
        TransactionsPage(
          transactions: [transaction],
          accounts: [account],
          onEdit: (_) {},
          onDelete: (_, _) async {},
          onPaid: (_) {},
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('dashboard recognizes legacy credit card kinds', (tester) async {
    await tester.binding.setSurfaceSize(const Size(340, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final legacyCard = FinanceAccount(
      id: 'legacy-card',
      name: 'Itaú',
      kind: 'Cartão de crédito',
      openingBalance: 0,
      limit: 10000,
    );

    await tester.pumpWidget(
      app(
        DashboardPage(
          displayName: 'João',
          month: DateTime(2026, 9),
          transactions: const [],
          accounts: [legacyCard],
          budgets: const [],
          cashFlowProjections: const [],
          balanceFor: (_) => 0,
          invoiceSummaryFor: invoiceFor,
          availableFor: (_) => 10000,
          onMonth: (_) {},
          onTransactions: () {},
          onAccount: (_) {},
        ),
      ),
    );
    await tester.pump();
    for (
      var attempt = 0;
      attempt < 5 && find.byIcon(Icons.credit_card_rounded).evaluate().isEmpty;
      attempt++
    ) {
      await tester.drag(find.byType(ListView).first, const Offset(0, -320));
      await tester.pump();
    }

    expect(legacyCard.kind, 'card');
    expect(find.byIcon(Icons.credit_card_rounded), findsOneWidget);
    expect(find.text('Nenhum cartão registrado.'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('installment editor fits a narrow viewport', (tester) async {
    await tester.binding.setSurfaceSize(const Size(340, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      app(
        TransactionEditor(
          accounts: [
            account,
            FinanceAccount(
              id: 'account-2',
              name: 'Segunda conta',
              kind: 'account',
              openingBalance: 0,
            ),
          ],
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);

    for (var index = 0; index < 3; index++) {
      await tester.drag(find.byType(ListView), const Offset(0, -420));
      await tester.pump();
    }
    final installmentChip = find.widgetWithText(ChoiceChip, 'Parcelada');
    await tester.tap(installmentChip);
    await tester.pump();
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pump();
    expect(find.byType(NumberField), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });
}
