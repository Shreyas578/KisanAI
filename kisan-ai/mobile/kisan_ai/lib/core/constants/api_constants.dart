import 'package:kisan_ai/core/config/api_config.dart';

class ApiConstants {
  static const String baseUrl = ApiConfig.baseUrl; // Uses centralized ApiConfig

  // API endpoints
  static const String authRegister = '/api/auth/register';
  static const String authLogin = '/api/auth/login';
  static const String authRefresh = '/api/auth/refresh';
  static const String authLogout = '/api/auth/logout';
  static const String authFcmToken = '/api/auth/fcm-token';

  // Farmer routes
  static const String farmerProfile = '/api/farmer/profile';
  static const String farmerLocation = '/api/farmer/location';
  static const String farmerCrops = '/api/farmer/crops';
  static const String farmerReport = '/api/farmer/report';
  static const String farmerReportGenerate = '/api/farmer/report/generate';
  static const String farmReport = '/api/farm-report';
  static const String farmReportGenerate = '/api/farm-report/generate';
  static const String farmReportHistory = '/api/farm-report/history';
  static const String farmerCropSuggestion = '/api/farmer/crop-suggestion';

  // Weather routes
  static const String weatherCurrent = '/api/weather/current';
  static const String weatherForecast = '/api/weather/forecast';

  // Disease routes
  static const String diseaseDetect = '/api/disease/detect';
  static const String diseaseHistory = '/api/disease/history';

  // Market routes
  static const String marketPrices = '/api/market/prices';
  static const String marketMyCropsPrices = '/api/market/my-crops-prices';
  static const String marketNegotiationCoach = '/api/market/negotiation-coach';

  // Marketplace routes
  static const String marketplaceListings = '/api/marketplace/listings';
  static const String marketplaceMyListings = '/api/marketplace/my-listings';
  static const String marketplaceCreateListing = '/api/marketplace/listings';
  static const String marketplaceOrders = '/api/marketplace/orders';
  static const String marketplaceMyOrders = '/api/marketplace/orders';

  // Chatbot routes
  static const String chatbotMessage = '/api/chatbot/message';
  static const String chatbotTranscribe = '/api/chatbot/transcribe';
  static const String chatSendMessage = '/api/chatbot/send';
  static const String chatConversations = '/api/chatbot/conversations';
  static const String chatBots = '/api/chatbot/bots';
  static const String chatUploadMedia = '/api/chatbot/upload';

  // Government Scheme routes
  static const String governmentSchemes = '/api/government-schemes';
  static const String governmentSchemeApplications =
      '/api/government-schemes/applications';

  // Input Management routes
  static const String fertilizationSchedules = '/api/fertilization/schedules';
  static const String fertilizationApplications =
      '/api/fertilization/applications';
  static const String irrigationSchedules = '/api/irrigation/schedules';
  static const String irrigationExecutions = '/api/irrigation/executions';
  static const String pesticideSchedules = '/api/pesticide/schedules';
  static const String pesticideApplications = '/api/pesticide/applications';
  static const String orders = '/api/order';

  // Blockchain routes
  static const String blockchainListing = '/api/blockchain/listing';
  static const String blockchainOrder = '/api/blockchain/order';
  static const String blockchainHistory = '/api/blockchain/history';
}
