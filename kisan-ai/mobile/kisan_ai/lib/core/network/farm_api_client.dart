import 'package:dio/dio.dart';
import '../models/farm_models.dart';
import '../models/market_models.dart';
import '../models/report_models.dart';
import '../config/api_config.dart';

class FarmApiClient {
  final Dio _dio;
  final String baseUrl;

  FarmApiClient(this._dio, {String? customBaseUrl})
    : baseUrl = customBaseUrl ?? '${ApiConfig.baseUrl}/api' {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = ApiConfig.connectionTimeout;
    _dio.options.receiveTimeout = ApiConfig.receiveTimeout;
  }

  // ============= FARM PROFILE ENDPOINTS =============

  Future<ApiResponse<FarmProfileResponse>> createFarmProfile(
    String userId,
    FarmProfileRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/farm-profile/$userId',
        data: request.toJson(),
      );
      return ApiResponse<FarmProfileResponse>.fromJson(
        response.data,
        (json) => FarmProfileResponse.fromJson(json),
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        error: e.message ?? 'Failed to create farm profile',
      );
    }
  }

  Future<ApiResponse<FarmProfileResponse>> getFarmProfile(String userId) async {
    try {
      final response = await _dio.get('/farm-profile/$userId');
      return ApiResponse<FarmProfileResponse>.fromJson(
        response.data,
        (json) => FarmProfileResponse.fromJson(json),
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        error: e.message ?? 'Failed to get farm profile',
      );
    }
  }

  // ============= CROP ENDPOINTS =============

  Future<ApiResponse<CropResponse>> addCrop(
    String farmProfileId,
    CropRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/farm-profile/$farmProfileId/crop',
        data: request.toJson(),
      );
      return ApiResponse<CropResponse>.fromJson(
        response.data,
        (json) => CropResponse.fromJson(json),
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        error: e.message ?? 'Failed to add crop',
      );
    }
  }

  Future<ApiResponse<List<CropResponse>>> getFarmCrops(
    String farmProfileId,
  ) async {
    try {
      final response = await _dio.get('/farm-profile/$farmProfileId/crops');
      return ApiResponse<List<CropResponse>>.fromJson(
        response.data,
        (json) =>
            (json as List).map((item) => CropResponse.fromJson(item)).toList(),
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        error: e.message ?? 'Failed to get farm crops',
      );
    }
  }

  Future<ApiResponse<List<CropMaster>>> getAllCrops() async {
    try {
      final response = await _dio.get('/farm-profile/crops/all');
      return ApiResponse<List<CropMaster>>.fromJson(
        response.data,
        (json) =>
            (json as List).map((item) => CropMaster.fromJson(item)).toList(),
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        error: e.message ?? 'Failed to get crops',
      );
    }
  }

  Future<ApiResponse<List<CropMaster>>> searchCrops(String query) async {
    try {
      final response = await _dio.get(
        '/farm-profile/crops/search',
        queryParameters: {'q': query},
      );
      return ApiResponse<List<CropMaster>>.fromJson(
        response.data,
        (json) =>
            (json as List).map((item) => CropMaster.fromJson(item)).toList(),
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        error: e.message ?? 'Failed to search crops',
      );
    }
  }

  Future<ApiResponse<void>> updateCrop(
    String cropId,
    CropRequest request,
  ) async {
    try {
      final response = await _dio.put(
        '/farm-profile/crop/$cropId',
        data: request.toJson(),
      );
      return ApiResponse<void>(
        success: response.statusCode == 200,
        error: response.statusCode != 200 ? 'Failed to update crop' : null,
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        error: e.message ?? 'Failed to update crop',
      );
    }
  }

  // ============= FARM REPORT ENDPOINTS =============

  Future<ApiResponse<ReportResponse>> generate365DayPlan(
    String farmProfileId,
    String cropId,
  ) async {
    try {
      final response = await _dio.post(
        '/farm-report/generate-plan',
        data: {'farmProfileId': farmProfileId, 'cropId': cropId},
      );
      return ApiResponse<ReportResponse>.fromJson(
        response.data,
        (json) => ReportResponse.fromJson(json),
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        error: e.message ?? 'Failed to generate report',
      );
    }
  }

  // ============= MARKET INTELLIGENCE ENDPOINTS =============

  Future<ApiResponse<MarketData>> getMarketPrices(
    String commodity,
    String state,
  ) async {
    try {
      final response = await _dio.get(
        '/market-intelligence/prices',
        queryParameters: {'commodity': commodity, 'state': state},
      );
      return ApiResponse<MarketData>.fromJson(
        response.data,
        (json) => MarketData.fromJson(json),
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        error: e.message ?? 'Failed to get market prices',
      );
    }
  }

  Future<ApiResponse<PriceForecast>> getPriceForecast(
    String commodity,
    String state,
    int days,
  ) async {
    try {
      final response = await _dio.get(
        '/market-intelligence/forecast',
        queryParameters: {
          'commodity': commodity,
          'state': state,
          'days': days.toString(),
        },
      );
      return ApiResponse<PriceForecast>.fromJson(
        response.data,
        (json) => PriceForecast.fromJson(json),
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        error: e.message ?? 'Failed to get price forecast',
      );
    }
  }

  Future<ApiResponse<DemandScore>> getDemandScore(
    String commodity,
    int month,
  ) async {
    try {
      final response = await _dio.get(
        '/market-intelligence/demand-score',
        queryParameters: {'commodity': commodity, 'month': month.toString()},
      );
      return ApiResponse<DemandScore>.fromJson(
        response.data,
        (json) => DemandScore.fromJson(json),
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        error: e.message ?? 'Failed to get demand score',
      );
    }
  }

  // ============= CROP RECOMMENDATIONS ENDPOINTS =============

  Future<ApiResponse<RecommendationsResponse>> getCropRecommendations(
    String farmProfileId,
  ) async {
    try {
      final response = await _dio.get(
        '/farm-report/recommendations/$farmProfileId',
      );
      return ApiResponse<RecommendationsResponse>.fromJson(
        response.data,
        (json) => RecommendationsResponse.fromJson(json),
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        error: e.message ?? 'Failed to get recommendations',
      );
    }
  }

  // ============= ADDITIONAL ENDPOINTS =============

  Future<ApiResponse<List<ReportResponse>>> getFarmReports(
    String farmProfileId,
  ) async {
    try {
      final response = await _dio.get('/farm-report/all/$farmProfileId');
      return ApiResponse<List<ReportResponse>>.fromJson(
        response.data,
        (json) => (json as List)
            .map((item) => ReportResponse.fromJson(item))
            .toList(),
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        error: e.message ?? 'Failed to get farm reports',
      );
    }
  }

  Future<ApiResponse<SmartPriceSuggestion>> getSmartPrice(
    String commodity,
    String state,
  ) async {
    try {
      final response = await _dio.get(
        '/market-intelligence/smart-price',
        queryParameters: {'commodity': commodity, 'state': state},
      );
      return ApiResponse<SmartPriceSuggestion>.fromJson(
        response.data,
        (json) => SmartPriceSuggestion.fromJson(json),
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        error: e.message ?? 'Failed to get smart price',
      );
    }
  }

  Future<ApiResponse<List<PriceAlert>>> getUserPriceAlerts() async {
    try {
      final response = await _dio.get('/market-intelligence/alerts');
      return ApiResponse<List<PriceAlert>>.fromJson(
        response.data,
        (json) =>
            (json as List).map((item) => PriceAlert.fromJson(item)).toList(),
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        error: e.message ?? 'Failed to get price alerts',
      );
    }
  }
}
