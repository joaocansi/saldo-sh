abstract interface class AIToolAudit {
  Future<void> record({
    required String toolName,
    required Iterable<String> argumentNames,
    required bool success,
  });
}
