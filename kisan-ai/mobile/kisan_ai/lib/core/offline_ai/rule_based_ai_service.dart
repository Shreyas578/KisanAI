import 'dart:math';
import 'ai_service_base.dart';

/// Simple rule-based AI service as a fallback when no other models are available
class RuleBasedAiService extends BaseAiService {
  bool _isInitialized = false;
  bool _isDisposed = false;

  @override
  Future<void> initialize() async {
    if (_isDisposed) return;
    _isInitialized = true;
    // Simulate initialization delay
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<bool> isReady() => Future.value(_isInitialized && !_isDisposed);

  @override
  Future<String> completeText(String prompt,
      {int? maxTokens, double? temperature}) async {
    if (!await isReady()) {
      throw AiServiceException('Rule-based AI service not ready');
    }

    // Simple rule-based responses based on keywords in the prompt
    final lowerPrompt = prompt.toLowerCase();

    if (['crop', 'plant', 'grow', 'seed', 'harvest', 'farm', 'field', 'soil', 'water']
        .any((keyword) => lowerPrompt.contains(keyword))) {
      return _getAgricultureAdvice();
    } else if (['market', 'price', 'sell', 'buy', 'profit', 'cost']
        .any((keyword) => lowerPrompt.contains(keyword))) {
      return _getMarketAdvice();
    } else if (['weather', 'rain', 'sun', 'temperature', 'forecast']
        .any((keyword) => lowerPrompt.contains(keyword))) {
      return _getWeatherAdvice();
    } else if (['disease', 'pest', 'insect', 'fungus', 'virus', 'blight']
        .any((keyword) => lowerPrompt.contains(keyword))) {
      return _getDiseaseAdvice();
    } else {
      return _getGeneralResponse();
    }
  }

  @override
  Future<String> chatCompletion(List<Map<String, dynamic>> messages,
      {int? maxTokens, double? temperature}) async {
    if (!await isReady()) {
      throw AiServiceException('Rule-based AI service not ready');
    }

    // Get the last user message
    final lastUserMessage = messages
        .where((msg) => msg['role'] == 'user')
        .lastOrNull?
        ['content'] as String?;

    if (lastUserMessage == null) {
      return "I'm here to help with your farming questions. How can I assist you today?";
    }

    return await completeText(lastUserMessage);
  }

  @override
  Future<String> translateText(String text, String targetLanguage,
      [String? sourceLanguage]) async {
    // For the rule-based service, we just return a placeholder
    return 'Translation service not available in offline mode. Original text: $text';
  }

  @override
  Future<String> transcribeAudio(List<int> audioData) async {
    // For the rule-based service, we just return a placeholder
    return 'Speech-to-text service not available in offline mode.';
  }

  @override
  Future<void> dispose() async {
    _isDisposed = true;
    _isInitialized = false;
  }

  String _getAgricultureAdvice() {
    final advice = [
      'For optimal crop growth, ensure proper soil preparation and regular irrigation.',
      'Consider crop rotation to maintain soil health and reduce pest buildup.',
      'Use organic fertilizers like compost to improve soil structure and fertility.',
      'Monitor your crops regularly for early detection of pests and diseases.',
      'Water deeply but less frequently to encourage strong root development.',
      'Use mulch to retain soil moisture and suppress weeds.',
      'Consider planting cover crops during off-seasons to prevent soil erosion.',
    ];
    return advice[Random().nextInt(advice.length)];
  }

  String _getMarketAdvice() {
    final advice = [
      'Research local market prices before selling your produce.',
      'Consider joining a farmer\'s cooperative for better bargaining power.',
      'Explore direct-to-consumer sales channels like farmers\' markets.',
      'Keep track of your production costs to ensure profitable pricing.',
      'Consider value-added processing to increase product value.',
      'Build relationships with local restaurants and grocery stores.',
      'Use social media to market your products directly to consumers.',
    ];
    return advice[Random().nextInt(advice.length)];
  }

  String _getWeatherAdvice() {
    return 'For accurate weather forecasts, please consult a reliable weather service or application. In offline mode, detailed weather information is not available.';
  }

  String _getDiseaseAdvice() {
    final advice = [
      'Remove and destroy affected plant parts to prevent disease spread.',
      'Ensure proper spacing between plants for good air circulation.',
      'Apply appropriate fungicides or pesticides following manufacturer instructions.',
      'Practice crop rotation to reduce soil-borne disease buildup.',
      'Use resistant varieties when available.',
      'Monitor plants regularly for early signs of infection.',
      'Consult with local agricultural extension services for specific recommendations.',
    ];
    return advice[Random().nextInt(advice.length)];
  }

  String _getGeneralResponse() {
    final responses = [
      'I\'m here to help with your farming questions. Could you please provide more details?',
      'As an offline assistant, I can provide general agricultural advice. What specific information do you need?',
      'For complex queries requiring up-to-date information, please connect to the internet.',
      'I specialize in farming, agriculture, and rural livelihood topics. How can I assist you?',
    ];
    return responses[Random().nextInt(responses.length)];
  }
}