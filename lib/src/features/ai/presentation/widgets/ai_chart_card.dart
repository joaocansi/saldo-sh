import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../app/app_theme.dart';
import '../../domain/ai_chart.dart';

class AIChartCard extends StatelessWidget {
  const AIChartCard({super.key, required this.snapshot});

  final AIChartSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      container: true,
      label: _semanticLabel(),
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          border: Border.all(color: colors.outlineVariant),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.insert_chart_outlined_rounded,
                  size: 19,
                  color: colors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        snapshot.title,
                        style: Theme.of(context).textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        snapshot.subtitle,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!snapshot.hasData || !_supports(snapshot))
              const _EmptyChart()
            else
              _ChartBody(snapshot: snapshot),
          ],
        ),
      ),
    );
  }

  String _semanticLabel() {
    final totals = snapshot.series
        .map(
          (series) =>
              '${series.label}: ${_moneyCents(series.points.fold(0, (sum, point) => sum + point.valueCents))}',
        )
        .join('; ');
    return 'Gráfico ${snapshot.title}. ${snapshot.subtitle}. $totals';
  }
}

class _ChartBody extends StatelessWidget {
  const _ChartBody({required this.snapshot});

  final AIChartSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final chart = switch (snapshot.kind) {
      AIChartKind.incomeExpense => _IncomeExpenseChart(snapshot: snapshot),
      AIChartKind.cashFlow => _CashFlowChart(snapshot: snapshot),
      AIChartKind.categorySpending => _CategoryChart(snapshot: snapshot),
      AIChartKind.budgetUsage => _BudgetChart(snapshot: snapshot),
      AIChartKind.invoiceEvolution => _InvoiceChart(snapshot: snapshot),
    };
    if ({
      AIChartKind.categorySpending,
      AIChartKind.budgetUsage,
    }.contains(snapshot.kind)) {
      return chart;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SeriesLegend(series: snapshot.series),
        const SizedBox(height: 10),
        chart,
      ],
    );
  }
}

bool _supports(AIChartSnapshot snapshot) {
  final roles = snapshot.series.map((series) => series.role).toSet();
  return switch (snapshot.kind) {
    AIChartKind.incomeExpense =>
      roles.contains('income') && roles.contains('expense'),
    AIChartKind.cashFlow => roles.contains('balance'),
    AIChartKind.categorySpending => roles.contains('category'),
    AIChartKind.budgetUsage =>
      roles.contains('spent') && roles.contains('limit'),
    AIChartKind.invoiceEvolution =>
      roles.contains('paid') && roles.contains('remaining'),
  };
}

class _IncomeExpenseChart extends StatelessWidget {
  const _IncomeExpenseChart({required this.snapshot});

