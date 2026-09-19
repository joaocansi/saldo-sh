import '../entities/finance_account.dart';
import '../entities/finance_budget.dart';
import '../entities/finance_transaction.dart';
import '../entities/finance_recurrence.dart';

abstract interface class FinanceRepository {
  Future<List<FinanceTransaction>> readTransactions();
  Future<List<FinanceAccount>> readAccounts();
  Future<List<FinanceBudget>> readBudgets();

  Future<void> saveTransactions(List<FinanceTransaction> items);
  Future<void> saveAccounts(List<FinanceAccount> items);
  Future<void> saveBudgets(List<FinanceBudget> items);

  Future<Map<String, DateTime>> readCardInvoiceTrackingStarts();
  Future<void> saveCardInvoiceTrackingStart(String cardId, DateTime month);

  Future<bool> readDarkTheme();
  Future<void> saveDarkTheme(bool value);
}

/// Optional persistence capability kept separate so lightweight repositories
/// (including tests and previews) do not need to know about recurrence rules.
abstract interface class RecurrenceRepository {
  Future<List<FinanceRecurrence>> readRecurrences();
  Future<void> saveRecurrences(List<FinanceRecurrence> items);
}
