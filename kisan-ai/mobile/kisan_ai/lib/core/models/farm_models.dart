import 'package:json_annotation/json_annotation.dart';

part 'farm_models.g.dart';

// ============= Request Models =============

@JsonSerializable()
class FarmProfileRequest {
  final String village;
  final String? tehsil;
  final String district;
  final String state;
  final String? pin_code;
  final double land_size_acres;
  final double? land_size_hectares;
  final String? soil_type;
  final double? soil_ph;
  final String? water_source;
  final String? irrigation_type;
  final String? equipment;
  final String? labor_type;
  final bool? storage_available;
  final String? nearest_mandi;
  final String? preferred_language;

  FarmProfileRequest({
    required this.village,
    this.tehsil,
    required this.district,
    required this.state,
    this.pin_code,
    required this.land_size_acres,
    this.land_size_hectares,
    this.soil_type,
    this.soil_ph,
    this.water_source,
    this.irrigation_type,
    this.equipment,
    this.labor_type,
    this.storage_available,
    this.nearest_mandi,
    this.preferred_language,
  });

  factory FarmProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$FarmProfileRequestFromJson(json);
  Map<String, dynamic> toJson() => _$FarmProfileRequestToJson(this);
}

@JsonSerializable()
class CropRequest {
  final String crop_name;
  final String? variety;
  final String? sowing_date;
  final String? expected_harvest;

  CropRequest({
    required this.crop_name,
    this.variety,
    this.sowing_date,
    this.expected_harvest,
  });

  factory CropRequest.fromJson(Map<String, dynamic> json) =>
      _$CropRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CropRequestToJson(this);
}

// ============= Response Models =============

@JsonSerializable()
class FarmProfileResponse {
  final String id;
  final String user_id;
  final String? village;
  final String? district;
  final String? state;
  final double? land_size_acres;
  final double? land_size_hectares;
  final String? soil_type;
  final double? soil_ph;
  final String? water_source;
  final String? irrigation_type;
  final String? equipment;
  final String? labor_type;
  final bool? storage_available;
  final String? nearest_mandi;
  final String? preferred_language;
  final String? created_at;
  final String? updated_at;

  FarmProfileResponse({
    required this.id,
    required this.user_id,
    this.village,
    this.district,
    this.state,
    this.land_size_acres,
    this.land_size_hectares,
    this.soil_type,
    this.soil_ph,
    this.water_source,
    this.irrigation_type,
    this.equipment,
    this.labor_type,
    this.storage_available,
    this.nearest_mandi,
    this.preferred_language,
    this.created_at,
    this.updated_at,
  });

  factory FarmProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$FarmProfileResponseFromJson(json);
  Map<String, dynamic> toJson() => _$FarmProfileResponseToJson(this);
}

@JsonSerializable()
class CropResponse {
  final String id;
  final String farm_profile_id;
  final String crop_name;
  final String? variety;
  final String? sowing_date;
  final String? expected_harvest;
  final String? status;
  final String? created_at;

  CropResponse({
    required this.id,
    required this.farm_profile_id,
    required this.crop_name,
    this.variety,
    this.sowing_date,
    this.expected_harvest,
    this.status,
    this.created_at,
  });

  factory CropResponse.fromJson(Map<String, dynamic> json) =>
      _$CropResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CropResponseToJson(this);
}

@JsonSerializable()
class CropMaster {
  final String id;
  final String name;
  final String? scientific_name;
  final String? water_requirement;
  final String? growing_season;
  final String? soil_preference;

  CropMaster({
    required this.id,
    required this.name,
    this.scientific_name,
    this.water_requirement,
    this.growing_season,
    this.soil_preference,
  });

  factory CropMaster.fromJson(Map<String, dynamic> json) =>
      _$CropMasterFromJson(json);
  Map<String, dynamic> toJson() => _$CropMasterToJson(this);
}

@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final String? message;

  ApiResponse({required this.success, this.data, this.error, this.message});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) => ApiResponse(
    success: json['success'] as bool,
    data: json['data'] != null ? fromJsonT(json['data']) : null,
    error: json['error'] as String?,
    message: json['message'] as String?,
  );
}
