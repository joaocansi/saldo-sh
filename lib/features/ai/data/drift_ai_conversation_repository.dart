import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../domain/ai_conversation.dart';

class DriftAIConversationRepository implements AIConversationRepository {
  DriftAIConversationRepository(this._database, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  final AppDatabase _database;
  final Uuid _uuid;

  @override
  Future<List<AIConversation>> readConversations() async {
    final rows = await (_database.select(
      _database.aIConversationRecords,
    )..orderBy([(row) => OrderingTerm.desc(row.updatedAt)])).get();
    return [
      for (final row in rows)
        AIConversation(
          id: row.id,
          title: row.title,
          createdAt: _date(row.createdAt),
          updatedAt: _date(row.updatedAt),
        ),
    ];
  }

  @override
  Future<List<AIStoredMessage>> readMessages(String conversationId) async {
    final rows =
        await (_database.select(_database.aIChatMessageRecords)
              ..where((row) => row.conversationId.equals(conversationId))
              ..orderBy([(row) => OrderingTerm.asc(row.sequence)]))
            .get();
    return [
      for (final row in rows)
        AIStoredMessage(
          id: row.id,
          conversationId: row.conversationId,
          role: row.role,
          content: row.content,
          createdAt: _date(row.createdAt),
          metadata: _metadata(row.metadataJson),
        ),
    ];
  }

  @override
  Future<AIConversation> createConversation(String title) async {
    final now = DateTime.now().toUtc();
    final conversation = AIConversation(
      id: _uuid.v4(),
      title: title.trim(),
      createdAt: now,
      updatedAt: now,
    );
    await _database
        .into(_database.aIConversationRecords)
        .insert(
          AIConversationRecordsCompanion.insert(
            id: conversation.id,
            title: conversation.title,
            createdAt: now.millisecondsSinceEpoch,
            updatedAt: now.millisecondsSinceEpoch,
          ),
        );
    return conversation;
  }

  @override
  Future<void> addMessage(AIStoredMessage message) =>
      _database.transaction(() async {
        final maxSequence = _database.aIChatMessageRecords.sequence.max();
        final lastSequence =
            await (_database.selectOnly(_database.aIChatMessageRecords)
                  ..addColumns([maxSequence])
                  ..where(
                    _database.aIChatMessageRecords.conversationId.equals(
                      message.conversationId,
                    ),
                  ))
                .map((row) => row.read(maxSequence) ?? 0)
                .getSingle();
        final createdAt = message.createdAt.toUtc().millisecondsSinceEpoch;
        await _database
            .into(_database.aIChatMessageRecords)
            .insert(
              AIChatMessageRecordsCompanion.insert(
                id: message.id,
                conversationId: message.conversationId,
                role: message.role,
                content: message.content,
                metadataJson: Value(jsonEncode(message.metadata)),
                createdAt: createdAt,
                sequence: lastSequence + 1,
              ),
            );
        await (_database.update(_database.aIConversationRecords)
              ..where((row) => row.id.equals(message.conversationId)))
            .write(AIConversationRecordsCompanion(updatedAt: Value(createdAt)));
      });

  @override
  Future<void> updateMessageMetadata(
    String messageId,
    Map<String, dynamic> metadata,
  ) async {
    await (_database.update(
      _database.aIChatMessageRecords,
    )..where((row) => row.id.equals(messageId))).write(
      AIChatMessageRecordsCompanion(metadataJson: Value(jsonEncode(metadata))),
    );
  }

  @override
  Future<void> deleteConversation(String conversationId) =>
      _database.transaction(() async {
        await (_database.delete(
          _database.aIChatMessageRecords,
        )..where((row) => row.conversationId.equals(conversationId))).go();
        await (_database.delete(
          _database.aIConversationRecords,
        )..where((row) => row.id.equals(conversationId))).go();
      });

  Map<String, dynamic> _metadata(String source) {
    try {
      final decoded = jsonDecode(source);
      return decoded is Map<String, dynamic> ? decoded : const {};
    } on FormatException {
      return const {};
    }
  }

  DateTime _date(int milliseconds) =>
      DateTime.fromMillisecondsSinceEpoch(milliseconds, isUtc: true).toLocal();
}
