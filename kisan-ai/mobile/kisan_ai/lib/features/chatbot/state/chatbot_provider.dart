import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan_ai/core/config/api_config.dart';
import 'package:kisan_ai/core/network/api_client.dart';
import 'package:kisan_ai/features/chatbot/services/chatbot_service.dart';
import 'package:kisan_ai/shared/models/chat_model.dart';
import 'package:kisan_ai/features/auth/repository/auth_repository.dart';

/// Provider for ApiClient - cached and reused
/// This ensures the same client instance is used for all requests
final chatbotApiClientProvider = Provider<ApiClient>((ref) {
  final apiClient = ApiClient(ApiConfig.baseUrl);
  // Set the token if available (synchronously)
  // Token refresh will be handled separately if needed
  return apiClient;
});

/// Provider for ChatbotService - uses cached ApiClient
final chatbotServiceProvider = FutureProvider<ChatbotService>((ref) async {
  final apiClient = ref.watch(chatbotApiClientProvider);

  // Try to get auth token and set it
  try {
    final authRepo = ref.watch(authRepositoryProvider);
    final accessToken = await authRepo.getAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      apiClient.setToken(accessToken);
    }
  } catch (e) {
    // Continue without token if auth fails
    print('⚠️ Failed to get auth token: $e');
  }

  return ChatbotService(apiClient);
});

/// Provider for sending a message and getting AI response
final sendMessageProvider = FutureProvider.family<ChatMessage, ChatMessage>((
  ref,
  message,
) async {
  final service = await ref.read(chatbotServiceProvider.future);
  
  // Try to get language from the selectedLanguageProvider if it exists
  // For the family provider, it's safer to pass it directly, but since this is used 
  // without the language parameter, we can default it or get it from context elsewhere.
  // Actually, we'll let the UI call service.sendMessage directly so it can pass the language.
  return service.sendMessage(message);
});
