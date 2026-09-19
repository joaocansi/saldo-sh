class FinanceAccount {
  FinanceAccount({
    required this.id,
    required this.name,
    required String kind,
    required this.openingBalance,
    this.limit = 0,
    this.closingDay = 1,
    this.dueDay = 10,
    this.archived = false,
  }) : kind = canonicalAccountKind(kind);

  factory FinanceAccount.fromJson(Map<String, dynamic> json) {
    final rawKind = json['kind'] as String? ?? 'account';
    return FinanceAccount(
      id:
          json['id']?.toString() ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      name: json['name'] as String? ?? 'Conta',
      kind: rawKind,
      openingBalance:
          (json['openingBalance'] as num?)?.toDouble() ??
          (json['balance'] as num?)?.toDouble() ??
          0,
      limit: (json['limit'] as num?)?.toDouble() ?? 0,
      closingDay: json['closingDay'] as int? ?? 1,
      dueDay: json['dueDay'] as int? ?? 10,
      archived: json['archived'] as bool? ?? false,
    );
  }

  final String id, name, kind;
  final double openingBalance, limit;
  final int closingDay, dueDay;
  final bool archived;
  bool get isCard => kind == 'card';

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'kind': kind,
    'openingBalance': openingBalance,
    'limit': limit,
    'closingDay': closingDay,
    'dueDay': dueDay,
    'archived': archived,
  };
}

String canonicalAccountKind(String value) {
  final normalized = value
      .trim()
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('à', 'a')
      .replaceAll('â', 'a')
      .replaceAll('ã', 'a')
      .replaceAll('é', 'e')
      .replaceAll('ê', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ô', 'o')
      .replaceAll('õ', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ç', 'c')
      .replaceAll(RegExp(r'[\s_-]+'), ' ');
  if ({
    'card',
    'credit card',
    'creditcard',
    'cartao',
    'cartao de credito',
  }.contains(normalized)) {
    return 'card';
  }
  if ({'cash', 'wallet', 'carteira', 'dinheiro'}.contains(normalized)) {
    return 'cash';
  }
  if ({
    'account',
    'bank account',
    'conta',
    'conta bancaria',
  }.contains(normalized)) {
    return 'account';
  }
  return normalized;
}
