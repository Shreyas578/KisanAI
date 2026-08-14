import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:kisan_ai/core/constants/api_constants.dart';
import 'package:kisan_ai/core/network/api_client.dart';
import 'package:kisan_ai/shared/models/weather_model.dart';

/// Service for handling weather-related API calls
class WeatherService {
  final ApiClient _apiClient;

  WeatherService(this._apiClient);

  /// Get current weather for given coordinates
  Future<WeatherData> getCurrentWeather(
    double latitude,
    double longitude,
  ) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.weatherCurrent,
        queryParameters: {'lat': latitude, 'lon': longitude},
      );

      if (response.statusCode == 200) {
        // Handle response with 'data' wrapper
        final data = response.data['data'] ?? response.data;
        return WeatherData(
          id: '${latitude}_${longitude}',
          latitude: latitude,
          longitude: longitude,
          locationName: data['city_name'] ?? 'Unknown',
          temperature: (data['temperature'] ?? 0).toDouble(),
          feelsLike: (data['feels_like'] ?? 0).toDouble(),
          humidity: data['humidity'] ?? 0,
          pressure: data['pressure'] ?? 0,
          windSpeed: (data['wind_speed'] ?? 0).toDouble(),
          windDirection: data['wind_deg'] ?? 0,
          cloudiness: data['clouds'] ?? 0,
          weatherMain: data['weather_main'] ?? 'Unknown',
          weatherDescription: data['weather_description'] ?? 'Unknown',
          weatherIcon: data['weather_icon'] ?? '01d',
          visibility: (data['visibility'] ?? 0).toDouble(),
          uvIndex: 0,
          dt: DateTime.now(),
          sunrise: DateTime.now(),
          sunset: DateTime.now(),
          timezone: data['timezone'] ?? 0,
        );
      } else {
        throw Exception(
          'Failed to get current weather: ${response.data['error'] ?? 'Unknown error'}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Get weather forecast for given coordinates
  Future<WeatherForecast> getWeatherForecast(
    double latitude,
    double longitude,
  ) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.weatherForecast,
        queryParameters: {'lat': latitude, 'lon': longitude},
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Parse hourly data
        final hourlyList = (data['hourly'] as List? ?? []).map((h) {
          return WeatherHourly(
            dt: DateTime.fromMillisecondsSinceEpoch((h['dt'] ?? 0) * 1000),
            temp: (h['temp'] ?? 0).toDouble(),
            feelsLike: (h['feelsLike'] ?? h['temp'] ?? 0).toDouble(),
            pressure: h['pressure'] ?? 0,
            humidity: h['humidity'] ?? 0,
            windSpeed: (h['windSpeed'] ?? 0).toDouble(),
            windDeg: h['windDeg'] ?? 0,
            windGust: h['windGust'] ?? 0,
            weather: [
              WeatherCondition(
                id: h['weather'][0]['id'] ?? 0,
                main: h['weather'][0]['main'] ?? 'Unknown',
                description: h['weather'][0]['description'] ?? 'Unknown',
                icon: h['weather'][0]['icon'] ?? '01d',
              ),
            ],
            clouds: (h['clouds'] ?? 0).toDouble(),
            pop: (h['pop'] ?? 0).toDouble(),
            rain: (h['rain'] ?? 0).toDouble(),
            snow: (h['snow'] ?? 0).toDouble(),
          );
        }).toList();

        // Parse daily data
        final dailyList = (data['daily'] as List? ?? []).map((d) {
          return WeatherDaily(
            dt: DateTime.parse(d['dt'] ?? DateTime.now().toIso8601String()),
            sunrise: (d['sunrise'] ?? 0).toDouble(),
            sunset: (d['sunset'] ?? 0).toDouble(),
            moonrise: (d['moonrise'] ?? 0).toDouble(),
            moonset: (d['moonset'] ?? 0).toDouble(),
            temp: Temp(
              day: (d['temp']['day'] ?? 0).toDouble(),
              min: (d['temp']['min'] ?? 0).toDouble(),
              max: (d['temp']['max'] ?? 0).toDouble(),
              night: (d['temp']['night'] ?? 0).toDouble(),
              eve: (d['temp']['eve'] ?? 0).toDouble(),
              morn: (d['temp']['morn'] ?? 0).toDouble(),
            ),
            feelsLike: FeelsLike(
              day: (d['feelsLike']['day'] ?? 0).toDouble(),
              night: (d['feelsLike']['night'] ?? 0).toDouble(),
              eve: (d['feelsLike']['eve'] ?? 0).toDouble(),
              morn: (d['feelsLike']['morn'] ?? 0).toDouble(),
            ),
            pressure: d['pressure'] ?? 0,
            humidity: d['humidity'] ?? 0,
            windSpeed: (d['windSpeed'] ?? 0).toDouble(),
            windDeg: d['windDeg'] ?? 0,
            weather: [
              WeatherCondition(
                id: d['weather'][0]['id'] ?? 0,
                main: d['weather'][0]['main'] ?? 'Unknown',
                description: d['weather'][0]['description'] ?? 'Unknown',
                icon: d['weather'][0]['icon'] ?? '01d',
              ),
            ],
            clouds: (d['clouds'] ?? 0).toDouble(),
            pop: (d['pop'] ?? 0).toDouble(),
            rain: (d['rain'] ?? 0).toDouble(),
            snow: (d['snow'] ?? 0).toDouble(),
          );
        }).toList();

        return WeatherForecast(
          cityName: 'Delhi',
          country: 'IN',
          timezone: 19800,
          daily: dailyList,
          hourly: hourlyList,
        );
      } else {
        throw Exception(
          'Failed to get weather forecast: ${response.data['error'] ?? 'Unknown error'}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Get weather data by city name
  Future<WeatherData> getWeatherByCity(String cityName) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.weatherCurrent,
        queryParameters: {'q': cityName},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return WeatherData(
          id: '${cityName}_weather',
          latitude: 0,
          longitude: 0,
          locationName: data['city_name'] ?? cityName,
          temperature: (data['temperature'] ?? 0).toDouble(),
          feelsLike: (data['feels_like'] ?? 0).toDouble(),
          humidity: data['humidity'] ?? 0,
          pressure: data['pressure'] ?? 0,
          windSpeed: (data['wind_speed'] ?? 0).toDouble(),
          windDirection: data['wind_deg'] ?? 0,
          cloudiness: data['clouds'] ?? 0,
          weatherMain: data['weather_main'] ?? 'Unknown',
          weatherDescription: data['weather_description'] ?? 'Unknown',
          weatherIcon: data['weather_icon'] ?? '01d',
          visibility: (data['visibility'] ?? 0).toDouble(),
          uvIndex: 0,
          dt: DateTime.now(),
          sunrise: DateTime.now(),
          sunset: DateTime.now(),
          timezone: data['timezone'] ?? 0,
        );
      } else {
        throw Exception(
          'Failed to get weather for city: ${response.data['error'] ?? 'Unknown error'}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }
}
