import 'package:flutter/foundation.dart';

/// Enum representing different types of AI models available
enum AiModelType {
  /// Online models (API-based)
  groqLlama370b,
  groqMixtral8x22b,

  /// Offline models (local)
  mistral7bGguf,
  nllb200,
  whisperTiny,

  /// Fallback / utility models
  ruleBased,
}

/// Configuration for AI models
class AiModelConfig {
  final AiModelType type;
  final String name;
  final String description;
  final bool requiresInternet;
  final int maxTokens;
  final double temperature;

  const AiModelConfig({
    required this.type,
    required this.name,
    required this.description,
    required this.requiresInternet,
    this.maxTokens = 2048,
    this.temperature = 0.7,
  });

  /// Get the configuration for a specific model type
  static AiModelConfig of(AiModelType type) {
    switch (type) {
      case AiModelType.groqLlama370b:
        return AiModelConfig(
          type: type,
          name: 'Groq Llama 3 70B',
          description: 'High-performance language model via Groq API',
          requiresInternet: true,
          maxTokens: 4096,
          temperature: 0.7,
        );
      case AiModelType.groqMixtral8x22b:
        return AiModelConfig(
          type: type,
          name: 'Groq Mixtral 8x22B',
          description: 'Mixture of Experts model via Groq API',
          requiresInternet: true,
          maxTokens: 4096,
          temperature: 0.7,
        );
      case AiModelType.mistral7bGguf:
        return AiModelConfig(
          type: type,
          name: 'Mistral 7B GGUF',
          description: 'Quantized Mistral 7B model for offline use',
          requiresInternet: false,
          maxTokens: 2048,
          temperature: 0.7,
        );
      case AiModelType.nllb200:
        return AiModelConfig(
          type: type,
          name: 'NLLB-200',
          description: 'Multilingual translation model for offline use',
          requiresInternet: false,
          maxTokens: 512,
          temperature: 0.3,
        );
      case AiModelType.whisperTiny:
        return AiModelConfig(
          type: type,
          name: 'Whisper Tiny',
          description: 'Speech-to-text model for offline use',
          requiresInternet: false,
          maxTokens: 448, // Whisper uses audio frames, not tokens
          temperature: 0.0,
        );
      case AiModelType.ruleBased:
        return AiModelConfig(
          type: type,
          name: 'Rule-Based System',
          description: 'Fallback rule-based system for basic operations',
          requiresInternet: false,
          maxTokens: 128,
          temperature: 0.0,
        );
    }
  }
}

/// Abstract base class for AI service implementations
abstract class BaseAiService {
  /// Initialize the AI service
  Future<void> initialize();

  /// Check if the service is ready to process requests
  Future<bool> isReady();

  /// Process a text completion request
  Future<String> completeText(String prompt, {int? maxTokens, double? temperature});

  /// Process a chat completion request
  Future<String> chatCompletion(List<Map<String, dynamic>> messages, {int? maxTokens, double? temperature});

  /// Process a translation request
  Future<String> translateText(String text, String targetLanguage, String? sourceLanguage);

  /// Process a speech-to-text request
  Future<String> transcribeAudio(List<int> audioData);

  /// Clean up resources
  Future<void> dispose();
}

/// Exception thrown when AI services fail
class AiServiceException implements Exception {
  final String message;
  final String? code;

  const AiServiceException(this.message, [this.code]);

  @override
  String toString() => 'AiServiceException: $message${code != null ? ' (Code: $code)' : ''}';
}