class AIConversationContext {
  const AIConversationContext({
    this.recentTransactions = const [],
    this.recentAccounts = const [],
  });

  final List<AITransactionMemory> recentTransactions;
  final List<AIAccountMemory> recentAccounts;

  bool get isEmpty => recentTransactions.isEmpty && recentAccounts.isEmpty;
}

class AITransactionMemory {
  const AITransactionMemory({
    required this.name,
    required this.amountCents,
    required this.category,
    required this.type,
    required this.accountId,
    required this.purchaseDate,
    required this.confirmed,
    this.targetAccountId,
  });

  final String name;
  final int amountCents;
  final String category;
  final String type;
  final String accountId;
  final String? targetAccountId;
  final DateTime purchaseDate;
  final bool confirmed;
}

class AIAccountMemory {
  const AIAccountMemory({
    required this.name,
    required this.kind,
    required this.confirmed,
    this.accountId,
  });

  final String name;
  final String kind;
  final bool confirmed;
  final String? accountId;
}
