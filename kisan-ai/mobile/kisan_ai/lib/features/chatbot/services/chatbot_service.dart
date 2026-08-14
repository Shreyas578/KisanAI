import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:kisan_ai/core/network/api_client.dart';
import 'package:kisan_ai/shared/models/chat_model.dart';

/// Service for handling chatbot-related API calls
class ChatbotService {
  final ApiClient _apiClient;

  ChatbotService(this._apiClient);

  /// Send a message and get AI response
  Future<ChatMessage> sendMessage(ChatMessage message, {String language = 'en'}) async {
    try {
      // Convert to Groq-compatible format for the backend
      final groqMessages = [
        {
          'role': message.isFromBot ? 'assistant' : 'user',
          'content': message.content,
        },
      ];

      final response = await _apiClient.dio.post(
        '/api/chatbot/message',
        data: {
          'messages': groqMessages, 
          'temperature': 0.7, 
          'max_tokens': 512,
          'language': language,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Extract response from Groq API
        final botResponse =
            response.data['result'] ??
            response.data['message'] ??
            'I didn\'t understand that. Could you please rephrase?';
        return ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          conversationId: message.conversationId,
          senderId: 'bot',
          senderName: 'Agri Assistant',
          isFromBot: true,
          messageType: 'text',
          content: botResponse,
          timestamp: DateTime.now(),
          isRead: true,
        );
      } else {
        throw Exception(
          'Failed to send message: ${response.data['error'] ?? 'Unknown error'}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Upload media (for image/audio messages)
  Future<String> uploadMedia(Uint8List fileBytes, String fileName) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(fileBytes, filename: fileName),
      });

      final response = await _apiClient.dio.post(
        '/api/chatbot/upload',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['url'] ?? '';
      } else {
        throw Exception(
          'Failed to upload media: ${response.data['error'] ?? 'Unknown error'}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }
}
