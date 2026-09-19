import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/app_theme.dart';
import 'package:flutter_application_1/features/finance/domain/models.dart';
import 'package:flutter_application_1/features/finance/presentation/pages/accounts_page.dart';
import 'package:flutter_application_1/features/finance/presentation/pages/transactions_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final account = FinanceAccount(
    id: 'checking',
    name: 'Conta principal',
    kind: 'account',
    openingBalance: 1000,
  );

  Widget app(Widget child) => MaterialApp(
    theme: AppTheme.build(Brightness.light),
    home: Scaffold(body: child),
  );

  testWidgets('empty accounts page guides the first creation', (tester) async {
    await tester.pumpWidget(
      app(
        AccountsPage(
          accounts: const [],
          balanceFor: (_) => 0,
          invoiceSummaryFor: (_, _) => throw UnimplementedError(),
          availableFor: (_) => 0,
          onAdd: (_) {},
          onDelete: (_) {},
          onOpen: (_) {},
        ),
      ),
    );

    expect(find.text('Comece organizando seu dinheiro'), findsOneWidget);
    expect(find.text('Criar conta ou cartão'), findsOneWidget);
    expect(
      find.textContaining('Adicione sua primeira conta, carteira ou cartão'),
      findsOneWidget,
    );

    await tester.tap(find.text('Criar conta ou cartão'));
    await tester.pumpAndSettle();
    expect(find.text('Nova conta'), findsOneWidget);
  });

  testWidgets('account cards expose a visible delete action', (tester) async {
    FinanceAccount? deleted;
    await tester.pumpWidget(
      app(
        AccountsPage(
          accounts: [account],
          balanceFor: (_) => 1000,
          invoiceSummaryFor: (_, _) => throw UnimplementedError(),
          availableFor: (_) => 0,
          onAdd: (_) {},
          onDelete: (value) => deleted = value,
          onOpen: (_) {},
        ),
      ),
    );

    await tester.tap(find.byTooltip('Ações de Conta principal'));
    await tester.pumpAndSettle();
    expect(find.text('Excluir conta'), findsOneWidget);
    await tester.tap(find.text('Excluir conta'));
    await tester.pumpAndSettle();

    expect(deleted, same(account));
  });

  testWidgets('installment actions expose individual and future deletion', (
    tester,
  ) async {
    (FinanceTransaction, bool)? deletion;
    final installment = FinanceTransaction(
      id: 'part-2',
      name: 'Notebook',
      category: 'Compras',
      amount: 200,
      date: DateTime(2026, 9, 1),
      dueDate: DateTime(2026, 9, 10),
      type: 'expense',
      accountId: account.id,
      installmentGroupId: 'series',
      installmentNumber: 2,
      installmentCount: 10,
    );
    await tester.pumpWidget(
      app(
        TransactionsPage(
          transactions: [installment],
          accounts: [account],
          onEdit: (_) {},
          onDelete: (item, future) async => deletion = (item, future),
          onPaid: (_) {},
        ),
      ),
    );

    await tester.tap(find.byTooltip('Ações da transação'));
    await tester.pumpAndSettle();
    expect(find.text('Excluir somente esta'), findsOneWidget);
    expect(find.text('Excluir esta e as futuras'), findsOneWidget);
    await tester.tap(find.text('Excluir esta e as futuras'));
    await tester.pumpAndSettle();

    expect(deletion?.$1, same(installment));
    expect(deletion?.$2, isTrue);
    expect(tester.takeException(), isNull);
  });
}
