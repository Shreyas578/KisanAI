// registration_models.dart
// Plain Dart models for registration flow — no code generation required.

// =====================================================================
// SCREEN 1: PERSONAL DETAILS
// =====================================================================

class PersonalDetailsRequest {
  final String name;
  final String phone;
  final String email;
  final String password;
  final String passwordConfirm;
  final String preferredLanguage;

  PersonalDetailsRequest({
    required this.name,
    required this.phone,
    required this.email,
    required this.password,
    required this.passwordConfirm,
    this.preferredLanguage = 'en',
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'email': email,
        'password': password,
        'passwordConfirm': passwordConfirm,
        'preferredLanguage': preferredLanguage,
      };
}

class PersonalDetailsResponse {
  final bool success;
  final String message;
  final String sessionToken;
  final int nextStep;

  PersonalDetailsResponse({
    required this.success,
    required this.message,
    required this.sessionToken,
    required this.nextStep,
  });

  factory PersonalDetailsResponse.fromJson(Map<String, dynamic> json) =>
      PersonalDetailsResponse(
        success: json['success'] as bool,
        message: json['message'] as String,
        sessionToken: json['sessionToken'] as String,
        nextStep: json['nextStep'] as int,
      );
}

// =====================================================================
// SCREEN 2: FARM LOCATION
// =====================================================================

class FarmLocationRequest {
  final String sessionToken;
  final String method;
  final double lat;
  final double lng;
  final String? village;
  final String? tehsil;
  final String district;
  final String state;
  final String? pinCode;

  FarmLocationRequest({
    required this.sessionToken,
    required this.method,
    required this.lat,
    required this.lng,
    this.village,
    this.tehsil,
    required this.district,
    required this.state,
    this.pinCode,
  });

  Map<String, dynamic> toJson() => {
        'sessionToken': sessionToken,
        'method': method,
        'lat': lat,
        'lng': lng,
        'village': village,
        'tehsil': tehsil,
        'district': district,
        'state': state,
        'pinCode': pinCode,
      };
}

class FarmLocationResponse {
  final bool success;
  final String message;
  final String sessionToken;
  final int nextStep;

  FarmLocationResponse({
    required this.success,
    required this.message,
    required this.sessionToken,
    required this.nextStep,
  });

  factory FarmLocationResponse.fromJson(Map<String, dynamic> json) =>
      FarmLocationResponse(
        success: json['success'] as bool,
        message: json['message'] as String,
        sessionToken: json['sessionToken'] as String,
        nextStep: json['nextStep'] as int,
      );
}

// =====================================================================
// SCREEN 3: LAND DETAILS
// =====================================================================

class LandDetailsRequest {
  final String sessionToken;
  final double landAcres;
  final int numPlots;
  final String soilType;
  final String waterSource;
  final String irrigationType;
  final String? topography;
  final String? equipment;
  final bool hasStorage;
  final String? budgetRange;
  final String? marketPreference;
  final String riskAppetite;

  LandDetailsRequest({
    required this.sessionToken,
    required this.landAcres,
    required this.numPlots,
    required this.soilType,
    required this.waterSource,
    required this.irrigationType,
    this.topography,
    this.equipment,
    required this.hasStorage,
    this.budgetRange,
    this.marketPreference,
    this.riskAppetite = 'medium',
  });

  Map<String, dynamic> toJson() => {
        'sessionToken': sessionToken,
        'landAcres': landAcres,
        'numPlots': numPlots,
        'soilType': soilType,
        'waterSource': waterSource,
        'irrigationType': irrigationType,
        'topography': topography,
        'equipment': equipment,
        'hasStorage': hasStorage,
        'budgetRange': budgetRange,
        'marketPreference': marketPreference,
        'riskAppetite': riskAppetite,
      };
}

class LandDetailsResponse {
  final bool success;
  final String message;
  final String sessionToken;
  final int nextStep;

  LandDetailsResponse({
    required this.success,
    required this.message,
    required this.sessionToken,
    required this.nextStep,
  });

  factory LandDetailsResponse.fromJson(Map<String, dynamic> json) =>
      LandDetailsResponse(
        success: json['success'] as bool,
        message: json['message'] as String,
        sessionToken: json['sessionToken'] as String,
        nextStep: json['nextStep'] as int,
      );
}

// =====================================================================
// SCREEN 4: CROP SELECTION
// =====================================================================

class CropSelectionRequest {
  final String sessionToken;
  final bool isDecided;
  final String? cropName;
  final String? seedVariety;
  final String? sowingDate;
  final String? previousCrop;
  final String? estimatedBudget;

  CropSelectionRequest({
    required this.sessionToken,
    required this.isDecided,
    this.cropName,
    this.seedVariety,
    this.sowingDate,
    this.previousCrop,
    this.estimatedBudget,
  });

  Map<String, dynamic> toJson() => {
        'sessionToken': sessionToken,
        'isDecided': isDecided,
        'cropName': cropName,
        'seedVariety': seedVariety,
        'sowingDate': sowingDate,
        'previousCrop': previousCrop,
        'estimatedBudget': estimatedBudget,
      };
}

class CropSelectionResponse {
  final bool success;
  final String message;
  final String sessionToken;
  final int nextStep;

  CropSelectionResponse({
    required this.success,
    required this.message,
    required this.sessionToken,
    required this.nextStep,
  });

  factory CropSelectionResponse.fromJson(Map<String, dynamic> json) =>
      CropSelectionResponse(
        success: json['success'] as bool,
        message: json['message'] as String,
        sessionToken: json['sessionToken'] as String,
        nextStep: json['nextStep'] as int,
      );
}

// =====================================================================
// SCREEN 5: REGISTRATION COMPLETION
// =====================================================================

class CompleteRegistrationRequest {
  final String sessionToken;
  final String password;

  CompleteRegistrationRequest({
    required this.sessionToken,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'sessionToken': sessionToken,
        'password': password,
      };
}

class CropMaster {
  final String id;
  final String name;
  final String? category;
  final String? description;

  CropMaster({
    required this.id,
    required this.name,
    this.category,
    this.description,
  });

  factory CropMaster.fromJson(Map<String, dynamic> json) => CropMaster(
        id: json['id'] as String,
        name: json['name'] as String,
        category: json['category'] as String?,
        description: json['description'] as String?,
      );
}
