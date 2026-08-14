import 'package:flutter/material.dart';
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
  static const String farmerCropSuggestion =
      '/api/farbonnet/farmer/crop-suggestion';

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

  // Blockchain routes
  static const String blockchainListing = '/api/blockchain/listing';
  static const String blockchainOrder = '/api/blockchain/order';
  static const String blockchainHistory = '/api/blockchain/history';
}

class LanguageConstants {
  static const Map<String, String> languageCodes = {
    'en': 'English',
    'hi': 'हिन्दी (Hindi)',
    'mr': 'मराठी (Marathi)',
    'ta': 'தமிழ் (Tamil)',
    'te': 'తెలుగు (Telugu)',
    'kn': 'ಕನ್ನಡ (Kannada)',
    'bn': 'বাংলা (Bengali)',
    'gu': 'ગુજરાતી (Gujarati)',
    'pa': 'ਪੰਜਾਬੀ (Punjabi)',
    'ml': 'മലയാളം (Malayalam)',
  };

  static const Map<String, String> languageCodesReverse = {
    'English': 'en',
    'हिन्दी (Hindi)': 'hi',
    'मराठी (Marathi)': 'mr',
    'தமிழ் (Tamil)': 'ta',
    'తెలుగు (Telugu)': 'te',
    'ಕನ್ನಡ (Kannada)': 'kn',
    'বাংলা (Bengali)': 'bn',
    'ગુજરાતી (Gujarati)': 'gu',
    'ਪੰਜਾਬੀ (Punjabi)': 'pa',
    'മലയാളം (Malayalam)': 'ml',
  };
}

class AppStrings {
  static String appName = 'Kisan AI';
  static String tagline = 'Your field. Your data. Your power.';

  // Common strings
  static String loading = 'Loading...';
  static String errorOccurred = 'An error occurred';
  static String tryAgain = 'Try Again';
  static String cancel = 'Cancel';
  static String ok = 'OK';
  static String yes = 'Yes';
  static String no = 'No';

  // Auth strings
  static String welcomeBack = 'Welcome Back';
  static String signInToContinue = 'Sign in to continue';
  static String phoneNumber = 'Phone Number';
  static String password = 'Password';
  static String forgotPin = 'Forgot PIN?';
  static String signIn = 'Sign In';
  static String or = 'OR';
  static String newToKisanAi = 'New to Kisan AI?';
  static String register = 'Register';

  // Onboarding strings
  static String yourFarm = 'Your Farm';
  static String farmSize = 'Farm Size';
  static String acres = 'acres';
  static String soilType = 'Soil Type';
  static String waterSource = 'Water Source';
  static String location = 'Location';
  static String state = 'State';
  static String district = 'District';
  static String village = 'Village';
  static String iDontHaveCropsYet = "I don't have crops yet";
  static String nextStep = 'Next →';

  static String language = 'Language';
  static String speakYourLanguage = 'Speak your language';
  static String kisanAIWillAdviseYouInThisLanguage =
      'Kisan AI will advise you in this language';
  static String english = 'English';
  static String hindi = 'Hindi';
  static String marathi = 'Marathi';
  static String tamil = 'Tamil';
  static String telugu = 'Telugu';
  static String kannada = 'Kannada';
  static String bengali = 'Bengali';
  static String gujarati = 'Gujarati';
  static String punjabi = 'Punjabi';
  static String malayalam = 'Malayalam';

  // Farmer home strings
  static String goodMorning = 'Good morning';
  static String goodAfternoon = 'Good afternoon';
  static String goodEvening = 'Good evening';
  static String farmHealth = 'Farm Health';
  static String satelliteUpdated = 'Satellite updated';
  static String daysAgo = 'days ago';
  static String viewFullAnalysis = 'View full analysis →';
  static String weather = 'Weather';
  static String marketPrices = 'Market Prices';
  static String farmReport = 'Farm Report';
  static String marketplace = 'Marketplace';
  static String scanDisease = 'Scan Disease';
  static String myCrops = 'My Crops';
  static String manage = 'Manage';
  static String regionalDiseaseAlert = 'Regional Disease Alert';
  static String inspectYour = 'Inspect your';
  static String viewPrecautions = 'View precautions →';
  static String todaysPrices = 'Today\'s Prices';

  // Disease scan strings
  static String cropDiseaseScan = 'Crop Disease Scan';
  static String tapToTakePhoto = 'Tap to take photo';
  static String orUploadFromGallery = 'or upload from gallery';
  static String cropName = 'Crop Name';
  static String hintCropName = 'e.g. Tomato, Wheat, Rice...';
  static String analyseDisease = 'Analyse Disease';

  // Disease result strings
  static String confidence = 'Confidence';
  static String severity = 'Severity';
  static String listenToAdvice = 'Listen to advice';
  static String immediateActions = 'Act Now';
  static String treatment = 'Treatment';
  static String organic = 'Organic';
  static String chemical = 'Chemical';
  static String prevention = 'Prevention';
  static String spreadRisk = 'Spread Risk';
  static String recoveryTimeline = 'Recovery Timeline';
  static String consultExpert = 'Consult Expert';

