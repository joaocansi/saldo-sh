import 'package:flutter_application_1/features/finance/application/recurrence_service.dart';
import 'package:flutter_application_1/features/finance/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = RecurrenceService();

  test('projects a daily recurrence directly in a distant month', () {
    final recurrence = FinanceRecurrence(
      id: 'daily',
      template: FinanceTransaction(
        id: 'daily-template',
        name: 'CafÃ©',
        category: 'AlimentaÃ§Ã£o',
        amount: 8,
        date: DateTime(2026, 1, 1),
        dueDate: DateTime(2026, 1, 1),
        type: 'expense',
        accountId: 'wallet',
        recurrence: 'daily',
        seriesId: 'daily',
      ),
      frequency: 'daily',
      startsOn: DateTime(2026, 1, 1),
    );

    final result = service
        .projectDueBetween(
          recurrence,
          from: DateTime(2126, 2, 1),
          through: DateTime(2126, 2, 28),
        )
        .toList();

    expect(result, hasLength(28));
    expect(result.first.date, DateTime(2126, 2, 1));
    expect(result.last.date, DateTime(2126, 2, 28));
    expect(result.every((item) => item.isProjection), isTrue);
  });

  test('uses the due month when projecting a distant card recurrence', () {
    final recurrence = FinanceRecurrence(
      id: 'card-monthly',
      template: FinanceTransaction(
        id: 'card-template',
        name: 'Assinatura',
        category: 'ServiÃ§os',
        amount: 30,
        date: DateTime(2026, 1, 31),
        dueDate: DateTime(2026, 3, 5),
        type: 'expense',
        accountId: 'card',
        recurrence: 'monthly',
        seriesId: 'card-monthly',
      ),
      frequency: 'monthly',
      startsOn: DateTime(2026, 1, 31),
    );

    final result = service
        .projectDueBetween(
          recurrence,
          from: DateTime(2126, 3, 1),
          through: DateTime(2126, 3, 31),
        )
        .toList();

    expect(result, hasLength(1));
    expect(result.single.date, DateTime(2126, 1, 31));
    expect(result.single.dueDate, DateTime(2126, 3, 5));
  });
}
