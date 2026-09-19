import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:saldo_sh/src/app/app_theme.dart';
import 'package:saldo_sh/src/features/ai/domain/ai_chart.dart';
import 'package:saldo_sh/src/features/ai/presentation/widgets/ai_chart_card.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders every controlled chart without overflowing on mobile', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final snapshot in _snapshots()) {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.build(
            Brightness.light,
            platform: TargetPlatform.android,
          ),
          darkTheme: AppTheme.build(
            Brightness.dark,
            platform: TargetPlatform.windows,
          ),
          themeMode: ThemeMode.dark,
          home: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              child: AIChartCard(snapshot: snapshot),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text(snapshot.title), findsOneWidget);
      expect(tester.takeException(), isNull, reason: snapshot.kind.name);
    }
  });

  testWidgets('uses native chart widgets and shows a safe empty state', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(
          Brightness.light,
          platform: TargetPlatform.windows,
        ),
        home: Scaffold(
          body: AIChartCard(snapshot: _snapshots().first),
        ),
      ),
    );
    expect(find.byType(BarChart), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(
          Brightness.light,
          platform: TargetPlatform.windows,
        ),
        home: Scaffold(
          body: AIChartCard(
            snapshot: AIChartSnapshot(
              kind: AIChartKind.cashFlow,
              title: 'Sem movimento',
              subtitle: 'Período vazio',
              generatedAt: DateTime.utc(2026, 9, 12),
              periodStart: '2026-09',
              periodEnd: '2026-09',
              series: const [
                AIChartSeries(label: 'Caixa', role: 'balance', points: []),
              ],
            ),
          ),
        ),
      ),
    );
    expect(
      find.text('Não há dados suficientes para este gráfico.'),
      findsOneWidget,
    );
  });
}

List<AIChartSnapshot> _snapshots() {
  final now = DateTime.utc(2026, 9, 12);
  const months = [
    AIChartPoint(label: '2026-09', valueCents: 300000),
    AIChartPoint(label: '2026-10', valueCents: -50000),
  ];
  return [
    AIChartSnapshot(
      kind: AIChartKind.incomeExpense,
      title: 'Entradas e saídas',
      subtitle: 'Comparação mensal',
      generatedAt: now,
      periodStart: '2026-09',
      periodEnd: '2026-10',
      series: const [
        AIChartSeries(label: 'Entradas', role: 'income', points: months),
        AIChartSeries(
          label: 'Saídas',
          role: 'expense',
          points: [
            AIChartPoint(label: '2026-09', valueCents: 180000),
            AIChartPoint(label: '2026-10', valueCents: 210000),
          ],
        ),
      ],
    ),
    AIChartSnapshot(
      kind: AIChartKind.cashFlow,
      title: 'Evolução do caixa',
      subtitle: 'Saldo acumulado',
      generatedAt: now,
      periodStart: '2026-09',
      periodEnd: '2026-10',
      series: const [
        AIChartSeries(label: 'Caixa', role: 'balance', points: months),
      ],
    ),
    AIChartSnapshot(
      kind: AIChartKind.categorySpending,
      title: 'Gastos por categoria',
      subtitle: 'Distribuição',
      generatedAt: now,
      periodStart: '2026-09',
      periodEnd: '2026-09',
      series: const [
        AIChartSeries(
          label: 'Despesas',
          role: 'category',
          points: [
            AIChartPoint(label: 'Moradia', valueCents: 180000),
            AIChartPoint(label: 'Alimentação', valueCents: 80000),
          ],
        ),
      ],
    ),
    AIChartSnapshot(
      kind: AIChartKind.budgetUsage,
      title: 'Consumo dos orçamentos',
      subtitle: 'Limites mensais',
      generatedAt: now,
      periodStart: '2026-09',
      periodEnd: '2026-09',
      series: const [
        AIChartSeries(
          label: 'Gasto',
          role: 'spent',
          points: [AIChartPoint(label: 'Moradia', valueCents: 180000)],
        ),
        AIChartSeries(
          label: 'Limite',
          role: 'limit',
          points: [AIChartPoint(label: 'Moradia', valueCents: 150000)],
        ),
      ],
    ),
    AIChartSnapshot(
      kind: AIChartKind.invoiceEvolution,
      title: 'Evolução das faturas',
      subtitle: 'Pagas e em aberto',
      generatedAt: now,
      periodStart: '2026-09',
      periodEnd: '2026-10',
      series: const [
        AIChartSeries(
          label: 'Pago',
          role: 'paid',
          points: [
            AIChartPoint(label: '2026-09', valueCents: 50000),
            AIChartPoint(label: '2026-10', valueCents: 30000),
          ],
        ),
        AIChartSeries(
          label: 'Em aberto',
          role: 'remaining',
          points: [
            AIChartPoint(label: '2026-09', valueCents: 70000),
            AIChartPoint(label: '2026-10', valueCents: 90000),
          ],
        ),
      ],
    ),
  ];
}
