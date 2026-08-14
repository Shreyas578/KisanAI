import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/config/api_config.dart';

/// Registration State Model
class RegistrationState {
  // Step 1: Personal Details
  final String? name;
  final String? phone;
  final String? email;
  final String? password;
  final String? preferredLanguage;
  final String? role;

  // Step 2: Farm Location
  final double? latitude;
  final double? longitude;
  final String? village;
  final String? tehsil;
  final String? district;
  final String? state;
  final String? pinCode;

  // Step 3: Land Details
  final double? landAcres;
  final int? numPlots;
  final String? soilType;
  final String? waterSource;
  final String? irrigationType;
  final String? topography;
  final String? equipment;
  final bool? hasStorage;
  final String? budgetRange;
  final String? marketPreference;
  final String? riskAppetite;

  // Step 4: Crop Selection
  final bool? cropDecided;
  final String? cropName;
  final String? seedVariety;
  final String? sowingDate;
  final String? previousCrop;
  final String? estimatedBudget;

  // Session management
  final String? sessionToken;
  final int currentStep;

  RegistrationState({
    // Step 1
    this.name,
    this.phone,
    this.email,
    this.password,
    this.preferredLanguage = 'en',
    this.role = 'farmer',
    // Step 2
    this.latitude,
    this.longitude,
    this.village,
    this.tehsil,
    this.district,
    this.state,
    this.pinCode,
    // Step 3
    this.landAcres,
    this.numPlots,
    this.soilType,
    this.waterSource,
    this.irrigationType,
    this.topography,
    this.equipment,
    this.hasStorage,
    this.budgetRange,
    this.marketPreference,
    this.riskAppetite,
    // Step 4
    this.cropDecided,
    this.cropName,
    this.seedVariety,
    this.sowingDate,
    this.previousCrop,
    this.estimatedBudget,
    // Session
    this.sessionToken,
    this.currentStep = 0,
  });

  RegistrationState copyWith({
    String? name,
    String? phone,
    String? email,
    String? password,
    String? preferredLanguage,
    String? role,
    double? latitude,
    double? longitude,
    String? village,
    String? tehsil,
    String? district,
    String? state,
    String? pinCode,
    double? landAcres,
    int? numPlots,
    String? soilType,
    String? waterSource,
    String? irrigationType,
    String? topography,
    String? equipment,
    bool? hasStorage,
    String? budgetRange,
    String? marketPreference,
    String? riskAppetite,
    bool? cropDecided,
    String? cropName,
    String? seedVariety,
    String? sowingDate,
    String? previousCrop,
    String? estimatedBudget,
    String? sessionToken,
    int? currentStep,
  }) {
    return RegistrationState(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      password: password ?? this.password,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      role: role ?? this.role,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      village: village ?? this.village,
      tehsil: tehsil ?? this.tehsil,
      district: district ?? this.district,
      state: state ?? this.state,
      pinCode: pinCode ?? this.pinCode,
      landAcres: landAcres ?? this.landAcres,
      numPlots: numPlots ?? this.numPlots,
      soilType: soilType ?? this.soilType,
      waterSource: waterSource ?? this.waterSource,
      irrigationType: irrigationType ?? this.irrigationType,
      topography: topography ?? this.topography,
      equipment: equipment ?? this.equipment,
      hasStorage: hasStorage ?? this.hasStorage,
      budgetRange: budgetRange ?? this.budgetRange,
      marketPreference: marketPreference ?? this.marketPreference,
      riskAppetite: riskAppetite ?? this.riskAppetite,
      cropDecided: cropDecided ?? this.cropDecided,
      cropName: cropName ?? this.cropName,
      seedVariety: seedVariety ?? this.seedVariety,
      sowingDate: sowingDate ?? this.sowingDate,
      previousCrop: previousCrop ?? this.previousCrop,
      estimatedBudget: estimatedBudget ?? this.estimatedBudget,
      sessionToken: sessionToken ?? this.sessionToken,
      currentStep: currentStep ?? this.currentStep,
    );
  }
}

/// Notifier for managing registration state
class RegistrationStateNotifier extends StateNotifier<RegistrationState> {
  RegistrationStateNotifier() : super(RegistrationState());

