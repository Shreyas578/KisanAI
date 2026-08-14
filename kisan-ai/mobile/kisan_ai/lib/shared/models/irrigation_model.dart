class IrrigationSchedule {
  final String id;
  final String farmId;
  final String? fieldId;
  final String title;
  final String? description;
  final DateTime startDate;
  final DateTime? endDate;
  final String frequency; // "daily", "every_2_days", "weekly", etc.
  final String method; // "drip", "sprinkler", "flood", "furrow"
  final double waterAmount; // in liters or mm
  final String waterUnit; // "liters", "mm", "inches"
  final String timeOfDay; // "morning", "evening", "both"
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  // New fields for compatibility
  final String cropType;
  final double area;

  IrrigationSchedule({
    required this.id,
    this.farmId = '',
    this.fieldId,
    required this.title,
    this.description,
    required this.startDate,
    this.endDate,
    required this.frequency,
    required this.method,
    required this.waterAmount,
    required this.waterUnit,
    required this.timeOfDay,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
    this.cropType = 'Wheat',
    this.area = 1.0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'farmId': farmId,
    'fieldId': fieldId,
    'title': title,
    'description': description,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'frequency': frequency,
    'method': method,
    'waterAmount': waterAmount,
    'waterUnit': waterUnit,
    'timeOfDay': timeOfDay,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'cropType': cropType,
    'area': area,
  };

  factory IrrigationSchedule.fromJson(Map<String, dynamic> json) =>
      IrrigationSchedule(
        id: json['id'] ?? '',
        farmId: json['farmId'] ?? '',
        fieldId: json['fieldId'],
        title: json['title'] ?? '',
        description: json['description'],
        startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : DateTime.now(),
        endDate: json['endDate'] != null
            ? DateTime.parse(json['endDate'])
            : null,
        frequency: json['frequency'] ?? '',
        method: json['method'] ?? '',
        waterAmount: (json['waterAmount'] as num?)?.toDouble() ?? 0.0,
        waterUnit: json['waterUnit'] ?? 'liters',
        timeOfDay: json['timeOfDay'] ?? 'morning',
        isActive: json['isActive'] ?? false,
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'])
            : null,
        cropType: json['cropType'] ?? json['crop_type'] ?? 'Wheat',
        area: (json['area'] as num?)?.toDouble() ?? 1.0,
      );
}

class IrrigationExecution {
  final String id;
  final String irrigationScheduleId;
  final DateTime executedAt;
  final double actualWaterAmount;
  final String? executedBy; // farmer ID or system
  final String status; // "planned", "executed", "skipped", "failed"
  final String? notes;

  IrrigationExecution({
    required this.id,
    required this.irrigationScheduleId,
    required this.executedAt,
    required this.actualWaterAmount,
    this.executedBy,
    required this.status,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'irrigationScheduleId': irrigationScheduleId,
    'executedAt': executedAt.toIso8601String(),
    'actualWaterAmount': actualWaterAmount,
    'executedBy': executedBy,
    'status': status,
    'notes': notes,
  };

  factory IrrigationExecution.fromJson(Map<String, dynamic> json) =>
      IrrigationExecution(
        id: json['id'] ?? '',
        irrigationScheduleId: json['irrigationScheduleId'] ?? '',
        executedAt: json['executedAt'] != null ? DateTime.parse(json['executedAt']) : DateTime.now(),
        actualWaterAmount: (json['actualWaterAmount'] as num?)?.toDouble() ?? 0.0,
        executedBy: json['executedBy'],
        status: json['status'] ?? 'planned',
        notes: json['notes'],
      );
}

/// Irrigation recommendation from AI/backend
class IrrigationRecommendation {
  final String id;
  final String farmId;
  final String cropType;
  final double recommendedWaterAmount;
  final String waterUnit;
  final String method;
  final String reason;
  final DateTime recommendedDate;
  final DateTime createdAt;

  IrrigationRecommendation({
    required this.id,
    required this.farmId,
    required this.cropType,
    required this.recommendedWaterAmount,
    required this.waterUnit,
    required this.method,
    required this.reason,
    required this.recommendedDate,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'farmId': farmId,
    'cropType': cropType,
    'recommendedWaterAmount': recommendedWaterAmount,
    'waterUnit': waterUnit,
    'method': method,
    'reason': reason,
    'recommendedDate': recommendedDate.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory IrrigationRecommendation.fromJson(Map<String, dynamic> json) =>
      IrrigationRecommendation(
        id: json['id'] ?? '',
        farmId: json['farmId'] ?? '',
        cropType: json['cropType'] ?? '',
        recommendedWaterAmount:
            (json['recommendedWaterAmount'] as num?)?.toDouble() ?? 0,
        waterUnit: json['waterUnit'] ?? '',
        method: json['method'] ?? '',
        reason: json['reason'] ?? '',
        recommendedDate: json['recommendedDate'] != null
            ? DateTime.parse(json['recommendedDate'])
            : DateTime.now(),
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
      );
}
