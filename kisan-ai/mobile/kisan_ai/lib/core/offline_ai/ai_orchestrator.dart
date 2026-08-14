import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:kisan_ai/core/config/api_config.dart';

final aiOrchestratorProvider = Provider<AIOrchestrator>((ref) {
  return AIOrchestrator();
});

class AIOrchestrator {
  static const String _ollamaUrl = 'http://localhost:11434/api/generate';
  static const String _localMistralModel = 'mistral:7b-instruct-q4_K_M';

  final http.Client _httpClient = http.Client();

  /// Generates text. If offline, uses Mistral via Ollama localhost. If online, uses Groq.
  Future<String> generateText(String prompt, {bool isOnline = true}) async {
    if (isOnline) {
      return _generateOnline(prompt);
    } else {
      return _generateOffline(prompt);
    }
  }

  /// Generate text using Groq API (online)
  Future<String> _generateOnline(String prompt) async {
    try {
      // Call backend Groq integration endpoint
      final response = await _httpClient
          .post(
            Uri.parse('${ApiConfig.baseUrl}/api/chatbot/generate'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'prompt': prompt,
              'model': 'mixtral-8x7b-32768',
              'temperature': 0.7,
              'max_tokens': 500,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] ?? 'No response generated';
      } else {
        throw Exception('Groq API error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to generate text online: $e');
    }
  }

  /// Generate text using local Ollama Mistral API (offline)
  Future<String> _generateOffline(String prompt) async {
    try {
      // Check if Ollama is running locally
      final response = await _httpClient
          .post(
            Uri.parse(_ollamaUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'model': _localMistralModel,
              'prompt': prompt,
              'temperature': 0.7,
              'stream': false,
            }),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] ?? 'No response generated';
      } else {
        throw Exception('Ollama error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(
        'Failed to generate text offline (is Ollama running?): $e',
      );
    }
  }

  /// Analyzes a crop image for disease using the TFLite model via backend
  Future<Map<String, dynamic>> analyzeDisease(File image) async {
    try {
      // Read image and convert to base64
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Send to backend disease detection endpoint
      final response = await _httpClient
          .post(
            Uri.parse(
              '${ApiConfig.baseUrl}${ApiConfig.diseaseEndpoint}/detect',
            ),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'image': base64Image,
              'crop_type':
                  'general', // Can be enhanced with user's selected crop
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'disease': data['disease'] ?? 'Unknown',
          'confidence': data['confidence'] ?? 0.0,
          'treatment':
              data['treatment'] ?? 'Consult with an agricultural expert',
          'severity': data['severity'] ?? 'unknown',
        };
      } else {
        throw Exception('Disease detection error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to analyze disease: $e');
    }
  }

  /// Clean up resources
  void dispose() {
    _httpClient.close();
  }
}
