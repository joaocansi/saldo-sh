import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../domain/ai_tool_audit.dart';

class DriftAIToolAudit implements AIToolAudit {
  DriftAIToolAudit(this._database, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final AppDatabase _database;
  final Uuid _uuid;

  @override
  Future<void> record({
    required String toolName,
    required Iterable<String> argumentNames,
    required bool success,
  }) => _database
      .into(_database.aIToolAuditRecords)
      .insert(
        AIToolAuditRecordsCompanion.insert(
          id: _uuid.v4(),
          toolName: toolName,
          risk: toolName == 'prepare_transaction' ? 'draft' : 'read',
          argumentsSummary: jsonEncode({
            'fields': argumentNames.toList()..sort(),
          }),
          success: success,
          createdAt: DateTime.now().toUtc().millisecondsSinceEpoch,
        ),
      );
}
