import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Location model
class Location {
  final String name;
  final double latitude;
  final double longitude;

  Location({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  Location copyWith({String? name, double? latitude, double? longitude}) {
    return Location(
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  String toString() => '$name ($latitude, $longitude)';
}

/// Common Indian locations
final commonLocations = [
  Location(name: 'Delhi', latitude: 28.6139, longitude: 77.2090),
  Location(name: 'Mumbai', latitude: 19.0760, longitude: 72.8777),
  Location(name: 'Bangalore', latitude: 12.9716, longitude: 77.5946),
  Location(name: 'Chennai', latitude: 13.0827, longitude: 80.2707),
  Location(name: 'Kolkata', latitude: 22.5726, longitude: 88.3639),
  Location(name: 'Hyderabad', latitude: 17.3850, longitude: 78.4867),
  Location(name: 'Pune', latitude: 18.5204, longitude: 73.8567),
  Location(name: 'Jaipur', latitude: 26.9124, longitude: 75.7873),
  Location(name: 'Ahmedabad', latitude: 23.0225, longitude: 72.5714),
  Location(name: 'Lucknow', latitude: 26.8467, longitude: 80.9462),
  Location(name: 'Chandigarh', latitude: 30.7333, longitude: 76.7794),
  Location(name: 'Indore', latitude: 22.7196, longitude: 75.8577),
  Location(name: 'Kanpur', latitude: 26.4499, longitude: 80.3319),
  Location(name: 'Vadodara', latitude: 22.3072, longitude: 73.1812),
  Location(name: 'Visakhapatnam', latitude: 17.6869, longitude: 83.2185),
];

/// Location notifier
class LocationNotifier extends StateNotifier<Location> {
  LocationNotifier() : super(commonLocations.first); // Default to Delhi

  void setLocation(Location location) {
    state = location;
  }

  void setCoordinates(double latitude, double longitude, String name) {
    state = Location(name: name, latitude: latitude, longitude: longitude);
  }

  void setByName(String name) {
    try {
      final location = commonLocations.firstWhere(
        (loc) => loc.name.toLowerCase() == name.toLowerCase(),
      );
      state = location;
    } catch (e) {
      // Location not found, keep current
    }
  }
}

/// Provider for current location
final locationProvider = StateNotifierProvider<LocationNotifier, Location>((
  ref,
) {
  return LocationNotifier();
});

/// Provider for common locations list
final commonLocationsProvider = Provider<List<Location>>((ref) {
  return commonLocations;
});

/// Provider for location search
final locationSearchProvider = Provider.family<List<Location>, String>((
  ref,
  query,
) {
  if (query.isEmpty) {
    return ref.watch(commonLocationsProvider);
  }

  final lowerQuery = query.toLowerCase();
  return ref
      .watch(commonLocationsProvider)
      .where((location) => location.name.toLowerCase().contains(lowerQuery))
      .toList();
});