  /// Save Step 1: Personal Details
  Future<void> savePersonalDetails({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String preferredLanguage,
    required String role,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/api/auth/register/step1'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'phone': phone,
              'email': email,
              'password': password,
              'passwordConfirm': password,
              'preferredLanguage': preferredLanguage,
              'role': role,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        state = state.copyWith(
          name: name,
          phone: phone,
          email: email,
          preferredLanguage: preferredLanguage,
          role: role,
          sessionToken: data['sessionToken'],
          currentStep: 1,
        );
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Step 1 failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Save Step 2: Farm Location
  Future<void> saveFarmLocation({
    required double latitude,
    required double longitude,
    required String district,
    required String farmState,
    String? village,
    String? tehsil,
    String? pinCode,
    required String sessionToken,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/api/auth/register/step2'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'sessionToken': sessionToken,
              'method': 'manual',
              'lat': latitude,
              'lng': longitude,
              'village': village,
              'tehsil': tehsil,
              'district': district,
              'state': farmState,
              'pinCode': pinCode,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        state = state.copyWith(
          latitude: latitude,
          longitude: longitude,
          village: village,
          tehsil: tehsil,
          district: district,
          state: farmState,
          pinCode: pinCode,
          sessionToken: data['sessionToken'],
          currentStep: 2,
        );
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Step 2 failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Save Step 3: Land Details
  Future<void> saveLandDetails({
    required double landAcres,
    required String soilType,
    required String waterSource,
    String? irrigationType,
    String? topography,
    String? equipment,
    bool? hasStorage,
    String? budgetRange,
    String? marketPreference,
    String? riskAppetite,
    int? numPlots,
    required String sessionToken,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/api/auth/register/step3'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'sessionToken': sessionToken,
              'landAcres': landAcres,
              'numPlots': numPlots ?? 1,
              'soilType': soilType,
              'waterSource': waterSource,
              'irrigationType': irrigationType,
              'topography': topography,
              'equipment': equipment,
              'hasStorage': hasStorage ?? false,
              'budgetRange': budgetRange,
              'marketPreference': marketPreference,
              'riskAppetite': riskAppetite ?? 'medium',
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        state = state.copyWith(
          landAcres: landAcres,
          numPlots: numPlots ?? 1,
          soilType: soilType,
          waterSource: waterSource,
          irrigationType: irrigationType,
          topography: topography,
          equipment: equipment,
          hasStorage: hasStorage ?? false,
          budgetRange: budgetRange,
          marketPreference: marketPreference,
          riskAppetite: riskAppetite ?? 'medium',
          sessionToken: data['sessionToken'],
          currentStep: 3,
        );
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Step 3 failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Save Step 4: Crop Selection
  Future<void> saveCropSelection({
    required bool isDecided,
    String? cropName,
    String? seedVariety,
    String? sowingDate,
    String? previousCrop,
    String? estimatedBudget,
    required String sessionToken,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/api/auth/register/step4'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'sessionToken': sessionToken,
              'isDecided': isDecided,
              'cropName': cropName,
              'seedVariety': seedVariety,
              'sowingDate': sowingDate,
              'previousCrop': previousCrop,
              'estimatedBudget': estimatedBudget,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        state = state.copyWith(
          cropDecided: isDecided,
          cropName: cropName,
          seedVariety: seedVariety,
          sowingDate: sowingDate,
          previousCrop: previousCrop,
          estimatedBudget: estimatedBudget,
          sessionToken: data['sessionToken'],
          currentStep: 4,
        );
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Step 4 failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Reset registration state
  void reset() {
    state = RegistrationState();
  }
}

// Providers
final registrationStateProvider =
    StateNotifierProvider<RegistrationStateNotifier, RegistrationState>(
      (ref) => RegistrationStateNotifier(),
    );

final registrationLoadingProvider = StateProvider<bool>((ref) => false);

final registrationErrorProvider = StateProvider<String?>((ref) => null);

final registrationTokenProvider = StateProvider<String?>((ref) => null);

final cropSelectionProvider = registrationStateProvider;
