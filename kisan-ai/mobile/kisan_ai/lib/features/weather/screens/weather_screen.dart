import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/kisan_widgets.dart';
import '../../../../features/weather/state/weather_provider.dart';
import '../../../../features/weather/widgets/location_picker_dialog.dart';
import '../../../../shared/models/weather_model.dart';
import '../../../../providers/farmer_profile_provider.dart';
import 'package:intl/intl.dart';

class WeatherScreen extends ConsumerStatefulWidget {
  const WeatherScreen({super.key});

  @override
  ConsumerState<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends ConsumerState<WeatherScreen> {
  late String _currentLat;
  late String _currentLng;

  @override
  void initState() {
    super.initState();
    // Initialize with farmer's location if registered, otherwise default
    _initializeLocation();
  }

  void _initializeLocation() {
    // Default to Delhi, India
    _currentLat = '28.6139';
    _currentLng = '77.2090';

    // Will be updated in build() with farmer location if available
  }

  void _updateLocation(String lat, String lng) {
    setState(() {
      _currentLat = lat;
      _currentLng = lng;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get farmer profile to use their registered location
    final farmerProfile = ref.watch(farmerProfileProvider);

    // If farmer is registered with location, use their location
    if (farmerProfile != null &&
        farmerProfile.latitude != 0 &&
        farmerProfile.longitude != 0) {
      _currentLat = farmerProfile.latitude.toString();
      _currentLng = farmerProfile.longitude.toString();
    }

    final coordinatesStr = '$_currentLat,$_currentLng';

    final currentWeatherAsync = ref.watch(currentWeatherProvider(coordinatesStr));
    final forecastWeatherAsync = ref.watch(
      weatherForecastProvider(coordinatesStr),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F0D),
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: KisanAppBar(title: 'Weather', showSearch: true),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate.fixed([
                _buildWeatherHeader(ref, currentWeatherAsync.value),
                const SizedBox(height: 24),
                currentWeatherAsync.when(
                  data: (weather) => _buildCurrentConditions(weather),
                  loading: () => const _LoadingShimmer(),
                  error: (error, stack) => _ErrorWidget(
                    message: error.toString(),
                    onRetry: () {
                      final coordsStr = '$_currentLat,$_currentLng';
                      ref.invalidate(currentWeatherProvider(coordsStr));
                    },
                  ),
                ),
                const SizedBox(height: 24),
                forecastWeatherAsync.when(
                  data: (forecast) => _buildHourlyForecast(forecast),
                  loading: () => const _LoadingShimmer(height: 120),
                  error: (error, stack) => _ErrorWidget(
                    message: error.toString(),
                    onRetry: () {
                      final coordsStr = '$_currentLat,$_currentLng';
                      ref.invalidate(weatherForecastProvider(coordsStr));
                    },
                  ),
                ),
                const SizedBox(height: 24),
                forecastWeatherAsync.when(
                  data: (forecast) => _buildDailyForecast(forecast),
                  loading: () => const _LoadingShimmer(height: 200),
                  error: (error, stack) => _ErrorWidget(
                    message: error.toString(),
                    onRetry: () {
                      final coordsStr = '$_currentLat,$_currentLng';
                      ref.invalidate(weatherForecastProvider(coordsStr));
                    },
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherHeader(WidgetRef ref, WeatherData? weather) {
    final profile = ref.watch(farmerProfileProvider);
    String locationName = 'Delhi, India';
    if (profile != null && profile.village.isNotEmpty) {
      locationName = '${profile.village}, ${profile.state}';
    } else if (profile != null && profile.state.isNotEmpty) {
      locationName = profile.state;
    }

    return KisanCard(
      child: Column(
        children: [
          _LocationInfo(
            coordinates: {
              'latitude': double.parse(_currentLat),
              'longitude': double.parse(_currentLng),
            },
            locationName: locationName,
            onEditLocation: (lat, lng) => _updateLocation(lat, lng),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFF2A3830)),
          const SizedBox(height: 16),
          _WeatherMetrics(weather: weather),
        ],
      ),
    );
  }

  Widget _buildCurrentConditions(WeatherData weather) {
    return KisanCard(
      child: Column(
        children: [
          _CurrentConditionHeader(),
          const SizedBox(height: 24),
          _CurrentConditionDetails(weather: weather),
          SizedBox(height: 24),
          _WeatherAlert(),
        ],
      ),
    );
  }

  Widget _buildHourlyForecast(WeatherForecast forecast) {
    return KisanCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'Hourly Forecast'),
          const SizedBox(height: 16),
          _HourlyForecastList(hourly: forecast.hourly),
        ],
      ),
    );
  }

  Widget _buildDailyForecast(WeatherForecast forecast) {
    return KisanCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: '7-Day Forecast'),
          const SizedBox(height: 16),
          _DailyForecastList(daily: forecast.daily),
        ],
      ),
    );
  }
}

