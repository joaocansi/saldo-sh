class FinanceTransaction {
  FinanceTransaction({
    required this.id,
    required this.name,
    required this.category,
    required this.amount,
    required this.date,
    required this.dueDate,
    required this.type,
    required this.accountId,
    this.targetAccountId,
    this.status = 'paid',
    this.notes = '',
    this.recurrence = 'none',
    this.seriesId,
    this.installmentGroupId,
    this.installmentNumber = 1,
    this.installmentCount = 1,
    this.projected = false,
  });

  factory FinanceTransaction.fromJson(Map<String, dynamic> json) {
    final legacyIncome = json['income'] as bool?;
    return FinanceTransaction(
      id:
          json['id']?.toString() ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      name: json['name'] as String? ?? 'Lançamento',
      category: json['category'] as String? ?? 'Outros',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      dueDate:
          DateTime.tryParse(json['dueDate']?.toString() ?? '') ??
          DateTime.tryParse(json['date']?.toString() ?? '') ??
          DateTime.now(),
      type:
          json['type'] as String? ??
          (legacyIncome == true ? 'income' : 'expense'),
      accountId:
          json['accountId']?.toString() ??
          json['account']?.toString() ??
          'main',
      targetAccountId: json['targetAccountId']?.toString(),
      status: json['status'] as String? ?? 'paid',
      notes: json['notes'] as String? ?? '',
      recurrence: json['recurrence'] as String? ?? 'none',
      seriesId: json['seriesId']?.toString(),
      installmentGroupId: json['installmentGroupId']?.toString(),
      installmentNumber: json['installmentNumber'] as int? ?? 1,
      installmentCount:
          json['installmentCount'] as int? ?? json['installments'] as int? ?? 1,
    );
  }

  final String id, name, category, type, accountId, status, notes, recurrence;
  final String? targetAccountId, seriesId, installmentGroupId;
  final double amount;
  final DateTime date, dueDate;
  final int installmentNumber, installmentCount;
  final bool projected;

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';
  bool get isTransfer => type == 'transfer';
  bool get isCardPayment => type == 'cardPayment';
  bool get isPlanned => status == 'planned' || status == 'pending';
  bool get isInstallment => installmentCount > 1;
  bool get isRecurring => seriesId != null;
  bool get isProjection => projected;

  FinanceTransaction copyWith({
    String? name,
    String? category,
    double? amount,
    DateTime? date,
    DateTime? dueDate,
    String? type,
    String? accountId,
    String? targetAccountId,
    bool clearTargetAccountId = false,
    String? status,
    String? notes,
    bool? projected,
  }) => FinanceTransaction(
    id: id,
    name: name ?? this.name,
    category: category ?? this.category,
    amount: amount ?? this.amount,
    date: date ?? this.date,
    dueDate: dueDate ?? this.dueDate,
    type: type ?? this.type,
    accountId: accountId ?? this.accountId,
    targetAccountId: clearTargetAccountId
        ? null
        : targetAccountId ?? this.targetAccountId,
    status: status ?? this.status,
    notes: notes ?? this.notes,
    recurrence: recurrence,
    seriesId: seriesId,
    installmentGroupId: installmentGroupId,
    installmentNumber: installmentNumber,
    installmentCount: installmentCount,
    projected: projected ?? this.projected,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'amount': amount,
    'date': date.toIso8601String(),
    'dueDate': dueDate.toIso8601String(),
    'type': type,
    'accountId': accountId,
    'targetAccountId': targetAccountId,
    'status': status,
    'notes': notes,
    'recurrence': recurrence,
    'seriesId': seriesId,
    'installmentGroupId': installmentGroupId,
    'installmentNumber': installmentNumber,
    'installmentCount': installmentCount,
  };
}
