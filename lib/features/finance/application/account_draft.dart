/// An account proposal. IDs are assigned only when the user confirms the form.
class AccountDraft {
  const AccountDraft({
    required this.name,
    required this.kind,
    this.openingBalanceCents = 0,
    this.limitCents = 0,
    this.closingDay,
    this.dueDay,
  });

  final String name;
  final String kind;
  final int openingBalanceCents;
  final int limitCents;
  final int? closingDay;
  final int? dueDay;

  Map<String, dynamic> toJson() => {
    'name': name,
    'kind': kind,
    if (kind == 'card') ...{
      'limit_cents': limitCents,
      'closing_day': closingDay,
      'due_day': dueDay,
    } else
      'opening_balance_cents': openingBalanceCents,
  };

  static AccountDraft? tryFromJson(Object? source) {
    if (source is! Map) return null;
    final json = Map<String, dynamic>.from(source);
    final name = json['name'];
    final kind = json['kind'];
    if (name is! String || kind is! String) return null;
    return AccountDraft(
      name: name,
      kind: kind,
      openingBalanceCents:
          (json['opening_balance_cents'] as num?)?.toInt() ?? 0,
      limitCents: (json['limit_cents'] as num?)?.toInt() ?? 0,
      closingDay: (json['closing_day'] as num?)?.toInt(),
      dueDay: (json['due_day'] as num?)?.toInt(),
    );
  }
}
