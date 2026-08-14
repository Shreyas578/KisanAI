class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId; // user ID or bot ID
  final String senderName;
  final String? senderAvatar; // URL or asset path
  final bool isFromBot; // true if message is from bot, false if from user
  final String messageType; // "text", "image", "audio", "video", "document"
  final String content; // text content or URL/media reference
  final Map<String, dynamic>? metadata; // additional data like sentiment, intent, etc.
  final DateTime timestamp;
  final bool isRead; // whether recipient has seen the message
  
  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.isFromBot,
    required this.messageType,
    required this.content,
    this.metadata,
    required this.timestamp,
    required this.isRead,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'conversationId': conversationId,
        'senderId': senderId,
        'senderName': senderName,
        'senderAvatar': senderAvatar,
        'isFromBot': isFromBot,
        'messageType': messageType,
        'content': content,
        'metadata': metadata,
        'timestamp': timestamp.toIso8601String(),
        'isRead': isRead,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'],
        conversationId: json['conversationId'],
        senderId: json['senderId'],
        senderName: json['senderName'],
        senderAvatar: json['senderAvatar'],
        isFromBot: json['isFromBot'],
        messageType: json['messageType'],
        content: json['content'],
        metadata: json['metadata'],
        timestamp: DateTime.parse(json['timestamp']),
        isRead: json['isRead'],
      );
}

class ChatConversation {
  final String id;
  final String userId;
  final String? agentId; // if chatting with specific agent/bot
  final String title; // conversation title or topic
  final String? subtitle;
  final DateTime createdAt;
  final DateTime lastActivityAt;
  final bool isArchived;
  final bool isPinned;
  final int unreadCount;
  final String? lastMessagePreview;
  final DateTime? lastMessageTimestamp;
  
  ChatConversation({
    required this.id,
    required this.userId,
    this.agentId,
    required this.title,
    this.subtitle,
    required this.createdAt,
    required this.lastActivityAt,
    required this.isArchived,
    required this.isPinned,
    required this.unreadCount,
    this.lastMessagePreview,
    this.lastMessageTimestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'agentId': agentId,
        'title': title,
        'subtitle': subtitle,
        'createdAt': createdAt.toIso8601String(),
        'lastActivityAt': lastActivityAt.toIso8601String(),
        'isArchived': isArchived,
        'isPinned': isPinned,
        'unreadCount': unreadCount,
        'lastMessagePreview': lastMessagePreview,
        'lastMessageTimestamp': lastMessageTimestamp?.toIso8601String(),
      };

  factory ChatConversation.fromJson(Map<String, dynamic> json) => ChatConversation(
        id: json['id'],
        userId: json['userId'],
        agentId: json['agentId'],
        title: json['title'],
        subtitle: json['subtitle'],
        createdAt: DateTime.parse(json['createdAt']),
        lastActivityAt: DateTime.parse(json['lastActivityAt']),
        isArchived: json['isArchived'],
        isPinned: json['isPinned'],
        unreadCount: json['unreadCount'],
        lastMessagePreview: json['lastMessagePreview'],
        lastMessageTimestamp: json['lastMessageTimestamp'] != null ? DateTime.parse(json['lastMessageTimestamp']) : null,
      );
}

class ChatBotConfig {
  final String id;
  final String name;
  final String description;
  final String avatarUrl;
  final String welcomeMessage;
  final List<String> suggestedQuestions;
  final Map<String, dynamic> capabilities; // what the bot can do
  final bool isEnabled;
  final String? specialization; // e.g., "disease_detection", "market_advice", "weather"
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  ChatBotConfig({
    required this.id,
    required this.name,
    required this.description,
    required this.avatarUrl,
    required this.welcomeMessage,
    required this.suggestedQuestions,
    required this.capabilities,
    required this.isEnabled,
    this.specialization,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'avatarUrl': avatarUrl,
        'welcomeMessage': welcomeMessage,
        'suggestedQuestions': suggestedQuestions,
        'capabilities': capabilities,
        'isEnabled': isEnabled,
        'specialization': specialization,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory ChatBotConfig.fromJson(Map<String, dynamic> json) => ChatBotConfig(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        avatarUrl: json['avatarUrl'],
        welcomeMessage: json['welcomeMessage'],
        suggestedQuestions: List<String>.from(json['suggestedQuestions']),
        capabilities: json['capabilities'],
        isEnabled: json['isEnabled'],
        specialization: json['specialization'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      );
}
