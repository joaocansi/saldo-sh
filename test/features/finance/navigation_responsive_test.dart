import 'package:flutter/material.dart';
import 'package:saldo_sh/src/features/finance/presentation/widgets/navigation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('desktop top bar occupies no space', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FinanceTopBar(
            desktop: true,
            dark: false,
            onTheme: () {},
            onPage: (_) {},
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(FinanceTopBar)).height, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sidebar scrolls instead of overflowing on a short window', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1100, 560));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.25)),
          child: Scaffold(
            body: Align(
              alignment: Alignment.centerLeft,
              child: FinanceSidebar(
                selected: 0,
                dark: false,
                displayName: 'João Guilherme da Silva',
                onTheme: () {},
                onSelect: (_) {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(Scrollbar), findsOneWidget);
    expect(find.text('Lembretes'), findsNothing);

    final sidebarRect = tester.getRect(find.byType(FinanceSidebar));
    final scrollbarRect = tester.getRect(find.byType(Scrollbar));
    expect(scrollbarRect.right, sidebarRect.right);
    expect(scrollbarRect.height, sidebarRect.height);

    final scrollbar = tester.widget<Scrollbar>(find.byType(Scrollbar));
    final scrollView = tester.widget<SingleChildScrollView>(
      find.byType(SingleChildScrollView),
    );
    expect(scrollbar.controller, same(scrollView.controller));

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -350),
    );
    await tester.pump();
    expect(find.text('Dados locais'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
