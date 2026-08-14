import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan_ai/core/network/api_client.dart';
import 'package:kisan_ai/core/network/authenticated_api_client_provider.dart';
import 'package:kisan_ai/core/constants/api_constants.dart';
import 'package:kisan_ai/features/weather/services/weather_service.dart';
import 'package:kisan_ai/shared/models/weather_model.dart';

/// Provider for ApiClient with authentication
final apiClientProvider = FutureProvider<ApiClient>((ref) async {
  return createAuthenticatedApiClient(ref, ApiConstants.baseUrl);
});

/// Provider for WeatherService - now returns regular provider to avoid breaking all downstream code
final weatherServiceProvider = Provider<WeatherService>((ref) {
  // This is a workaround - we create the service with a base client here,
  // but the token will be set when needed by authenticated providers
  return WeatherService(ApiClient(ApiConstants.baseUrl));
});

/// Provider for current weather data - auto-refreshes every 5 minutes
final currentWeatherProvider = FutureProvider.autoDispose
    .family<WeatherData, String>((ref, coordinatesStr) async {
      // Parse coordinates from string
      final parts = coordinatesStr.split(',');
      final lat = double.parse(parts[0]);
      final lng = double.parse(parts[1]);

      // Get authenticated API client
      final apiClient = await ref.read(apiClientProvider.future);
      final weatherService = WeatherService(apiClient);

      // Auto-refresh every 5 minutes
      ref.watch(weatherRefreshProvider);

      return await weatherService.getCurrentWeather(lat, lng);
    });

/// Provider for weather forecast data - auto-refreshes every 30 minutes
final weatherForecastProvider = FutureProvider.autoDispose
    .family<WeatherForecast, String>((ref, coordinatesStr) async {
      // Parse coordinates from string
      final parts = coordinatesStr.split(',');
      final lat = double.parse(parts[0]);
      final lng = double.parse(parts[1]);

      // Get authenticated API client
      final apiClient = await ref.read(apiClientProvider.future);
      final weatherService = WeatherService(apiClient);

      // Auto-refresh every 30 minutes
      ref.watch(weatherForecastRefreshProvider);

      return await weatherService.getWeatherForecast(lat, lng);
    });

/// Provider for weather data by city name - auto-refreshes
final weatherByCityProvider = FutureProvider.autoDispose
    .family<WeatherData, String>((ref, cityName) async {
      // Get authenticated API client
      final apiClient = await ref.read(apiClientProvider.future);
      final weatherService = WeatherService(apiClient);

      // Auto-refresh every 5 minutes
      ref.watch(weatherRefreshProvider);

      return await weatherService.getWeatherByCity(cityName);
    });

/// Refresh trigger for current weather (updates every 5 minutes)
final weatherRefreshProvider = StreamProvider<int>((ref) async* {
  int counter = 0;
  while (true) {
    yield counter++;
    await Future.delayed(const Duration(minutes: 5));
  }
});

/// Refresh trigger for forecast (updates every 30 minutes)
final weatherForecastRefreshProvider = StreamProvider<int>((ref) async* {
  int counter = 0;
  while (true) {
    yield counter++;
    await Future.delayed(const Duration(minutes: 30));
  }
});
