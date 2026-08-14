import 'package:http/http.dart' as http;
import 'dart:convert';

/// Service for offline AI chat using Ollama
class OfflineChatService {
  static const String _ollamaUrl = 'http://localhost:11434/api/generate';
  
  /// Check if Ollama is available
  Future<bool> isOllamaAvailable() async {
    try {
      final response = await http
          .get(Uri.parse('http://localhost:11434'))
          .timeout(const Duration(seconds: 2));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
  
  /// Send message to Ollama and stream response
  Stream<String> sendMessage(
    String message, {
    required String farmerName,
    required String crop,
    required String language,
  }) async* {
    try {
      if (!await isOllamaAvailable()) {
        yield 'Error: Ollama not running. Please start with: ollama run mistral';
        return;
      }
      
      final prompt = _buildPrompt(message, farmerName, crop, language);
      
      final request = http.StreamedRequest(
        'POST',
        Uri.parse(_ollamaUrl),
      );
      
      request.headers['Content-Type'] = 'application/json';
      request.add(
        utf8.encode(jsonEncode({
          'model': 'mistral:7b',
          'prompt': prompt,
          'stream': true,
        })),
      );
      
      final response = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Request timeout'),
      );
      
      if (response.statusCode != 200) {
        yield 'Error: ${response.statusCode}';
        return;
      }
      
      await for (final chunk in response.stream.transform(utf8.decoder).transform(const LineSplitter())) {
        try {
          if (chunk.isEmpty) continue;
          final json = jsonDecode(chunk);
          if (json['response'] != null) {
            yield json['response'] as String;
          }
        } catch (_) {
          // Skip malformed JSON
        }
      }
    } catch (e) {
      yield 'Error: $e';
    }
  }
  
  /// Build agricultural prompt
  String _buildPrompt(
    String message,
    String name,
    String crop,
    String language,
  ) {
    return '''You are KisanAI, helping Indian farmers with agriculture.

Farmer: $name
Crop: $crop
Language: $language

IMPORTANT:
1. Respond in $language only
2. Be brief (2-3 sentences)
3. If asked about live prices/weather: "I'm offline. Please connect to internet for current data."
4. Give practical farming advice
5. Consider local practices

Question: $message

Answer:''';
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  
  @override
  String toString() => message;
}
