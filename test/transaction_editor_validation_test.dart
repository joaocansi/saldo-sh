import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/app_theme.dart';
import 'package:flutter_application_1/features/finance/domain/models.dart';
import 'package:flutter_application_1/features/finance/presentation/widgets/transaction_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows required transaction errors directly in the fields', (
    tester,
  ) async {
    await _pumpEditor(tester, const []);

    await tester.tap(find.text('Salvar localmente'));
    await tester.pump();

    expect(find.text('Informe o nome da transação.'), findsOneWidget);
    expect(find.text('Informe o valor.'), findsOneWidget);
    expect(find.text('Selecione uma conta ou cartão.'), findsOneWidget);
    final errors = tester.widgetList<InputDecorator>(
      find.byType(InputDecorator),
    );
    expect(
      errors.where((item) => item.decoration.errorText != null),
      isNotEmpty,
    );
  });

  testWidgets('requires a destination account for transfers', (tester) async {
    await _pumpEditor(tester, [
      FinanceAccount(
        id: 'checking',
        name: 'Conta',
        kind: 'account',
        openingBalance: 0,
      ),
      FinanceAccount(
        id: 'savings',
        name: 'Reserva',
        kind: 'account',
        openingBalance: 0,
      ),
    ]);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nome da transação *'),
      'Transferência',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Valor *'),
      '100',
    );
    await tester.tap(find.text('Transferir'));
    await tester.pump();

    await tester.tap(find.text('Salvar localmente'));
    await tester.pump();

    expect(find.text('Selecione a conta de destino.'), findsOneWidget);
  });
}

Future<void> _pumpEditor(
  WidgetTester tester,
  List<FinanceAccount> accounts,
) async {
  await tester.binding.setSurfaceSize(const Size(520, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.build(Brightness.light),
      home: Scaffold(
        body: Builder(
          builder: (context) => FilledButton(
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (_) => TransactionEditor(accounts: accounts),
            ),
            child: const Text('Abrir'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Abrir'));
  await tester.pumpAndSettle();
}
