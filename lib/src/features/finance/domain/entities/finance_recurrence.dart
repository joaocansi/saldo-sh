import 'finance_transaction.dart';

class FinanceRecurrence {
  FinanceRecurrence({
    required this.id,
    required this.template,
    required this.frequency,
    required this.startsOn,
    this.endsOn,
    this.status = 'active',
    Set<String>? excludedOccurrenceKeys,
  }) : excludedOccurrenceKeys = Set.unmodifiable(
         excludedOccurrenceKeys ?? const <String>{},
       );

  final String id;
  final FinanceTransaction template;
  final String frequency;
  final DateTime startsOn;
  final DateTime? endsOn;
  final String status;
  final Set<String> excludedOccurrenceKeys;

  bool get isActive => status == 'active';

  bool excludes(DateTime date) =>
      excludedOccurrenceKeys.contains(occurrenceKey(date));

  FinanceRecurrence copyWith({
    FinanceTransaction? template,
    String? frequency,
    DateTime? startsOn,
    DateTime? endsOn,
    bool clearEndsOn = false,
    String? status,
    Set<String>? excludedOccurrenceKeys,
  }) => FinanceRecurrence(
    id: id,
    template: template ?? this.template,
    frequency: frequency ?? this.frequency,
    startsOn: startsOn ?? this.startsOn,
    endsOn: clearEndsOn ? null : endsOn ?? this.endsOn,
    status: status ?? this.status,
    excludedOccurrenceKeys:
        excludedOccurrenceKeys ?? this.excludedOccurrenceKeys,
  );

  Map<String, dynamic> toStorageJson() => {
    'version': 1,
    'template': template.toJson(),
    'excludedOccurrenceKeys': excludedOccurrenceKeys.toList()..sort(),
  };

  static String occurrenceKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
