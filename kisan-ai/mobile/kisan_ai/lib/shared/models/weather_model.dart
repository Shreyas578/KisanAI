class WeatherData {
  final String id;
  final double latitude;
  final double longitude;
  final String locationName;
  
  // Current weather
  final double temperature; // Celsius
  final double feelsLike; // Celsius
  final int humidity; // Percentage
  final int pressure; // hPa
  final double windSpeed; // m/s
  final int windDirection; // Degrees
  final int cloudiness; // Percentage
  final String weatherMain; // e.g., "Clear", "Rain", "Clouds"
  final String weatherDescription; // e.g., "clear sky", "light rain"
  final String weatherIcon; // Icon code from weather service
  
  // Additional data
  final double visibility; // meters
  final double uvIndex;
  
  // Time data
  final DateTime dt; // Time of data
  final DateTime sunrise; // Sunrise time
  final DateTime sunset; // Sunset time
  final int timezone; // Shift in seconds from UTC
  
  WeatherData({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.locationName,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    required this.windDirection,
    required this.cloudiness,
    required this.weatherMain,
    required this.weatherDescription,
    required this.weatherIcon,
    required this.visibility,
    required this.uvIndex,
    required this.dt,
    required this.sunrise,
    required this.sunset,
    required this.timezone,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'latitude': latitude,
        'longitude': longitude,
        'locationName': locationName,
        'temperature': temperature,
        'feelsLike': feelsLike,
        'humidity': humidity,
        'pressure': pressure,
        'windSpeed': windSpeed,
        'windDirection': windDirection,
        'cloudiness': cloudiness,
        'weatherMain': weatherMain,
        'weatherDescription': weatherDescription,
        'weatherIcon': weatherIcon,
        'visibility': visibility,
        'uvIndex': uvIndex,
        'dt': dt.toIso8601String(),
        'sunrise': sunrise.toIso8601String(),
        'sunset': sunset.toIso8601String(),
        'timezone': timezone,
      };

  factory WeatherData.fromJson(Map<String, dynamic> json) => WeatherData(
        id: json['id'],
        latitude: json['latitude'],
        longitude: json['longitude'],
        locationName: json['locationName'],
        temperature: json['temperature'],
        feelsLike: json['feelsLike'],
        humidity: json['humidity'],
        pressure: json['pressure'],
        windSpeed: json['windSpeed'],
        windDirection: json['windDirection'],
        cloudiness: json['cloudiness'],
        weatherMain: json['weatherMain'],
        weatherDescription: json['weatherDescription'],
        weatherIcon: json['weatherIcon'],
        visibility: json['visibility'],
        uvIndex: json['uvIndex'],
        dt: DateTime.parse(json['dt']),
        sunrise: DateTime.parse(json['sunrise']),
        sunset: DateTime.parse(json['sunset']),
        timezone: json['timezone'],
      );
}
// Rest of the file will be added in another command if needed
// Forecast data for multiple days
class WeatherForecast {
  final String cityName;
  final String country;
  final int timezone;
  final List<WeatherDaily> daily;
  final List<WeatherHourly> hourly;
  
  WeatherForecast({
    required this.cityName,
    required this.country,
    required this.timezone,
    required this.daily,
    required this.hourly,
  });

  Map<String, dynamic> toJson() => {
        'cityName': cityName,
        'country': country,
        'timezone': timezone,
        'daily': daily.map((e) => e.toJson()).toList(),
        'hourly': hourly.map((e) => e.toJson()).toList(),
      };

  factory WeatherForecast.fromJson(Map<String, dynamic> json) => WeatherForecast(
        cityName: json['cityName'],
        country: json['country'],
        timezone: json['timezone'],
        daily: List<WeatherDaily>.from(json['daily'].map((x) => WeatherDaily.fromJson(x))),
        hourly: List<WeatherHourly>.from(json['hourly'].map((x) => WeatherHourly.fromJson(x))),
      );
}

class WeatherDaily {
  final DateTime dt;
  final double sunrise;
  final double sunset;
  final double moonrise;
  final double moonset;
  final Temp temp;
  final FeelsLike feelsLike;
  final int pressure;
  final int humidity;
  final double windSpeed;
  final int windDeg;
  final List<WeatherCondition> weather;
  final double clouds;
  final double pop; // Probability of precipitation
  final double rain; // mm of rain
  final double snow; // mm of snow
  
  WeatherDaily({
    required this.dt,
    required this.sunrise,
    required this.sunset,
    required this.moonrise,
    required this.moonset,
    required this.temp,
    required this.feelsLike,
    required this.pressure,
    required this.humidity,
    required this.windSpeed,
    required this.windDeg,
    required this.weather,
    required this.clouds,
    required this.pop,
    required this.rain,
    required this.snow,
  });

  Map<String, dynamic> toJson() => {
        'dt': dt.toIso8601String(),
        'sunrise': sunrise,
        'sunset': sunset,
        'moonrise': moonrise,
        'moonset': moonset,
        'temp': temp.toJson(),
        'feelsLike': feelsLike.toJson(),
        'pressure': pressure,
        'humidity': humidity,
        'windSpeed': windSpeed,
        'windDeg': windDeg,
        'weather': weather.map((e) => e.toJson()).toList(),
        'clouds': clouds,
        'pop': pop,
        'rain': rain,
        'snow': snow,
      };

  factory WeatherDaily.fromJson(Map<String, dynamic> json) => WeatherDaily(
        dt: DateTime.parse(json['dt']),
        sunrise: json['sunrise'],
        sunset: json['sunset'],
        moonrise: json['moonrise'],
        moonset: json['moonset'],
        temp: Temp.fromJson(json['temp']),
        feelsLike: FeelsLike.fromJson(json['feelsLike']),
        pressure: json['pressure'],
        humidity: json['humidity'],
        windSpeed: json['windSpeed'],
        windDeg: json['windDeg'],
        weather: List<WeatherCondition>.from(json['weather'].map((x) => WeatherCondition.fromJson(x))),
        clouds: json['clouds'],
        pop: json['pop'],
        rain: json['rain'],
        snow: json['snow'],
      );
}

class Temp {
  final double day;
  final double min;
  final double max;
  final double night;
  final double eve;
  final double morn;
  
  Temp({
    required this.day,
    required this.min,
    required this.max,
    required this.night,
    required this.eve,
    required this.morn,
  });

  Map<String, dynamic> toJson() => {
        'day': day,
        'min': min,
        'max': max,
        'night': night,
        'eve': eve,
        'morn': morn,
      };

  factory Temp.fromJson(Map<String, dynamic> json) => Temp(
        day: json['day'],
        min: json['min'],
        max: json['max'],
        night: json['night'],
        eve: json['eve'],
        morn: json['morn'],
      );
}

class FeelsLike {
  final double day;
  final double night;
  final double eve;
  final double morn;
  
  FeelsLike({
    required this.day,
    required this.night,
    required this.eve,
    required this.morn,
  });

  Map<String, dynamic> toJson() => {
        'day': day,
        'night': night,
        'eve': eve,
        'morn': morn,
      };

  factory FeelsLike.fromJson(Map<String, dynamic> json) => FeelsLike(
        day: json['day'],
        night: json['night'],
        eve: json['eve'],
        morn: json['morn'],
      );
}

class WeatherCondition {
  final int id;
  final String main; // e.g., "Rain", "Clouds"
  final String description; // e.g., "light intensity drizzle"
  final String icon; // Icon code
  
  WeatherCondition({
    required this.id,
    required this.main,
    required this.description,
    required this.icon,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'main': main,
        'description': description,
        'icon': icon,
      };

  factory WeatherCondition.fromJson(Map<String, dynamic> json) => WeatherCondition(
        id: json['id'],
        main: json['main'],
        description: json['description'],
        icon: json['icon'],
      );
}

// Hourly forecast
class WeatherHourly {
  final DateTime dt;
  final double temp;
  final double feelsLike;
  final int pressure;
  final int humidity;
  final double windSpeed;
  final int windDeg;
  final int windGust;
  final List<WeatherCondition> weather;
  final double clouds;
  final double pop; // Probability of precipitation
  final double rain; // mm of rain in the last hour
  final double snow; // mm of snow in the last hour
  
  WeatherHourly({
    required this.dt,
    required this.temp,
    required this.feelsLike,
    required this.pressure,
    required this.humidity,
    required this.windSpeed,
    required this.windDeg,
    required this.windGust,
    required this.weather,
    required this.clouds,
    required this.pop,
    required this.rain,
    required this.snow,
  });

  Map<String, dynamic> toJson() => {
        'dt': dt.toIso8601String(),
        'temp': temp,
        'feelsLike': feelsLike,
        'pressure': pressure,
        'humidity': humidity,
        'windSpeed': windSpeed,
        'windDeg': windDeg,
        'windGust': windGust,
        'weather': weather.map((e) => e.toJson()).toList(),
        'clouds': clouds,
        'pop': pop,
        'rain': rain,
        'snow': snow,
      };

  factory WeatherHourly.fromJson(Map<String, dynamic> json) => WeatherHourly(
        dt: DateTime.parse(json['dt']),
        temp: json['temp'],
        feelsLike: json['feelsLike'],
        pressure: json['pressure'],
        humidity: json['humidity'],
        windSpeed: json['windSpeed'],
        windDeg: json['windDeg'],
        windGust: json['windGust'],
        weather: List<WeatherCondition>.from(json['weather'].map((x) => WeatherCondition.fromJson(x))),
        clouds: json['clouds'],
        pop: json['pop'],
        rain: json['rain'],
        snow: json['snow'],
      );
}
