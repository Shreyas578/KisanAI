import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan_ai/shared/models/chat_model.dart';

/// State notifier for managing chat messages across the app
/// This replaces local setState and ensures messages persist during navigation
class ChatMessageNotifier extends StateNotifier<List<ChatMessage>> {
  ChatMessageNotifier() : super([]);

  /// Add a user message
  void addUserMessage(String text) {
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: 'default_conversation',
      senderId: 'user',
      senderName: 'You',
      isFromBot: false,
      messageType: 'text',
      content: text,
      timestamp: DateTime.now(),
      isRead: true,
    );
    state = [...state, message];
  }

  /// Add a bot message
  void addBotMessage(String content) {
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: 'default_conversation',
      senderId: 'bot',
      senderName: 'Kisan AI',
      isFromBot: true,
      messageType: 'text',
      content: content,
      timestamp: DateTime.now(),
      isRead: true,
    );
    state = [...state, message];
  }

  /// Update the last message (used for streaming responses)
  void updateLastMessage(String content) {
    if (state.isEmpty) return;
    final messages = [...state];
    final lastMsg = messages[messages.length - 1];
    messages[messages.length - 1] = ChatMessage(
      id: lastMsg.id,
      conversationId: lastMsg.conversationId,
      senderId: lastMsg.senderId,
      senderName: lastMsg.senderName,
      isFromBot: lastMsg.isFromBot,
      messageType: lastMsg.messageType,
      content: content,
      timestamp: lastMsg.timestamp,
      isRead: lastMsg.isRead,
    );
    state = messages;
  }

  /// Clear all messages
  void clearMessages() {
    state = [];
  }

  /// Get message count
  int getMessageCount() => state.length;

  /// Get all messages
  List<ChatMessage> getMessages() => state;
}

/// Provider for chat message notifier
final chatMessageNotifierProvider =
    StateNotifierProvider<ChatMessageNotifier, List<ChatMessage>>((ref) {
      return ChatMessageNotifier();
    });

/// Provider for loading state during API calls
final chatLoadingProvider = StateProvider<bool>((ref) => false);

/// Provider for transcription text during voice input
final liveTranscriptProvider = StateProvider<String>((ref) => '');

/// Provider for selected language
final selectedLanguageProvider = StateProvider<String>((ref) => 'en');

/// Provider for auto-read setting
final autoReadBotRepliesProvider = StateProvider<bool>((ref) => true);

/// Provider for current speaking state
final isSpeakingProvider = StateProvider<bool>((ref) => false);

/// Provider for current listening state
final isListeningProvider = StateProvider<bool>((ref) => false);
