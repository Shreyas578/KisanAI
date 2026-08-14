import 'package:kisan_ai/core/network/api_client.dart';

/// Base service class that provides common functionality for all services
class BaseService {
  final ApiClient _apiClient;

  BaseService(this._apiClient);

  /// Handle API errors and throw appropriate exceptions
  dynamic handleError(dynamic error) {
    if (error is Exception) {
      throw error;
    } else {
      throw Exception('Unknown error occurred: $error');
    }
  }

  /// Check if the response is successful
  bool isSuccessResponse(dynamic response) {
    return response != null &&
           response is Map &&
           response.containsKey('success') &&
           response['success'] == true;
  }

  /// Extract data from a successful response
  dynamic getDataFromResponse(dynamic response) {
    if (isSuccessResponse(response)) {
      return response['data'];
    }
    return null;
  }

  /// Extract message from a response
  String getMessageFromResponse(dynamic response, {String defaultMessage = 'An error occurred'}) {
    if (response != null && response is Map && response.containsKey('message')) {
      return response['message'];
    }
    return defaultMessage;
  }
}