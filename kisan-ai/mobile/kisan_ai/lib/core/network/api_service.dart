import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dio_client.dart';
import '../constants/api_constants.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(ref.watch(dioProvider));
});

class ApiService {
  final Dio _dio;

  ApiService(this._dio);

  // Authentication
  Future<Response> login(String phone, String password) {
    return _dio.post(ApiConstants.authLogin, data: {
      'phone': phone,
      'password': password,
    });
  }

  Future<Response> register(Map<String, dynamic> data) {
    return _dio.post(ApiConstants.authRegister, data: data);
  }

  // Farmer
  Future<Response> getProfile() {
    return _dio.get(ApiConstants.farmerProfile);
  }

  Future<Response> updateProfile(Map<String, dynamic> data) {
    return _dio.put(ApiConstants.farmerProfile, data: data);
  }

  // Weather
  Future<Response> getWeather() {
    return _dio.get(ApiConstants.weatherCurrent);
  }

  // Disease
  Future<Response> uploadDiseaseScan(FormData formData) {
    return _dio.post(ApiConstants.diseaseDetect, data: formData);
  }

  Future<Response> getDiseaseHistory() {
    return _dio.get(ApiConstants.diseaseHistory);
  }

  // Market
  Future<Response> getMarketPrices({String? crop, String? state}) {
    return _dio.get(ApiConstants.marketPrices, queryParameters: {
      if (crop != null) 'crop': crop,
      if (state != null) 'state': state,
    });
  }

  // Marketplace
  Future<Response> getListings({int page = 1, int limit = 20}) {
    return _dio.get(ApiConstants.marketplaceListings, queryParameters: {
      'page': page,
      'limit': limit,
    });
  }

  Future<Response> createListing(FormData formData) {
    return _dio.post(ApiConstants.marketplaceCreateListing, data: formData);
  }

}
