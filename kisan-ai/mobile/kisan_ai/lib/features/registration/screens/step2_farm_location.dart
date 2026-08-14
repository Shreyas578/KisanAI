import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kisan_ai/features/registration/providers/registration_state_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Step2FarmLocation extends ConsumerStatefulWidget {
  final VoidCallback onNext;

  const Step2FarmLocation({
    required this.onNext,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<Step2FarmLocation> createState() => _Step2FarmLocationState();
}

class _Step2FarmLocationState extends ConsumerState<Step2FarmLocation> {
  late TextEditingController _villageController;
  late TextEditingController _tehsilController;
  late TextEditingController _districtController;
  late TextEditingController _stateController;
  late TextEditingController _pinCodeController;
  late TextEditingController _latController;
  late TextEditingController _lngController;

  String _selectedMethod = 'gps'; // 'gps' or 'manual'
  bool _isGettingLocation = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _locationStatus;

  Position? _currentPosition;

  final _formKey = GlobalKey<FormState>();

  final List<Map<String, String>> _indianStates = [
    {'name': 'Andhra Pradesh', 'code': 'AP'},
    {'name': 'Arunachal Pradesh', 'code': 'AR'},
    {'name': 'Assam', 'code': 'AS'},
    {'name': 'Bihar', 'code': 'BR'},
    {'name': 'Chhattisgarh', 'code': 'CG'},
    {'name': 'Goa', 'code': 'GA'},
    {'name': 'Gujarat', 'code': 'GJ'},
    {'name': 'Haryana', 'code': 'HR'},
    {'name': 'Himachal Pradesh', 'code': 'HP'},
    {'name': 'Jharkhand', 'code': 'JH'},
    {'name': 'Karnataka', 'code': 'KA'},
    {'name': 'Kerala', 'code': 'KL'},
    {'name': 'Madhya Pradesh', 'code': 'MP'},
    {'name': 'Maharashtra', 'code': 'MH'},
    {'name': 'Manipur', 'code': 'MN'},
    {'name': 'Meghalaya', 'code': 'ML'},
    {'name': 'Mizoram', 'code': 'MZ'},
    {'name': 'Nagaland', 'code': 'NL'},
    {'name': 'Odisha', 'code': 'OD'},
    {'name': 'Punjab', 'code': 'PB'},
    {'name': 'Rajasthan', 'code': 'RJ'},
    {'name': 'Sikkim', 'code': 'SK'},
    {'name': 'Tamil Nadu', 'code': 'TN'},
    {'name': 'Telangana', 'code': 'TG'},
    {'name': 'Tripura', 'code': 'TR'},
    {'name': 'Uttar Pradesh', 'code': 'UP'},
    {'name': 'Uttarakhand', 'code': 'UT'},
    {'name': 'West Bengal', 'code': 'WB'},
  ];

  @override
  void initState() {
    super.initState();
    _villageController = TextEditingController();
    _tehsilController = TextEditingController();
    _districtController = TextEditingController();
    _stateController = TextEditingController();
    _pinCodeController = TextEditingController();
    _latController = TextEditingController();
    _lngController = TextEditingController();
  }

  @override
  void dispose() {
    _villageController.dispose();
    _tehsilController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    _pinCodeController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
      _locationStatus = 'Getting your location...';
      _errorMessage = null;
    });

    try {
      // Check permission status
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage =
              'Location permission is required. Please enable it in settings.';
          _isGettingLocation = false;
          _locationStatus = null;
        });
        return;
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 30),
        );

        setState(() {
          _currentPosition = position;
          _latController.text = position.latitude.toString();
          _lngController.text = position.longitude.toString();
          _locationStatus = 'Location captured — fetching address...';
        });

        // Reverse geocode using OpenStreetMap Nominatim (no API key needed)
        await _reverseGeocode(position.latitude, position.longitude);

        if (mounted) {
          setState(() {
            _locationStatus =
                '📍 Location captured: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
            _isGettingLocation = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to get location: ${e.toString()}';
        _isGettingLocation = false;
        _locationStatus = null;
      });
    }
  }

  /// Reverse geocode coordinates to get village/district/state
  /// Uses OpenStreetMap Nominatim — completely free, no API key needed
  Future<void> _reverseGeocode(double lat, double lng) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lng&format=json&addressdetails=1',
      );
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'KisanAI/1.0 (farmer-registration)',
          'Accept-Language': 'en',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>? ?? {};

        // Extract location components (Nominatim uses different keys by region)
        final village = (address['village'] ??
                address['hamlet'] ??
                address['suburb'] ??
                address['town'] ??
                '') as String;
        final district = (address['county'] ??
                address['district'] ??
                address['state_district'] ??
                '') as String;
        final state = (address['state'] ?? '') as String;

        if (mounted) {
          setState(() {
            if (village.isNotEmpty) _villageController.text = village;
            if (district.isNotEmpty) _districtController.text = district;
            // Match state to dropdown if possible
            if (state.isNotEmpty) {
              final matchedState = _indianStates.firstWhere(
                (s) => s['name']!.toLowerCase() == state.toLowerCase(),
                orElse: () => <String, String>{},
              );
              if (matchedState.isNotEmpty) {
                _stateController.text = matchedState['name']!;
              } else {
                _stateController.text = state;
              }
            }
          });
        }
      }
    } catch (e) {
      // Geocoding failure is non-critical — farmer can fill manually
      debugPrint('Reverse geocoding failed: $e');
    }
  }

  Future<void> _submitLocation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedMethod == 'gps' && _currentPosition == null) {
      setState(() {
        _errorMessage = 'Please get your GPS location first';
      });
      return;
    }

    final sessionToken = ref.read(registrationStateProvider).sessionToken;
    if (sessionToken == null) {
      setState(() {
        _errorMessage = 'Session token not found. Please restart registration.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final lat = _selectedMethod == 'gps'
          ? _currentPosition!.latitude
          : double.parse(_latController.text);
      final lng = _selectedMethod == 'gps'
          ? _currentPosition!.longitude
          : double.parse(_lngController.text);

      await ref.read(registrationStateProvider.notifier).saveFarmLocation(
            latitude: lat,
            longitude: lng,
            district: _districtController.text.trim(),
            farmState: _stateController.text.trim(),
            village: _villageController.text.trim().isEmpty
                ? null
                : _villageController.text.trim(),
            tehsil: _tehsilController.text.trim().isEmpty
                ? null
                : _tehsilController.text.trim(),
            pinCode: _pinCodeController.text.trim().isEmpty
                ? null
                : _pinCodeController.text.trim(),
            sessionToken: sessionToken,
          );

      widget.onNext();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String? _validateCoordinate(String? value, String name) {
    if (value == null || value.isEmpty) {
      return '$name is required';
    }
    try {
      final num = double.parse(value);
      if (num < -90 || num > 90) {
        return 'Invalid $name';
      }
      return null;
    } catch (e) {
      return 'Invalid $name format';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Where is your farm located?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose GPS or enter manually',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // Method Selection
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('📍 GPS'),
                      subtitle: const Text('Auto-detect'),
                      value: 'gps',
                      groupValue: _selectedMethod,
                      onChanged: (value) {
                        setState(() {
                          _selectedMethod = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('📝 Manual'),
                      subtitle: const Text('Enter coordinates'),
                      value: 'manual',
                      groupValue: _selectedMethod,
                      onChanged: (value) {
                        setState(() {
                          _selectedMethod = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              if (_selectedMethod == 'gps') ...[
                // GPS Section
                if (_locationStatus != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      border: Border.all(color: Colors.green.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green.shade600),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _locationStatus!,
                            style: TextStyle(color: Colors.green.shade600),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isGettingLocation ? null : _getCurrentLocation,
                    icon: _isGettingLocation
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location),
                    label: Text(
                      _isGettingLocation
                          ? 'Getting location...'
                          : 'Get My Location',
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              if (_selectedMethod == 'manual') ...[
                // Manual Coordinates
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _latController,
                        decoration: InputDecoration(
                          labelText: 'Latitude',
                          hintText: '20.5937',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            _validateCoordinate(value, 'Latitude'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _lngController,
                        decoration: InputDecoration(
                          labelText: 'Longitude',
                          hintText: '78.9629',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            _validateCoordinate(value, 'Longitude'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Location Details
              TextFormField(
                controller: _villageController,
                decoration: InputDecoration(
                  labelText: 'Village (Optional)',
                  hintText: 'Enter village name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _tehsilController,
                decoration: InputDecoration(
                  labelText: 'Tehsil/Taluka (Optional)',
                  hintText: 'Enter tehsil name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _districtController,
                decoration: InputDecoration(
                  labelText: 'District *',
                  hintText: 'Enter district name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'District is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // State Dropdown
              DropdownButtonFormField<String>(
                value: _stateController.text.isEmpty
                    ? null
                    : _stateController.text,
                decoration: InputDecoration(
                  labelText: 'State *',
                  hintText: 'Select your state',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: _indianStates
                    .map(
                      (state) => DropdownMenuItem(
                        value: state['name'],
                        child: Text(state['name']!),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _stateController.text = value;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'State is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _pinCodeController,
                decoration: InputDecoration(
                  labelText: 'PIN Code (Optional)',
                  hintText: '110001',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),

              // Error Message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red.shade600),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade600),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitLocation,
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
