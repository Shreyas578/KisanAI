import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan_ai/features/farm_report/models/farm_report_model.dart';

/// Global farmer profile provider
/// Stores all farmer data that should be available throughout the app
/// This includes registration data, location, crop info, and generated reports

class FarmerProfileModel {
  // Personal Details
  final String userId;
  final String name;
  final String phone;
  final String email;
  final String preferredLanguage;

  // Location Details
  final double latitude;
  final double longitude;
  final String village;
  final String district;
  final String state;
  final String pinCode;

  // Land Details
  final double landAcres;
  final int numPlots;
  final String soilType;
  final String waterSource;
  final String irrigationType;
  final String topography;
  final String equipment;
  final bool hasStorage;
  final String budgetRange;
  final String marketPreference;
  final String riskAppetite;

  // Crop Details
  final bool cropDecided;
  final String? cropName;
  final String? seedVariety;
  final DateTime? sowingDate;
  final String? previousCrop;

  // Farm Report
  final FarmReportData? farmReport;
  final String reportType; // '365_day_plan' or 'crop_recommendation'
  final bool reportGenerated;
  final DateTime? reportGeneratedAt;

  // Metadata
  final DateTime registeredAt;
  final bool registrationComplete;

  FarmerProfileModel({
    required this.userId,
    required this.name,
    required this.phone,
    this.email = '',
    this.preferredLanguage = 'en',
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.village = '',
    this.district = '',
    this.state = '',
    this.pinCode = '',
    this.landAcres = 0.0,
    this.numPlots = 1,
    this.soilType = '',
    this.waterSource = '',
    this.irrigationType = '',
    this.topography = '',
    this.equipment = '',
    this.hasStorage = false,
    this.budgetRange = '',
    this.marketPreference = '',
    this.riskAppetite = 'medium',
    this.cropDecided = false,
    this.cropName,
    this.seedVariety,
    this.sowingDate,
    this.previousCrop,
    this.farmReport,
    this.reportType = 'crop_recommendation',
    this.reportGenerated = false,
    this.reportGeneratedAt,
    DateTime? registeredAt,
    this.registrationComplete = false,
  }) : registeredAt = registeredAt ?? DateTime.now();

  /// Copy with new values
  FarmerProfileModel copyWith({
    String? userId,
    String? name,
    String? phone,
    String? email,
    String? preferredLanguage,
    double? latitude,
    double? longitude,
    String? village,
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
    DateTime? sowingDate,
    String? previousCrop,
    FarmReportData? farmReport,
    String? reportType,
    bool? reportGenerated,
    DateTime? reportGeneratedAt,
    DateTime? registeredAt,
    bool? registrationComplete,
  }) {
    return FarmerProfileModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      village: village ?? this.village,
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
      farmReport: farmReport ?? this.farmReport,
      reportType: reportType ?? this.reportType,
      reportGenerated: reportGenerated ?? this.reportGenerated,
      reportGeneratedAt: reportGeneratedAt ?? this.reportGeneratedAt,
      registeredAt: registeredAt ?? this.registeredAt,
      registrationComplete: registrationComplete ?? this.registrationComplete,
    );
  }

  /// Get state for weather API (used everywhere)
  String get weatherState => state;

  /// Get coordinates for APIs
  String get coordinates => '$latitude,$longitude';

  /// Check if profile is complete
  bool get isProfileComplete =>
      registrationComplete &&
      state.isNotEmpty &&
      landAcres > 0 &&
      soilType.isNotEmpty;
}

/// Riverpod State Notifier for Farmer Profile
class FarmerProfileNotifier extends StateNotifier<FarmerProfileModel?> {
  FarmerProfileNotifier() : super(null);

  /// Initialize profile from registration or DB
  void initializeProfile(FarmerProfileModel profile) {
    state = profile;
  }

  /// Update profile with new data
  void updateProfile(FarmerProfileModel profile) {
    state = profile;
  }

  /// Update location (called from GPS)
  void updateLocation({
    required double latitude,
    required double longitude,
    required String stateVal,
    required String district,
    String? village,
    String? pinCode,
  }) {
    if (state == null) return;

    state = state!.copyWith(
      latitude: latitude,
      longitude: longitude,
      state: stateVal,
      district: district,
      village: village ?? state!.village,
      pinCode: pinCode ?? state!.pinCode,
    );
  }

  /// Update crop selection
  void updateCropSelection({
    required bool decided,
    String? cropName,
    String? seedVariety,
    DateTime? sowingDate,
  }) {
    if (state == null) return;

    state = state!.copyWith(
      cropDecided: decided,
      cropName: cropName,
      seedVariety: seedVariety,
      sowingDate: sowingDate,
    );
  }

  /// Update farm report once generated
  void setFarmReport({
    required FarmReportData reportData,
    required String reportType,
  }) {
    if (state == null) return;

    state = state!.copyWith(
      farmReport: reportData,
      reportType: reportType,
      reportGenerated: true,
      reportGeneratedAt: DateTime.now(),
    );
  }

  /// Mark registration complete
  void completeRegistration() {
    if (state == null) return;

    state = state!.copyWith(registrationComplete: true);
  }

  /// Clear profile on logout
  void clearProfile() {
    state = null;
  }

  /// Get farmer's state (for API filtering)
  String? getFarmerState() => state?.state;

  /// Check if farmer has GPS location
  bool hasLocation() =>
      (state?.latitude ?? 0) != 0 && (state?.longitude ?? 0) != 0;

  /// Check if crop is decided
  bool isCropDecided() => state?.cropDecided ?? false;
}

/// Riverpod provider for farmer profile
final farmerProfileProvider =
    StateNotifierProvider<FarmerProfileNotifier, FarmerProfileModel?>((ref) {
      return FarmerProfileNotifier();
    });

/// Provider to get farmer's state (for weather, prices, etc.)
final farmerStateProvider = Provider<String?>((ref) {
  final profile = ref.watch(farmerProfileProvider);
  return profile?.state;
});

/// Provider to check if farmer profile is complete
final isProfileCompleteProvider = Provider<bool>((ref) {
  final profile = ref.watch(farmerProfileProvider);
  return profile?.isProfileComplete ?? false;
});

/// Provider to get crop name
final farmerCropProvider = Provider<String?>((ref) {
  final profile = ref.watch(farmerProfileProvider);
  return profile?.cropName;
});

/// Provider to get farm report
final farmReportProvider = Provider<FarmReportData?>((ref) {
  final profile = ref.watch(farmerProfileProvider);
  return profile?.farmReport;
});

/// Provider to check if report is generated
final isReportGeneratedProvider = Provider<bool>((ref) {
  final profile = ref.watch(farmerProfileProvider);
  return profile?.reportGenerated ?? false;
});
