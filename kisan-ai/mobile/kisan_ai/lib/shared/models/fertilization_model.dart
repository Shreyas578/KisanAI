class FertilizationSchedule {
  final String id;
  final String farmId;
  final String? fieldId;
  final String title;
  final String? description;
  final DateTime startDate;
  final DateTime? endDate;
  final String frequency; // "daily", "weekly", "monthly", etc.
  final String fertilizerType; // "NPK", "urea", "compost", "organic", etc.
  final double amount; // quantity to apply
  final String amountUnit; // "kg", "grams", "liters", "bags"
  final String applicationMethod; // "broadcast", "banding", "foliar", "fertigation"
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  // New fields for compatibility
  final String cropType;
  final double area;
  final bool isExecuting;

  FertilizationSchedule({
    required this.id,
    this.farmId = '',
    this.fieldId,
    String? title,
    this.description,
    required this.startDate,
    this.endDate,
    required this.frequency,
    required this.fertilizerType,
    double? amount,
    double? applicationRate,
    String? amountUnit,
    String? unit,
    this.applicationMethod = 'broadcast',
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
    this.cropType = '',
    this.area = 0.0,
    this.isExecuting = false,
  }) : amount = amount ?? applicationRate ?? 0.0,
       amountUnit = amountUnit ?? unit ?? 'kg',
       title = title == null || title.isEmpty ? '$fertilizerType Schedule' : title;

  // Getters for UI compatibility
  double get applicationRate => amount;
  String get unit => amountUnit;

  Map<String, dynamic> toJson() => {
        'id': id,
        'farmId': farmId,
        'fieldId': fieldId,
        'title': title,
        'description': description,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'frequency': frequency,
        'fertilizerType': fertilizerType,
        'amount': amount,
        'amountUnit': amountUnit,
        'applicationMethod': applicationMethod,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'cropType': cropType,
        'area': area,
        'isExecuting': isExecuting,
      };

  factory FertilizationSchedule.fromJson(Map<String, dynamic> json) => FertilizationSchedule(
        id: json['id'] ?? '',
        farmId: json['farmId'] ?? '',
        fieldId: json['fieldId'],
        title: json['title'] ?? '',
        description: json['description'],
        startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : DateTime.now(),
        endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
        frequency: json['frequency'] ?? '',
        fertilizerType: json['fertilizerType'] ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        amountUnit: json['amountUnit'] ?? 'kg',
        applicationMethod: json['applicationMethod'] ?? 'broadcast',
        isActive: json['isActive'] ?? false,
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
        updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
        cropType: json['cropType'] ?? json['crop_type'] ?? '',
        area: (json['area'] as num?)?.toDouble() ?? 0.0,
        isExecuting: json['isExecuting'] ?? false,
      );
}

class FertilizationExecution {
  final String id;
  final String fertilizationScheduleId;
  final DateTime executedAt;
  final double actualAmount;
  final String? executedBy; // farmer ID or system
  final String status; // "planned", "executed", "skipped", "failed"
  final String? notes;
  
  // New fields for compatibility
  final String fertilizerType;
  final String unit;
  final double area;
  final String cropType;
  
  FertilizationExecution({
    required this.id,
    required this.fertilizationScheduleId,
    required this.executedAt,
    required this.actualAmount,
    this.executedBy,
    required this.status,
    this.notes,
    this.fertilizerType = 'NPK',
    this.unit = 'kg',
    this.area = 1.0,
    this.cropType = 'Wheat',
  });

  bool get isExecuted => status == 'executed';
  DateTime get applicationDate => executedAt;
  double get quantity => actualAmount;
  String get scheduleId => fertilizationScheduleId;

  Map<String, dynamic> toJson() => {
        'id': id,
        'fertilizationScheduleId': fertilizationScheduleId,
        'executedAt': executedAt.toIso8601String(),
        'actualAmount': actualAmount,
        'executedBy': executedBy,
        'status': status,
        'notes': notes,
        'fertilizerType': fertilizerType,
        'unit': unit,
        'area': area,
        'cropType': cropType,
      };

  factory FertilizationExecution.fromJson(Map<String, dynamic> json) => FertilizationExecution(
        id: json['id'] ?? '',
        fertilizationScheduleId: json['fertilizationScheduleId'] ?? '',
        executedAt: json['executedAt'] != null ? DateTime.parse(json['executedAt']) : DateTime.now(),
        actualAmount: (json['actualAmount'] as num?)?.toDouble() ?? 0.0,
        executedBy: json['executedBy'],
        status: json['status'] ?? 'planned',
        notes: json['notes'],
        fertilizerType: json['fertilizerType'] ?? json['fertilizer_type'] ?? 'NPK',
        unit: json['unit'] ?? 'kg',
        area: (json['area'] as num?)?.toDouble() ?? 1.0,
        cropType: json['cropType'] ?? json['crop_type'] ?? 'Wheat',
      );
}

/// Alias used by services and screens for fertilization execution records
typedef FertilizationApplication = FertilizationExecution;

/// Fertilization recommendation from AI/backend
class FertilizationRecommendation {
  final String id;
  final String farmId;
  final String cropType;
  final String fertilizerType;
  final double recommendedAmount;
  final String amountUnit;
  final String applicationMethod;
  final String reason;
  final DateTime recommendedDate;
  final DateTime createdAt;

  FertilizationRecommendation({
    required this.id,
    required this.farmId,
    required this.cropType,
    required this.fertilizerType,
    required this.recommendedAmount,
    required this.amountUnit,
    required this.applicationMethod,
    required this.reason,
    required this.recommendedDate,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'farmId': farmId,
        'cropType': cropType,
        'fertilizerType': fertilizerType,
        'recommendedAmount': recommendedAmount,
        'amountUnit': amountUnit,
        'applicationMethod': applicationMethod,
        'reason': reason,
        'recommendedDate': recommendedDate.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory FertilizationRecommendation.fromJson(Map<String, dynamic> json) =>
      FertilizationRecommendation(
        id: json['id'] ?? '',
        farmId: json['farmId'] ?? '',
        cropType: json['cropType'] ?? '',
        fertilizerType: json['fertilizerType'] ?? '',
        recommendedAmount: (json['recommendedAmount'] as num?)?.toDouble() ?? 0,
        amountUnit: json['amountUnit'] ?? '',
        applicationMethod: json['applicationMethod'] ?? '',
        reason: json['reason'] ?? '',
        recommendedDate: json['recommendedDate'] != null
            ? DateTime.parse(json['recommendedDate'])
            : DateTime.now(),
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
      );
}