  final AIChartSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final income = snapshot.series.firstWhere((item) => item.role == 'income');
    final expense = snapshot.series.firstWhere(
      (item) => item.role == 'expense',
    );
    final finance = _financeColors(context);
    final maximum = [
      ...income.points.map((point) => point.valueCents),
      ...expense.points.map((point) => point.valueCents),
    ].fold<int>(1, math.max).toDouble();
    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          maxY: maximum * 1.18,
          alignment: BarChartAlignment.spaceAround,
          barGroups: [
            for (var index = 0; index < income.points.length; index++)
              BarChartGroupData(
                x: index,
                barsSpace: 4,
                barRods: [
                  _bar(income.points[index].valueCents, finance.income),
                  _bar(
                    index < expense.points.length
                        ? expense.points[index].valueCents
                        : 0,
                    finance.expense,
                  ),
                ],
              ),
          ],
          titlesData: _titles(
            context,
            income.points.map((point) => point.label).toList(),
          ),
          gridData: _grid(context),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                '${rodIndex == 0 ? 'Entradas' : 'Saídas'}\n${_money(rod.toY)}',
                TextStyle(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CashFlowChart extends StatelessWidget {
  const _CashFlowChart({required this.snapshot});

  final AIChartSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final points = snapshot.series.first.points;
    final values = points.map((point) => point.valueCents.toDouble()).toList();
    var minimum = values.fold<double>(0, math.min);
    var maximum = values.fold<double>(0, math.max);
    final range = math.max(100.0, maximum - minimum);
    minimum -= range * .12;
    maximum += range * .12;
    final color = _financeColors(context).income;
    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          minY: minimum,
          maxY: maximum,
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var index = 0; index < points.length; index++)
                  FlSpot(index.toDouble(), points[index].valueCents.toDouble()),
              ],
              color: color,
              barWidth: 3,
              isCurved: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: color.withValues(alpha: .12),
              ),
            ),
          ],
          titlesData: _titles(
            context,
            points.map((point) => point.label).toList(),
          ),
          gridData: _grid(context),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => spots
                  .map(
                    (spot) => LineTooltipItem(
                      _money(spot.y),
                      TextStyle(
                        color: Theme.of(context).colorScheme.onInverseSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryChart extends StatelessWidget {
  const _CategoryChart({required this.snapshot});

  final AIChartSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final points = snapshot.series.first.points
        .where((point) => point.valueCents > 0)
        .toList();
    final palette = _palette(context);
    final total = points.fold<int>(0, (sum, point) => sum + point.valueCents);
    final chart = SizedBox(
      width: 190,
      height: 190,
      child: PieChart(
        PieChartData(
          centerSpaceRadius: 48,
          sectionsSpace: 2,
          sections: [
            for (var index = 0; index < points.length; index++)
              PieChartSectionData(
                value: points[index].valueCents.toDouble(),
                color: palette[index % palette.length],
                radius: 34,
                showTitle: total > 0 && points[index].valueCents / total >= .08,
                title: '${(points[index].valueCents * 100 / total).round()}%',
                titleStyle: TextStyle(
                  color: Theme.of(context).colorScheme.surface,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
          ],
        ),
      ),
    );
    final legend = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < points.length; index++)
          Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: _LegendItem(
              color: palette[index % palette.length],
              label: points[index].label,
              value: _moneyCents(points[index].valueCents),
            ),
          ),
      ],
    );
    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxWidth < 460
          ? Column(children: [chart, const SizedBox(height: 8), legend])
          : Row(
              children: [
                chart,
                const SizedBox(width: 18),
                Expanded(child: legend),
              ],
            ),
    );
  }
}

class _BudgetChart extends StatelessWidget {
  const _BudgetChart({required this.snapshot});

  final AIChartSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final spent = snapshot.series.firstWhere((item) => item.role == 'spent');
    final limits = snapshot.series.firstWhere((item) => item.role == 'limit');
    final finance = _financeColors(context);
    return Column(
      children: [
        for (var index = 0; index < spent.points.length; index++)
          Builder(
            builder: (context) {
              final limit = index < limits.points.length
                  ? limits.points[index].valueCents
                  : 0;
              final value = spent.points[index].valueCents;
              final ratio = limit <= 0 ? 0.0 : value / limit;
              final color = ratio > 1 ? finance.expense : finance.income;
              return Padding(
                padding: const EdgeInsets.only(bottom: 13),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            spent.points[index].label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_moneyCents(value)} / ${_moneyCents(limit)}',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        minHeight: 9,
                        value: ratio.clamp(0, 1),
                        color: color,
                        backgroundColor: color.withValues(alpha: .13),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

class _InvoiceChart extends StatelessWidget {
  const _InvoiceChart({required this.snapshot});

  final AIChartSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final paid = snapshot.series.firstWhere((item) => item.role == 'paid');
    final remaining = snapshot.series.firstWhere(
      (item) => item.role == 'remaining',
    );
    final finance = _financeColors(context);
    final totals = <int>[
      for (var index = 0; index < paid.points.length; index++)
        paid.points[index].valueCents +
            (index < remaining.points.length
                ? remaining.points[index].valueCents
                : 0),
    ];
    final maximum = totals.fold<int>(1, math.max).toDouble();
    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          maxY: maximum * 1.18,
          barGroups: [
            for (var index = 0; index < paid.points.length; index++)
              BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: totals[index].toDouble(),
                    width: 20,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(5),
                    ),
                    rodStackItems: [
                      BarChartRodStackItem(
                        0,
                        paid.points[index].valueCents.toDouble(),
                        finance.income,
                      ),
                      BarChartRodStackItem(
                        paid.points[index].valueCents.toDouble(),
                        totals[index].toDouble(),
                        finance.expense,
                      ),
                    ],
                  ),
                ],
              ),
          ],
          titlesData: _titles(
            context,
            paid.points.map((point) => point.label).toList(),
          ),
          gridData: _grid(context),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                'Pago: ${_moneyCents(paid.points[group.x].valueCents)}\n'
                'Em aberto: ${_moneyCents(group.x < remaining.points.length ? remaining.points[group.x].valueCents : 0)}',
                TextStyle(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 7),
      Expanded(
        child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      const SizedBox(width: 8),
      Text(value, style: Theme.of(context).textTheme.labelSmall),
    ],
  );
}