// Helper Widgets
class _LocationInfo extends StatelessWidget {
  final Map<String, double> coordinates;
  final String locationName;
  final Function(String lat, String lng) onEditLocation;

  const _LocationInfo({
    required this.coordinates,
    required this.locationName,
    required this.onEditLocation,
  });

  @override
  Widget build(BuildContext context) {
    // In a real app, you'd reverse geocode the coordinates to get a place name
    return Row(
      children: [
        const Icon(Icons.location_on, color: Color(0xFF00E676), size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                locationName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF0FFF4),
                ),
              ),
              Text(
                'Last updated: just now',
                style: TextStyle(fontSize: 12, color: Color(0xFF8BA898)),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit, color: Color(0xFF00E676)),
          onPressed: () async {
            // Show location picker dialog
            final result = await LocationPickerDialog.show(context);

            if (result != null) {
              onEditLocation(
                result.latitude.toString(),
                result.longitude.toString(),
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Location changed to ${result.name}'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            }
          },
        ),
      ],
    );
  }
}

class _WeatherMetrics extends StatelessWidget {
  final WeatherData? weather;

  const _WeatherMetrics({this.weather});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceAround,
      spacing: 8,
      runSpacing: 16,
      children: [
        _MetricCard(
          label: 'Temperature', 
          value: weather != null ? '${weather!.temperature.toStringAsFixed(1)}°' : '--°', 
          icon: Icons.thermostat
        ),
        _MetricCard(
          label: 'Humidity', 
          value: weather != null ? '${weather!.humidity}%' : '--%', 
          icon: Icons.water_drop
        ),
        _MetricCard(
          label: 'Wind', 
          value: weather != null ? '${weather!.windSpeed.toStringAsFixed(1)} m/s' : '-- m/s', 
          icon: Icons.air
        ),
        _MetricCard(
          label: 'Precipitation', 
          value: weather != null ? '${weather!.cloudiness}%' : '--%', 
          icon: Icons.water_drop_outlined
        ),
        _MetricCard(
          label: 'Pressure', 
          value: weather != null ? '${weather!.pressure} hPa' : '-- hPa', 
          icon: Icons.speed
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Color(0xFF00E676), size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFFF0FFF4),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF8BA898)),
        ),
      ],
    );
  }
}

class _CurrentConditionHeader extends StatelessWidget {
  const _CurrentConditionHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Current Conditions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFFF0FFF4),
          ),
        ),
        Consumer(
          builder: (context, ref, child) {
            const latitude = 28.6139;
            const longitude = 77.2090;
            return IconButton(
              icon: const Icon(Icons.refresh, color: Color(0xFF00E676)),
              onPressed: () {
                // Refresh current weather with coordinates
                final coordsStr = '$latitude,$longitude';
                ref.invalidate(currentWeatherProvider(coordsStr));
                ref.invalidate(weatherForecastProvider(coordsStr));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Weather data refreshed'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _CurrentConditionDetails extends StatelessWidget {
  final WeatherData weather;

  const _CurrentConditionDetails({required this.weather});

  @override
  Widget build(BuildContext context) {
    // Determine weather icon based on condition
    IconData getWeatherIcon(String condition) {
      switch (condition.toLowerCase()) {
        case 'clear':
        case 'sunny':
          return Icons.wb_sunny;
        case 'cloudy':
        case 'overcast':
          return Icons.cloud;
        case 'rain':
        case 'drizzle':
          return Icons.water_drop;
        case 'thunderstorm':
          return Icons.flash_on;
        case 'snow':
          return Icons.ac_unit;
        case 'mist':
        case 'fog':
        case 'haze':
          return Icons.cloud_queue;
        default:
          return Icons.wb_sunny; // default
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Weather icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF00E676).withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            getWeatherIcon(weather.weatherMain),
            size: 40,
            color: Color(0xFF00E676),
          ),
        ),
        const SizedBox(width: 24),
        Column(
          children: [
            Text(
              '${weather.temperature.toStringAsFixed(0)}°',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF0FFF4),
              ),
            ),
            Text(
              weather.weatherDescription,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFF8BA898),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _WeatherAlert extends StatelessWidget {
  const _WeatherAlert();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2420),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFB300), width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber, color: Color(0xFFFFB300), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Heat Advisory',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFB300),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'High temperatures expected today. Stay hydrated and avoid prolonged sun exposure.',
                  style: TextStyle(fontSize: 12, color: Color(0xFFF0FFF4)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingShimmer extends StatelessWidget {
  final double? height;

  const _LoadingShimmer({this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 200,
      width: double.infinity,
      color: Colors.grey[800],
      child: const Center(
        child: CircularProgressIndicator(color: Color(0xFF00E676)),
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _ErrorWidget({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red[400], size: 48),
          const SizedBox(height: 16),
          Text(
            'Error loading weather data',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red[400],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey[400]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E676),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFFF0FFF4),
      ),
    );
  }
}

class _HourlyForecastList extends StatelessWidget {
  final List<WeatherHourly> hourly;

  const _HourlyForecastList({required this.hourly});

  @override
  Widget build(BuildContext context) {
    // Take only first 8 hours for display
    final displayHours = hourly.take(8).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          for (final hour in displayHours)
            _HourlyForecastItem(
              time: DateFormat('ha').format(
                DateTime.fromMillisecondsSinceEpoch(
                  hour.dt.millisecondsSinceEpoch,
                ),
              ),
              icon: _getWeatherIconFromId(hour.weather.first.id),
              temp: '${hour.temp.toStringAsFixed(0)}°',
              precipitationChance: (hour.pop * 100).toInt(),
            ),
        ],
      ),
    );
  }

  IconData _getWeatherIconFromId(int weatherId) {
    // Weather condition codes from OpenWeatherMap
    if (weatherId >= 200 && weatherId < 300)
      return Icons.flash_on; // Thunderstorm
    if (weatherId >= 300 && weatherId < 400) return Icons.water_drop; // Drizzle
    if (weatherId >= 500 && weatherId < 600) return Icons.water_drop; // Rain
    if (weatherId >= 600 && weatherId < 700) return Icons.ac_unit; // Snow
    if (weatherId >= 700 && weatherId < 800)
      return Icons.cloud_queue; // Atmosphere
    if (weatherId == 800) return Icons.wb_sunny; // Clear
    if (weatherId > 800) return Icons.wb_cloudy; // Clouds
    return Icons.wb_sunny; // Default
  }
}

class _HourlyForecastItem extends StatelessWidget {
  final String time;
  final IconData icon;
  final String temp;
  final int precipitationChance;

  const _HourlyForecastItem({
    required this.time,
    required this.icon,
    required this.temp,
    required this.precipitationChance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Text(
            time,
            style: const TextStyle(fontSize: 12, color: Color(0xFF8BA898)),
          ),
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(0xFF111814),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Color(0xFF00E676), size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            temp,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFFF0FFF4),
            ),
          ),
          if (precipitationChance > 0) ...[
            const SizedBox(height: 4),
            Text(
              '$precipitationChance%',
              style: const TextStyle(fontSize: 10, color: Color(0xFF00E676)),
            ),
          ],
        ],
      ),
    );
  }
}

