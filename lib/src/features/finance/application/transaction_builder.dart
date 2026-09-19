import '../domain/models.dart';

import 'package:uuid/uuid.dart';

class TransactionDraft {
  const TransactionDraft({
    required this.name,
    required this.amount,
    required this.category,
    required this.type,
    required this.accountId,
    required this.date,
    required this.dueDate,
    required this.status,
    required this.mode,
    required this.recurrence,
    required this.installmentCount,
    required this.initialInstallment,
    this.targetAccountId,
    this.notes = '',
  });

  final String name;
  final double amount;
  final String category;
  final String type;
  final String accountId;
  final String? targetAccountId;
  final DateTime date;
  final DateTime dueDate;
  final String status;
  final String mode;
  final String recurrence;
  final int installmentCount;
  final int initialInstallment;
  final String notes;

  Map<String, dynamic> toJson() => {
    'name': name,
    'amount_cents': (amount * 100).round(),
    'category': category,
    'type': type,
    'account_id': accountId,
    if (targetAccountId != null) 'target_account_id': targetAccountId,
    'date': date.toIso8601String(),
    'due_date': dueDate.toIso8601String(),
    'status': status,
    'mode': mode,
    'recurrence': recurrence,
    'installment_count': installmentCount,
    'initial_installment': initialInstallment,
    'notes': notes,
  };

  static TransactionDraft? tryFromJson(Object? source) {
    if (source is! Map) return null;
    final json = Map<String, dynamic>.from(source);
    final name = json['name'];
    final amountCents = json['amount_cents'];
    final category = json['category'];
    final type = json['type'];
    final accountId = json['account_id'];
    final date = DateTime.tryParse(json['date']?.toString() ?? '');
    final dueDate = DateTime.tryParse(json['due_date']?.toString() ?? '');
    if (name is! String ||
        amountCents is! num ||
        category is! String ||
        type is! String ||
        accountId is! String ||
        date == null ||
        dueDate == null) {
      return null;
    }
    return TransactionDraft(
      name: name,
      amount: amountCents.toInt() / 100,
      category: category,
      type: type,
      accountId: accountId,
      targetAccountId: json['target_account_id'] as String?,
      date: date,
      dueDate: dueDate,
      status: json['status'] as String? ?? 'pending',
      mode: json['mode'] as String? ?? 'single',
      recurrence: json['recurrence'] as String? ?? 'none',
      installmentCount: (json['installment_count'] as num?)?.toInt() ?? 1,
      initialInstallment: (json['initial_installment'] as num?)?.toInt() ?? 1,
      notes: json['notes'] as String? ?? '',
    );
  }
}

class TransactionBuilder {
  const TransactionBuilder();

  DateTime dueDateFor(TransactionDraft draft, List<FinanceAccount> accounts) {
    final account = accounts
        .where((item) => item.id == draft.accountId)
        .firstOrNull;
    if (account == null || !account.isCard) return draft.dueDate;

    final closingMonthOffset = draft.date.day > account.closingDay ? 1 : 0;
    final closingMonth = addMonths(draft.date, closingMonthOffset);
    final dueMonthOffset = account.dueDay <= account.closingDay ? 1 : 0;
    final target = addMonths(closingMonth, dueMonthOffset);
    final lastDay = DateTime(target.year, target.month + 1, 0).day;
    return DateTime(
      target.year,
      target.month,
      account.dueDay.clamp(1, lastDay),
    );
  }

  List<FinanceTransaction> build(
    TransactionDraft draft,
    List<FinanceAccount> accounts, {
    FinanceTransaction? editing,
    String? generatedId,
  }) {
    final dueDate = dueDateFor(draft, accounts);
    if (editing != null) {
      return [
        editing.copyWith(
          name: draft.name,
          category: draft.category,
          amount: draft.amount,
          date: draft.date,
          dueDate: dueDate,
          type: draft.type,
          accountId: draft.accountId,
          targetAccountId: draft.targetAccountId,
          clearTargetAccountId: draft.targetAccountId == null,
          status: draft.status,
          notes: draft.notes,
        ),
      ];
    }

    final id = generatedId ?? const Uuid().v4();
    if (draft.mode == 'installment') {
      return [
        for (
          var number = draft.initialInstallment;
          number <= draft.installmentCount;
          number++
        )
          FinanceTransaction(
            id: '$id-$number',
            name: draft.name,
            category: draft.category,
            amount: draft.amount,
            date: addMonths(draft.date, number - draft.initialInstallment),
            dueDate: addMonths(dueDate, number - draft.initialInstallment),
            type: draft.type,
            accountId: draft.accountId,
            targetAccountId: draft.targetAccountId,
            status: number == draft.initialInstallment
                ? draft.status
                : 'planned',
            notes: draft.notes,
            installmentGroupId: id,
            installmentNumber: number,
            installmentCount: draft.installmentCount,
          ),
      ];
    }

    if (draft.mode == 'recurring') {
      // The controller persists a recurrence rule. This first occurrence is
      // only its template; future occurrences are projected on demand.
      return [_recurringTransaction(draft, dueDate, id, 0)];
    }

    return [
      FinanceTransaction(
        id: id,
        name: draft.name,
        category: draft.category,
        amount: draft.amount,
        date: draft.date,
        dueDate: dueDate,
        type: draft.type,
        accountId: draft.accountId,
        targetAccountId: draft.targetAccountId,
        status: draft.status,
        notes: draft.notes,
      ),
    ];
  }

  FinanceTransaction _recurringTransaction(
    TransactionDraft draft,
    DateTime baseDueDate,
    String id,
    int index,
  ) {
    final occurrence = switch (draft.recurrence) {
      'daily' => draft.date.add(Duration(days: index)),
      'weekly' => draft.date.add(Duration(days: index * 7)),
      'yearly' => DateTime(
        draft.date.year + index,
        draft.date.month,
        draft.date.day,
      ),
      _ => addMonths(draft.date, index),
    };
    final dueDate = draft.recurrence == 'monthly'
        ? addMonths(baseDueDate, index)
        : occurrence;
    return FinanceTransaction(
      id: '$id-$index',
      name: draft.name,
      category: draft.category,
      amount: draft.amount,
      date: occurrence,
      dueDate: dueDate,
      type: draft.type,
      accountId: draft.accountId,
      targetAccountId: draft.targetAccountId,
      status: index == 0 ? draft.status : 'planned',
      notes: draft.notes,
      recurrence: draft.recurrence,
      seriesId: id,
    );
  }
}
