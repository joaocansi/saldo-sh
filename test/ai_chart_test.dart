import 'package:flutter_application_1/features/ai/domain/ai_chart.dart';
import 'package:flutter_application_1/features/ai/application/finance_chart_snapshot_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('chart snapshot round-trips without losing historical values', () {
    final original = AIChartSnapshot(
      kind: AIChartKind.cashFlow,
      title: 'Evolução do caixa',
      subtitle: 'Conta corrente',
      generatedAt: DateTime.utc(2026, 9, 12, 10),
      periodStart: '2026-09',
      periodEnd: '2027-02',
      accountName: 'Conta corrente',
      series: const [
        AIChartSeries(
          label: 'Caixa acumulado',
          role: 'balance',
          points: [
            AIChartPoint(label: '2026-09', valueCents: 350000),
            AIChartPoint(label: '2026-10', valueCents: 650000),
          ],
        ),
      ],
    );

    final restored = AIChartSnapshot.tryFromJson(original.toJson());

    expect(restored?.kind, AIChartKind.cashFlow);
    expect(restored?.generatedAt, original.generatedAt);
    expect(restored?.series.single.points.last.valueCents, 650000);
    expect(restored?.toJson(), original.toJson());
  });

  test('invalid or future chart schemas are ignored safely', () {
    expect(AIChartSnapshot.tryFromJson(null), isNull);
    expect(
      AIChartSnapshot.tryFromJson({
        'schema_version': 2,
        'kind': 'cash_flow',
      }),
      isNull,
    );
    expect(
      AIChartSnapshot.tryFromJson({
        'schema_version': 1,
        'kind': 'unknown',
        'title': '',
        'subtitle': '',
        'generated_at': '2026-09-12T10:00:00Z',
        'period_start': '',
        'period_end': '',
        'series': const [],
      }),
      isNull,
    );
  });

  test('controlled builder maps every supported financial operation', () {
    final builder = FinanceChartSnapshotBuilder(
      clock: () => DateTime.utc(2026, 9, 12),
    );
    final fixtures = <String, Map<String, dynamic>>{
      'compare_months': {
        'months': [
          {'month': '2026-09', 'income_cents': 500000, 'expense_cents': 200000},
        ],
      },
      'cash_flow': {
        'months': [
          {'month': '2026-09', 'ending_balance_cents': 300000},
        ],
      },
      'category_spending': {
        'month': '2026-09',
        'categories': {'Moradia': 200000},
      },
      'budget_status': {
        'month': '2026-09',
        'budgets': [
          {'category': 'Moradia', 'spent_cents': 200000, 'limit_cents': 250000},
        ],
      },
      'invoices': {
        'evolution': [
          {'month': '2026-09', 'paid_cents': 50000, 'remaining_cents': 70000},
        ],
      },
    };

    final snapshots = fixtures.entries
        .map((entry) => builder.build(entry.key, entry.value))
        .toList();

    expect(snapshots.map((snapshot) => snapshot.kind), AIChartKind.values);
    expect(snapshots.every((snapshot) => snapshot.hasData), isTrue);
    expect(
      () => builder.build('balance', const {}),
      throwsArgumentError,
    );
  });
}
