import 'package:flutter/material.dart';
import 'package:saldo_sh/src/app/app_theme.dart';
import 'package:saldo_sh/src/core/presentation/widgets/app_select_field.dart';
import 'package:saldo_sh/src/features/finance/presentation/pages/accounts_page.dart';
import 'package:saldo_sh/src/features/finance/presentation/widgets/navigation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('select menu opens below its field and updates the value', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(420, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var selected = 'first';
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(Brightness.light),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 80),
                child: SizedBox(
                  width: 280,
                  child: AppSelectField<String>(
                    value: selected,
                    label: 'Opção',
                    options: const [
                      AppSelectOption(value: 'first', label: 'Primeira'),
                      AppSelectOption(value: 'second', label: 'Segunda'),
                    ],
                    onChanged: (value) => setState(() => selected = value),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final popupButton = tester.widget<PopupMenuButton<String>>(
      find.byType(PopupMenuButton<String>),
    );
    expect(popupButton.borderRadius, BorderRadius.circular(14));
    expect(popupButton.clipBehavior, Clip.antiAlias);
    final focusedShape = popupButton.style?.shape?.resolve({
      WidgetState.focused,
    });
    expect(
      (focusedShape as RoundedRectangleBorder).borderRadius,
      BorderRadius.circular(14),
    );

    final fieldRect = tester.getRect(find.byType(AppSelectField<String>));
    await tester.tap(find.byType(AppSelectField<String>));
    await tester.pumpAndSettle();

    final firstMenuItem = find.widgetWithText(
      PopupMenuItem<String>,
      'Primeira',
    );
    expect(firstMenuItem, findsOneWidget);
    expect(tester.getRect(firstMenuItem).top, greaterThan(fieldRect.bottom));

    await tester.tap(find.text('Segunda'));
    await tester.pumpAndSettle();
    expect(selected, 'second');
    expect(find.text('Segunda'), findsOneWidget);
  });

  testWidgets('header overflow menu opens below the three-dot button', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(420, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FinanceTopBar(
            desktop: false,
            dark: false,
            onTheme: () {},
            onPage: (_) {},
          ),
        ),
      ),
    );

    final buttonRect = tester.getRect(find.byIcon(Icons.more_horiz_rounded));
    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();

    final firstMenuItem = find.widgetWithText(PopupMenuItem<int>, 'Relatórios');
    expect(firstMenuItem, findsOneWidget);
    expect(tester.getRect(firstMenuItem).top, greaterThan(buttonRect.bottom));
  });

  testWidgets('select field can be laid out inside an alert dialog', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Novo cartão'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppSelectField<String>(
                          value: 'card',
                          label: 'Tipo',
                          options: const [
                            AppSelectOption(value: 'account', label: 'Conta'),
                            AppSelectOption(
                              value: 'card',
                              label: 'Cartão de crédito',
                            ),
                          ],
                          onChanged: (_) {},
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              child: const Text('Abrir'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    expect(find.text('Novo cartão'), findsOneWidget);
    expect(find.text('Cartão de crédito'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('new account dialog can switch to credit card', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AccountsPage(
            accounts: const [],
            balanceFor: (_) => 0,
            invoiceSummaryFor: (_, _) => throw UnimplementedError(),
            availableFor: (_) => 0,
            onAdd: (_) {},
            onDelete: (_) {},
            onOpen: (_) {},
          ),
        ),
      ),
    );

    await tester.tap(find.text('Nova'));
    await tester.pumpAndSettle();
    expect(find.text('Nova conta'), findsOneWidget);
    expect(find.byIcon(Icons.account_balance_rounded), findsOneWidget);

    await tester.tap(find.text('Conta'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cartão de crédito'));
    await tester.pumpAndSettle();

    expect(find.text('Novo cartão'), findsOneWidget);
    expect(find.byIcon(Icons.credit_card_rounded), findsOneWidget);
    expect(find.text('Limite total'), findsOneWidget);
    expect(find.text('Dia de fechamento'), findsOneWidget);
    expect(find.text('Dia de vencimento'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