  // Market price strings
  static String mandiPrices = 'Mandi Prices';
  static String searchCommodity = 'Search commodity';
  static String stateFilter = 'State Filter';
  static String modal = 'Modal';
  static String min = 'Min';
  static String max = 'Max';
  static String rising = 'Rising';
  static String falling = 'Falling';
  static String priceIntelligence = 'Price Intelligence';
  static String bestMarket = 'Best Market';
  static String trend = 'Trend';
  static String sellRecommendation = 'Sell Recommendation';
  static String optimalWindow = 'Optimal Window';
  static String negotiationCoach = 'Negotiation Coach';

  // Farm report strings
  static String farmReportTitle = 'Farm Report';
  static String regenerate = 'Regenerate';
  static String summary = 'Summary';
  static String season = 'Season';
  static String overallFarmHealth = 'Overall Farm Health';
  static String profitMaximization = 'Profit Maximization';
  static String action = 'Action';
  static String expectedImpact = 'Expected Impact';
  static String timeline = 'Timeline';
  static String priority = 'Priority';
  static String estimatedCostInr = 'Estimated Cost (₹)';
  static String cropCalendar = 'Crop Calendar';
  static String irrigationSchedule = 'Irrigation Schedule';
  static String fertilizerSchedule = 'Fertilizer Schedule';
  static String pesticideSchedule = 'Pesticide Schedule';
  static String marketAdvice = 'Market Advice';
  static String yieldPrediction = 'Yield Prediction';
  static String alerts = 'Alerts';
  static String waterConservationTips = 'Water Conservation Tips';
  static String governmentSchemes = 'Government Schemes';
  static String soilHealthAdvice = 'Soil Health Advice';

  // Chatbot strings
  static String kisanMitra = 'Kisan Mitra';
  static String online = 'Online';
  static String onDeviceAI = 'On-device AI';
  static String typeHere = 'Type here...';
  static String send = 'Send';

  // NDVI strings
  static String satelliteAnalysis = 'Satellite Analysis';
  static String pointsPlaced = 'points placed';
  static String calculateNdvi = 'Calculate NDVI';
  static String satelliteDate = 'Satellite Date';
  static String interpretation = 'Interpretation';
  static String irrigate = 'Irrigate';
  static String fertilize = 'Fertilize';
  static String healthTrend = 'Health Trend';
  static String recommendations = 'Recommendations';
  static String monitoringFrequency = 'Monitoring Frequency';

  // Marketplace strings
  static String marketplaceTitle = 'Marketplace';
  static String all = 'All';
  static String produce = 'Produce';
  static String inputs = 'Inputs';
  static String verified = 'Verified';
  static String pricePerUnit = 'Price/unit';
  static String available = 'available';
  static String category = 'Category';
  static String quantityAvailable = 'Quantity available';
  static String createListing = 'Create Listing';
  static String listingType = 'Listing Type';
  static String farmProduce = 'Farm Produce';
  static String inputSupply = 'Input/Supply';
  static String basicDetails = 'Basic Details';
  static String title = 'Title';
  static String categoryLabel = 'Category';
  static String description = 'Description';
  static String quantityPricing = 'Quantity & Pricing';
  static String quantityInput = 'Quantity';
  static String unit = 'Unit';
  static String pricePerUnitInput = 'Price per unit';
  static String negotiable = 'Negotiable';
  static String qualityGrade = 'Quality Grade';
  static String locationLabel = 'Location';
  static String stateLabel = 'State';
  static String districtLabel = 'District';
  static String photosLabel = 'Photos';
  static String addPhotosButton = 'Add Photos';
  static String qualityBadgeSection = 'Quality Badge';
  static String attachFieldVerification = 'Attach Field Verification';
  static String includeNdviScore = 'Include NDVI score';
  static String includeDiseaseClearance = 'Include disease clearance';
  static String verifiedListingsInfo =
      'Verified listings get 40% more buyer interest';
  static String publishListing = 'Publish Listing →';

  // Orders strings
  static String myOrders = 'My Orders';
  static String buying = 'Buying';
  static String selling = 'Selling';
  static String received = 'Received';
  static String placed = 'Placed';
  static String status = 'Status';
  static String totalPrice = 'Total Price';
  static String confirmOrder = 'Confirm Order';
  static String viewOnBlockchain = 'View on Blockchain';
}

class AppConstants {
  static final Map<String, String> languageCodes =
      LanguageConstants.languageCodes;
  static final List<Locale> supportedLocales = languageCodes.keys
      .map((code) => Locale(code))
      .toList();
  static final String appName = AppStrings.appName;
  static final String tagline = AppStrings.tagline;
}
