import '../domain/models.dart';

class RecurrenceService {
  const RecurrenceService();

  Iterable<FinanceTransaction> project(
    FinanceRecurrence recurrence, {
    required DateTime from,
    required DateTime through,
    Iterable<FinanceTransaction> persisted = const [],
  }) sync* {
    if (!recurrence.isActive || through.isBefore(from)) return;
    final existing = {
      for (final item in persisted.where(
        (item) => item.seriesId == recurrence.id,
      ))
        FinanceRecurrence.occurrenceKey(item.date),
    };
    var index = _firstCandidateIndex(recurrence, from);
    while (true) {
      final date = occurrenceAt(recurrence, index);
      if (date.isAfter(through)) break;
      if (recurrence.endsOn != null && date.isAfter(recurrence.endsOn!)) break;
      final key = FinanceRecurrence.occurrenceKey(date);
      if (!date.isBefore(recurrence.startsOn) &&
          !date.isBefore(from) &&
          !recurrence.excludedOccurrenceKeys.contains(key) &&
          !existing.contains(key)) {
        yield transactionAt(recurrence, index, projected: true);
      }
      index++;
    }
  }

  /// Generates only occurrences whose financial due date is inside the
  /// requested interval. The first candidate is calculated arithmetically, so
  /// a month decades in the future does not require walking every prior item.
  Iterable<FinanceTransaction> projectDueBetween(
    FinanceRecurrence recurrence, {
    required DateTime from,
    required DateTime through,
    Iterable<FinanceTransaction> persisted = const [],
  }) sync* {
    if (!recurrence.isActive || through.isBefore(from)) return;
    final existing = {
      for (final item in persisted.where(
        (item) => item.seriesId == recurrence.id,
      ))
        FinanceRecurrence.occurrenceKey(item.date),
    };
    var index = _firstDueCandidateIndex(recurrence, from);
    while (true) {
      final transaction = transactionAt(recurrence, index, projected: true);
      if (transaction.dueDate.isAfter(through)) break;
      if (recurrence.endsOn != null &&
          transaction.date.isAfter(recurrence.endsOn!)) {
        break;
      }
      final key = FinanceRecurrence.occurrenceKey(transaction.date);
      if (!transaction.dueDate.isBefore(from) &&
          !recurrence.excludedOccurrenceKeys.contains(key) &&
          !existing.contains(key)) {
        yield transaction;
      }
      index++;
    }
  }

  DateTime occurrenceAt(FinanceRecurrence recurrence, int index) =>
      switch (recurrence.frequency) {
        'daily' => _addCalendarDays(recurrence.startsOn, index),
        'weekly' => _addCalendarDays(recurrence.startsOn, index * 7),
        'yearly' => _addYears(recurrence.startsOn, index),
        _ => addMonths(recurrence.startsOn, index),
      };

  FinanceTransaction transactionAt(
    FinanceRecurrence recurrence,
    int index, {
    required bool projected,
    String status = 'planned',
  }) {
    final template = recurrence.template;
    final date = occurrenceAt(recurrence, index);
    final dueDate = switch (recurrence.frequency) {
      'monthly' => addMonths(template.dueDate, index),
      'yearly' => _addYears(template.dueDate, index),
      _ => _addCalendarDays(
        date,
        _calendarDayDifference(template.dueDate, template.date),
      ),
    };
    return FinanceTransaction(
      id: 'recurrence:${recurrence.id}:${FinanceRecurrence.occurrenceKey(date)}',
      name: template.name,
      category: template.category,
      amount: template.amount,
      date: date,
      dueDate: dueDate,
      type: template.type,
      accountId: template.accountId,
      targetAccountId: template.targetAccountId,
      status: status,
      notes: template.notes,
      recurrence: recurrence.frequency,
      seriesId: recurrence.id,
      projected: projected,
    );
  }

  int _firstCandidateIndex(FinanceRecurrence recurrence, DateTime from) {
    if (!from.isAfter(recurrence.startsOn)) return 0;
    return switch (recurrence.frequency) {
      'daily' => _calendarDayDifference(from, recurrence.startsOn),
      'weekly' => _calendarDayDifference(from, recurrence.startsOn) ~/ 7,
      'yearly' => (from.year - recurrence.startsOn.year).clamp(0, 1000000),
      _ =>
        ((from.year - recurrence.startsOn.year) * 12 +
                from.month -
                recurrence.startsOn.month)
            .clamp(0, 12000000),
    };
  }

  int _firstDueCandidateIndex(FinanceRecurrence recurrence, DateTime from) {
    final firstDueDate = recurrence.template.dueDate;
    if (!from.isAfter(firstDueDate)) return 0;
    final candidate = switch (recurrence.frequency) {
      'daily' => _calendarDayDifference(from, firstDueDate),
      'weekly' => _calendarDayDifference(from, firstDueDate) ~/ 7,
      'yearly' => from.year - firstDueDate.year,
      _ =>
        (from.year - firstDueDate.year) * 12 + from.month - firstDueDate.month,
    };
    return candidate < 0 ? 0 : candidate;
  }

  DateTime _addYears(DateTime date, int years) {
    final year = date.year + years;
    final lastDay = DateTime(year, date.month + 1, 0).day;
    return DateTime(year, date.month, date.day.clamp(1, lastDay));
  }

  DateTime _addCalendarDays(DateTime date, int days) =>
      DateTime(date.year, date.month, date.day + days);

  int _calendarDayDifference(DateTime left, DateTime right) => DateTime.utc(
    left.year,
    left.month,
    left.day,
  ).difference(DateTime.utc(right.year, right.month, right.day)).inDays;
}
