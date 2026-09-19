import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/app_theme.dart';
import 'package:flutter_application_1/features/finance/presentation/pages/budgets_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget app() => MaterialApp(
    theme: AppTheme.build(Brightness.light),
    home: Scaffold(
      body: BudgetsPage(
        budgets: const [],
        transactions: const [],
        onSave: (_) {},
        onDelete: (_) {},
      ),
    ),
  );

  testWidgets('empty budgets page explains the feature and opens creation', (
    tester,
  ) async {
    await tester.pumpWidget(app());

    expect(find.text('Planeje antes de gastar'), findsOneWidget);
    expect(find.text('Criar primeiro orçamento'), findsOneWidget);
    expect(
      find.textContaining('Defina limites mensais por categoria'),
      findsOneWidget,
    );

    await tester.tap(find.text('Criar primeiro orçamento'));
    await tester.pumpAndSettle();

    expect(find.text('Novo orçamento'), findsOneWidget);
    expect(find.text('Categoria'), findsOneWidget);
    expect(find.text('Limite mensal'), findsOneWidget);
  });
}