class _DailyForecastList extends StatelessWidget {
  final List<WeatherDaily> daily;

  const _DailyForecastList({required this.daily});

  @override
  Widget build(BuildContext context) {
    // Take only first 7 days for display
    final displayDays = daily.take(7).toList();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) =>
          const Divider(height: 1, color: Color(0xFF2A3830)),
      itemCount: displayDays.length,
      itemBuilder: (context, index) {
        final day = displayDays[index];
        return _DailyForecastItem(
          day: DateFormat('EEE').format(
            DateTime.fromMillisecondsSinceEpoch(day.dt.millisecondsSinceEpoch),
          ),
          icon: _getWeatherIconFromId(day.weather.first.id),
          minTemp: '${day.temp.min.toStringAsFixed(0)}°',
          maxTemp: '${day.temp.max.toStringAsFixed(0)}°',
          precipitationChance: (day.pop * 100).toInt(),
        );
      },
    );
  }

  IconData _getWeatherIconFromId(int weatherId) {
    // Weather condition codes from OpenWeatherMap
    if (weatherId >= 200 && weatherId < 300)
      return Icons.flash_on; // Thunderstorm
    if (weatherId >= 300 && weatherId < 400) return Icons.water_drop; // Drizzle
    if (weatherId >= 500 && weatherId < 600) return Icons.water_drop; // Rain
    if (weatherId >= 600 && weatherId < 700) return Icons.ac_unit; // Snow
    if (weatherId >= 700 && weatherId < 800)
      return Icons.cloud_queue; // Atmosphere
    if (weatherId == 800) return Icons.wb_sunny; // Clear
    if (weatherId > 800) return Icons.wb_cloudy; // Clouds
    return Icons.wb_sunny; // Default
  }
}

class _DailyForecastItem extends StatelessWidget {
  final String day;
  final IconData icon;
  final String minTemp;
  final String maxTemp;
  final int precipitationChance;

  const _DailyForecastItem({
    required this.day,
    required this.icon,
    required this.minTemp,
    required this.maxTemp,
    required this.precipitationChance,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Text(
            day,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF8BA898),
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Icon(icon, color: Color(0xFF00E676), size: 20),
              const SizedBox(width: 8),
              Text(
                '$minTemp / $maxTemp',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF0FFF4),
                ),
              ),
              if (precipitationChance > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E676).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '$precipitationChance%',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF00E676),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
