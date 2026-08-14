import 'package:dio/dio.dart';
import 'package:kisan_ai/core/config/api_config.dart';
import 'package:kisan_ai/features/registration/models/registration_models.dart';

/// Registration Service - Handles all registration API calls
/// Manages the 5-screen registration flow with session tokens
class RegistrationService {
  final Dio _dio;

  RegistrationService(this._dio) {
    _dio.options.baseUrl = ApiConfig.baseUrl;
    _dio.options.connectTimeout = ApiConfig.connectionTimeout;
    _dio.options.receiveTimeout = ApiConfig.receiveTimeout;
  }

  // =====================================================================
  // SCREEN 1: PERSONAL DETAILS
  // =====================================================================

  /// Save personal details and get session token
  /// Returns session token to hold registration state
  Future<PersonalDetailsResponse> savePersonalDetails(
    PersonalDetailsRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/api/registration/personal-details',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return PersonalDetailsResponse.fromJson(response.data);
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        error: 'Unexpected status code: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // =====================================================================
  // SCREEN 2: FARM LOCATION
  // =====================================================================

  /// Save farm location (GPS or manual entry)
  /// Updates session token and returns geocoded data
  Future<FarmLocationResponse> saveFarmLocation(
    FarmLocationRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/api/registration/farm-location',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return FarmLocationResponse.fromJson(response.data);
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        error: 'Unexpected status code: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // =====================================================================
  // SCREEN 3: LAND DETAILS
  // =====================================================================

  /// Save land details (acres, soil, water, irrigation, etc.)
  /// Updates session token
  Future<LandDetailsResponse> saveLandDetails(
    LandDetailsRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/api/registration/land-details',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return LandDetailsResponse.fromJson(response.data);
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        error: 'Unexpected status code: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // =====================================================================
  // SCREEN 4: CROP SELECTION
  // =====================================================================

  /// Save crop selection (decided or not decided)
  /// Updates session token
  Future<CropSelectionResponse> saveCropSelection(
    CropSelectionRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/api/registration/crop-selection',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return CropSelectionResponse.fromJson(response.data);
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        error: 'Unexpected status code: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // =====================================================================
  // SCREEN 5: REVIEW & COMPLETE REGISTRATION
  // =====================================================================

  /// Get registration summary for review
  /// Called before final submission
  Future<RegistrationSummary> getRegistrationSummary(
    RegistrationSummaryRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/api/registration/summary',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return RegistrationSummary.fromJson(response.data['summary']);
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        error: 'Unexpected status code: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Complete registration and create user account
  /// Triggers farm report generation
  /// Returns JWT tokens
  Future<RegistrationCompleteResponse> completeRegistration(
    CompleteRegistrationRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/api/registration/complete',
        data: request.toJson(),
      );

      if (response.statusCode == 201) {
        return RegistrationCompleteResponse.fromJson(response.data);
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        error: 'Unexpected status code: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // =====================================================================
  // CROPS LIST
  // =====================================================================

  /// Fetch list of all available crops for crop selection dropdown
  Future<List<CropMaster>> getCropsList() async {
    try {
      final response = await _dio.get('/api/crops/list');

      if (response.statusCode == 200) {
        final cropsResponse = CropsListResponse.fromJson(response.data);
        return cropsResponse.data;
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        error: 'Unexpected status code: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Search crops by query string (for auto-complete)
  Future<List<CropMaster>> searchCrops(String query) async {
    try {
      final response = await _dio.get(
        '/api/crops/search',
        queryParameters: {'q': query},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((item) => CropMaster.fromJson(item)).toList();
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        error: 'Unexpected status code: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // =====================================================================
  // ERROR HANDLING
  // =====================================================================

  Exception _handleDioError(DioException e) {
    String message = 'Network error occurred';

    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map && data.containsKey('error')) {
        message = data['error'] ?? message;
      }
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Connection timeout - please check your internet';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Request timeout - please try again';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Response timeout - please try again';
        break;
      case DioExceptionType.badResponse:
        if (e.response?.statusCode == 401) {
          message = 'Session expired - please start over';
        } else if (e.response?.statusCode == 409) {
          message = 'Phone number already registered';
        } else if (e.response?.statusCode == 400) {
          message = e.response?.data['error'] ?? message;
        }
        break;
      case DioExceptionType.cancel:
        message = 'Request cancelled';
        break;
      case DioExceptionType.connectionError:
        message = 'Please check your internet connection';
        break;
      case DioExceptionType.unknown:
        message = e.message ?? message;
        break;
    }

    return Exception(message);
  }
}