class _SeriesLegend extends StatelessWidget {
  const _SeriesLegend({required this.series});

  final List<AIChartSeries> series;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 14,
    runSpacing: 7,
    children: [
      for (final item in series)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: _roleColor(context, item.role),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(item.label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
    ],
  );
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart();

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 120,
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.query_stats_rounded,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 7),
          const Text('Não há dados suficientes para este gráfico.'),
        ],
      ),
    ),
  );
}

BarChartRodData _bar(int valueCents, Color color) => BarChartRodData(
  toY: valueCents.toDouble(),
  color: color,
  width: 12,
  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
);

FlTitlesData _titles(BuildContext context, List<String> labels) => FlTitlesData(
  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
  leftTitles: AxisTitles(
    sideTitles: SideTitles(
      showTitles: true,
      reservedSize: 48,
      getTitlesWidget: (value, meta) => Text(
        _compactMoney(value),
        style: Theme.of(context).textTheme.labelSmall,
      ),
    ),
  ),
  bottomTitles: AxisTitles(
    sideTitles: SideTitles(
      showTitles: true,
      reservedSize: 28,
      getTitlesWidget: (value, meta) {
        final index = value.round();
        if (index < 0 || index >= labels.length || value != index) {
          return const SizedBox.shrink();
        }
        return SideTitleWidget(
          meta: meta,
          child: Text(
            _shortPeriod(labels[index]),
            style: Theme.of(context).textTheme.labelSmall,
          ),
        );
      },
    ),
  ),
);

FlGridData _grid(BuildContext context) => FlGridData(
  drawVerticalLine: false,
  horizontalInterval: null,
  getDrawingHorizontalLine: (value) => FlLine(
    color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: .55),
    strokeWidth: 1,
  ),
);

List<Color> _palette(BuildContext context) {
  final finance = _financeColors(context);
  final colors = Theme.of(context).colorScheme;
  return [
    finance.expense,
    finance.warning,
    finance.transfer,
    finance.installment,
    finance.food,
    finance.leisure,
    colors.primary,
    colors.secondary,
  ];
}

Color _roleColor(BuildContext context, String role) {
  final finance = _financeColors(context);
  return switch (role) {
    'income' || 'balance' || 'paid' => finance.income,
    'expense' || 'remaining' => finance.expense,
    'spent' => finance.warning,
    _ => Theme.of(context).colorScheme.primary,
  };
}

FinanceColors _financeColors(BuildContext context) {
  final theme = Theme.of(context);
  return theme.extension<FinanceColors>() ??
      FinanceColors.forPlatform(theme.platform, theme.brightness);
}

String _shortPeriod(String value) {
  final match = RegExp(r'^(\d{4})-(\d{2})$').firstMatch(value);
  if (match == null) return value.length <= 7 ? value : value.substring(0, 7);
  const names = [
    'jan',
    'fev',
    'mar',
    'abr',
    'mai',
    'jun',
    'jul',
    'ago',
    'set',
    'out',
    'nov',
    'dez',
  ];
  final month = int.parse(match.group(2)!);
  return names[month - 1];
}

String _compactMoney(double cents) {
  final value = cents / 100;
  if (value.abs() >= 1000000) {
    return 'R\$ ${(value / 1000000).toStringAsFixed(1)} mi';
  }
  if (value.abs() >= 1000)
    return 'R\$ ${(value / 1000).toStringAsFixed(1)} mil';
  return 'R\$ ${value.toStringAsFixed(0)}';
}

String _money(double cents) => _moneyCents(cents.round());

String _moneyCents(int cents) {
  final value = cents / 100;
  final fixed = value.abs().toStringAsFixed(2).replaceAll('.', ',');
  return '${value < 0 ? '-' : ''}R\$ $fixed';
}
