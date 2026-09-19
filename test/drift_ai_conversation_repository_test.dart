import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_application_1/core/database/app_database.dart';
import 'package:flutter_application_1/features/ai/data/drift_ai_conversation_repository.dart';
import 'package:flutter_application_1/features/ai/domain/ai_conversation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late DriftAIConversationRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftAIConversationRepository(database);
  });

  tearDown(() => database.close());

  test(
    'stores, orders and deletes local conversations with their messages',
    () async {
      final first = await repository.createConversation('Primeira conversa');
      await repository.addMessage(
        AIStoredMessage(
          id: 'message-1',
          conversationId: first.id,
          role: 'user',
          content: 'Qual é meu saldo?',
          createdAt: DateTime(2026, 9, 12, 10),
        ),
      );
      await repository.addMessage(
        AIStoredMessage(
          id: 'message-2',
          conversationId: first.id,
          role: 'assistant',
          content: '**Saldo:** R\$ 1.000',
          createdAt: DateTime(2026, 9, 12, 10, 1),
          metadata: const {
            'usage': {'input_tokens': 10, 'output_tokens': 4},
          },
        ),
      );
      final second = await repository.createConversation('Conversa mais nova');
      await repository.addMessage(
        AIStoredMessage(
          id: 'message-3',
          conversationId: second.id,
          role: 'user',
          content: 'Analise meu orçamento.',
          createdAt: DateTime(2026, 9, 12, 11),
        ),
      );

      final conversations = await repository.readConversations();
      expect(conversations.map((item) => item.id), [second.id, first.id]);
      final messages = await repository.readMessages(first.id);
      expect(messages.map((item) => item.content), [
        'Qual é meu saldo?',
        '**Saldo:** R\$ 1.000',
      ]);
      expect(messages.last.metadata['usage'], isA<Map>());

      await repository.updateMessageMetadata('message-2', const {
        'context': {'state': 'confirmed'},
      });
      final updated = await repository.readMessages(first.id);
      expect(updated.last.metadata['context'], {'state': 'confirmed'});

      await repository.deleteConversation(first.id);
      expect(await repository.readMessages(first.id), isEmpty);
      expect((await repository.readConversations()).map((item) => item.id), [
        second.id,
      ]);
    },
  );

  test('factory data clear also removes local AI history', () async {
    final conversation = await repository.createConversation('Temporária');
    await repository.addMessage(
      AIStoredMessage(
        id: 'message',
        conversationId: conversation.id,
        role: 'user',
        content: 'Teste',
        createdAt: DateTime.now(),
      ),
    );

    await database.clearAllUserData();

    expect(await repository.readConversations(), isEmpty);
    expect(await repository.readMessages(conversation.id), isEmpty);
  });

  test(
    'migrates an existing schema from version 1 without data loss',
    () async {
      await database.close();
      final directory = await Directory.systemTemp.createTemp(
        'saldo-chat-migration-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final file = File('${directory.path}/migration.sqlite');
      var migrated = AppDatabase.forTesting(NativeDatabase(file));
      await migrated.customSelect('SELECT 1').get();
      await migrated.customStatement('DROP TABLE ai_chat_messages');
      await migrated.customStatement('DROP TABLE ai_conversations');
      await migrated.customStatement('PRAGMA user_version = 1');
      await migrated.close();

      migrated = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(migrated.close);
      final migratedRepository = DriftAIConversationRepository(migrated);
      final conversation = await migratedRepository.createConversation(
        'Depois da migração',
      );

      expect(
        (await migratedRepository.readConversations()).single.id,
        conversation.id,
      );
    },
  );
}
