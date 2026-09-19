abstract interface class AIConversationRepository {
  Future<List<AIConversation>> readConversations();

  Future<List<AIStoredMessage>> readMessages(String conversationId);

  Future<AIConversation> createConversation(String title);

  Future<void> addMessage(AIStoredMessage message);

  Future<void> updateMessageMetadata(
    String messageId,
    Map<String, dynamic> metadata,
  );

  Future<void> deleteConversation(String conversationId);
}

class AIConversation {
  const AIConversation({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class AIStoredMessage {
  const AIStoredMessage({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.createdAt,
    this.metadata = const {},
  });

  final String id;
  final String conversationId;
  final String role;
  final String content;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;
}
