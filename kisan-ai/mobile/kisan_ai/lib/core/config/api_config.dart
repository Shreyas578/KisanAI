/// API Configuration - Centralized endpoint management
class ApiConfig {
  // Backend base URL - Can be changed via environment
  // Local development: http://localhost:3000
  // Production: Use ngrok URL or deployed server
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue:
        'https://95e8-116-74-189-34.ngrok-free.app',
  );

  // API endpoints
  static const String authEndpoint = '$baseUrl/api/auth';
  static const String priceEndpoint = '$baseUrl/api/price';
  static const String diseaseEndpoint = '$baseUrl/api/disease';
  static const String weatherEndpoint = '$baseUrl/api/weather';
  static const String chatbotEndpoint = '$baseUrl/api/chatbot';
  static const String farmReportEndpoint = '$baseUrl/api/farm-report';
  static const String marketplaceEndpoint = '$baseUrl/api/marketplace';
  static const String cropEndpoint = '$baseUrl/api/crops';
  static const String orderEndpoint = '$baseUrl/api/order';
  static const String inputEndpoint = '$baseUrl/api/input';
  static const String governmentSchemeEndpoint = '$baseUrl/api/government-schemes';
  static const String notificationEndpoint = '$baseUrl/api/notifications';
  static const String newsEndpoint = '$baseUrl/api/news';
  static const String paymentEndpoint = '$baseUrl/api/payments';

  // API Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Retry configuration
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
}
