import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/finance_account.dart';
import '../../domain/entities/finance_budget.dart';
import '../../domain/entities/finance_transaction.dart';
import 'drift_finance_repository.dart';

class LegacyFinanceMigrator {
  LegacyFinanceMigrator(this.database, this.repository);

  static const _migrationKey = 'legacy_migration_v2';
  static const _themeKey = 'verde.dark-theme.v1';
  static const _financialKeys = [
    'verde.accounts.v2',
    'verde.accounts.v1',
    'verde.transactions.v2',
    'verde.transactions.v1',
    'verde.budgets.v2',
    'verde.budgets.v1',
  ];

  final AppDatabase database;
  final DriftFinanceRepository repository;

  Future<void> run() async {
    final preferences = await SharedPreferences.getInstance();
    final migrated = await (database.select(
      database.syncMetadata,
    )..where((row) => row.key.equals(_migrationKey))).getSingleOrNull();
    if (migrated != null) {
      await _cleanup(preferences);
      return;
    }

    final accounts = _decodeFirst(preferences, const [
      'verde.accounts.v2',
      'verde.accounts.v1',
    ], FinanceAccount.fromJson);
    final transactions = _decodeFirst(preferences, const [
      'verde.transactions.v2',
      'verde.transactions.v1',
    ], FinanceTransaction.fromJson);
    final budgets = _decodeFirst(preferences, const [
      'verde.budgets.v2',
      'verde.budgets.v1',
    ], FinanceBudget.fromJson);

    final accountIdsByLegacyName = {
      for (final account in accounts) account.name: account.id,
    };
    final normalizedTransactions = transactions.map((transaction) {
      final accountId =
          accountIdsByLegacyName[transaction.accountId] ??
          transaction.accountId;
      return accountId == transaction.accountId
          ? transaction
          : transaction.copyWith(accountId: accountId);
    }).toList();

    await repository.importLegacySnapshot(
      accounts: accounts,
      transactions: normalizedTransactions,
      budgets: budgets,
      darkTheme: preferences.getBool(_themeKey) ?? false,
    );

    await _cleanup(preferences);
  }

  Future<void> _cleanup(SharedPreferences preferences) async {
    for (final key in _financialKeys) {
      await preferences.remove(key);
    }
    await preferences.remove(_themeKey);
  }

  List<T> _decodeFirst<T>(
    SharedPreferences preferences,
    List<String> keys,
    T Function(Map<String, dynamic>) decode,
  ) {
    String? raw;
    for (final key in keys) {
      final candidate = preferences.getString(key);
      if (candidate != null && candidate.isNotEmpty) {
        raw = candidate;
        break;
      }
    }
    if (raw == null) return [];
    final json = jsonDecode(raw);
    if (json is! List) {
      throw const FormatException('Dados financeiros legados inválidos.');
    }
    return json
        .map((item) => decode(Map<String, dynamic>.from(item as Map)))
        .toList();
  }
}
