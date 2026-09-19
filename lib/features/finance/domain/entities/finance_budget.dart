class FinanceBudget {
  FinanceBudget({
    required this.id,
    required this.category,
    required this.limit,
  });
  factory FinanceBudget.fromJson(Map<String, dynamic> json) => FinanceBudget(
    id: json['id']?.toString() ?? '',
    category: json['category'] as String? ?? 'Outros',
    limit: (json['limit'] as num?)?.toDouble() ?? 0,
  );
  final String id, category;
  final double limit;
  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category,
    'limit': limit,
  };
}
