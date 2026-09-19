enum AIChartKind {
  incomeExpense('income_expense'),
  cashFlow('cash_flow'),
  categorySpending('category_spending'),
  budgetUsage('budget_usage'),
  invoiceEvolution('invoice_evolution');

  const AIChartKind(this.wireName);

  final String wireName;

  static AIChartKind? fromWireName(Object? value) => values
      .where((kind) => kind.wireName == value)
      .firstOrNull;
}

class AIChartPoint {
  const AIChartPoint({required this.label, required this.valueCents});

  final String label;
  final int valueCents;

  Map<String, dynamic> toJson() => {
    'label': label,
    'value_cents': valueCents,
  };

  static AIChartPoint? tryFromJson(Object? source) {
    if (source is! Map) return null;
    final label = source['label'];
    final value = source['value_cents'];
    if (label is! String || value is! num) return null;
    return AIChartPoint(label: label, valueCents: value.toInt());
  }
}

class AIChartSeries {
  const AIChartSeries({
    required this.label,
    required this.role,
    required this.points,
  });

  final String label;
  final String role;
  final List<AIChartPoint> points;

  Map<String, dynamic> toJson() => {
    'label': label,
    'role': role,
    'points': points.map((point) => point.toJson()).toList(),
  };

  static AIChartSeries? tryFromJson(Object? source) {
    if (source is! Map) return null;
    final label = source['label'];
    final role = source['role'];
    final points = source['points'];
    if (label is! String || role is! String || points is! List) return null;
    return AIChartSeries(
      label: label,
      role: role,
      points: points
          .map(AIChartPoint.tryFromJson)
          .whereType<AIChartPoint>()
          .take(36)
          .toList(growable: false),
    );
  }
}

class AIChartSnapshot {
  const AIChartSnapshot({
    this.schemaVersion = 1,
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.generatedAt,
    required this.periodStart,
    required this.periodEnd,
    required this.series,
    this.accountName,
  });

  final int schemaVersion;
  final AIChartKind kind;
  final String title;
  final String subtitle;
  final DateTime generatedAt;
  final String periodStart;
  final String periodEnd;
  final String? accountName;
  final List<AIChartSeries> series;

  bool get hasData => series.any((item) => item.points.isNotEmpty);

  Map<String, dynamic> toJson() => {
    'schema_version': schemaVersion,
    'kind': kind.wireName,
    'title': title,
    'subtitle': subtitle,
    'generated_at': generatedAt.toUtc().toIso8601String(),
    'period_start': periodStart,
    'period_end': periodEnd,
    if (accountName != null) 'account_name': accountName,
    'series': series.map((item) => item.toJson()).toList(),
  };

  static AIChartSnapshot? tryFromJson(Object? source) {
    if (source is! Map) return null;
    final version = source['schema_version'];
    final kind = AIChartKind.fromWireName(source['kind']);
    final title = source['title'];
    final subtitle = source['subtitle'];
    final generatedAt = DateTime.tryParse(
      source['generated_at']?.toString() ?? '',
    );
    final periodStart = source['period_start'];
    final periodEnd = source['period_end'];
    final series = source['series'];
    if (version != 1 ||
        kind == null ||
        title is! String ||
        subtitle is! String ||
        generatedAt == null ||
        periodStart is! String ||
        periodEnd is! String ||
        series is! List) {
      return null;
    }
    return AIChartSnapshot(
      schemaVersion: 1,
      kind: kind,
      title: title,
      subtitle: subtitle,
      generatedAt: generatedAt,
      periodStart: periodStart,
      periodEnd: periodEnd,
      accountName: source['account_name'] is String
          ? source['account_name'] as String
          : null,
      series: series
          .map(AIChartSeries.tryFromJson)
          .whereType<AIChartSeries>()
          .take(4)
          .toList(growable: false),
    );
  }
}
