class PesticideSchedule {
  final String id;
  final String farmId;
  final String? fieldId;
  final String title;
  final String? description;
  final DateTime startDate;
  final DateTime? endDate;
  final String frequency; // "as_needed", "weekly", "biweekly", etc.
  final String
  pesticideType; // "insecticide", "fungicide", "herbicide", "organic"
  final String targetPest; // what pest/disease it targets
  final double amount; // quantity to apply
  final String amountUnit; // "ml", "liters", "grams", "kg"
  final String
  applicationMethod; // "spray", "drench", "granular", "seed_treatment"
  final int safetyIntervalDays; // days to wait before harvest after application
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Compatibility fields retained for the schedule-management UI.
  final String cropType;
  final double area;
  final bool isExecuting;

  PesticideSchedule({
    required this.id,
    this.farmId = '',
    this.fieldId,
    this.title = '',
    this.description,
    required this.startDate,
    this.endDate,
    required this.frequency,
    required this.pesticideType,
    this.targetPest = '',
    double? amount,
    String? amountUnit,
    this.applicationMethod = 'spray',
    this.safetyIntervalDays = 0,
    this.isActive = true,
    DateTime? createdAt,
    this.updatedAt,
    this.cropType = '',
    double? applicationRate,
    String? unit,
    this.area = 0,
    this.isExecuting = false,
  })  : amount = amount ?? applicationRate ?? 0,
        amountUnit = amountUnit ?? unit ?? 'ml',
        createdAt = createdAt ?? DateTime.now();

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
    'pesticideType': pesticideType,
    'targetPest': targetPest,
    'amount': amount,
    'amountUnit': amountUnit,
    'applicationMethod': applicationMethod,
    'safetyIntervalDays': safetyIntervalDays,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  factory PesticideSchedule.fromJson(Map<String, dynamic> json) =>
      PesticideSchedule(
        id: json['id'],
        farmId: json['farmId'],
        fieldId: json['fieldId'],
        title: json['title'],
        description: json['description'],
        startDate: DateTime.parse(json['startDate']),
        endDate: json['endDate'] != null
            ? DateTime.parse(json['endDate'])
            : null,
        frequency: json['frequency'],
        pesticideType: json['pesticideType'],
        targetPest: json['targetPest'],
        amount: json['amount'],
        amountUnit: json['amountUnit'],
        applicationMethod: json['applicationMethod'],
        safetyIntervalDays: json['safetyIntervalDays'],
        isActive: json['isActive'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'])
            : null,
      );
}

class PesticideApplication {
  final String id;
  final String pesticideScheduleId;
  final DateTime appliedAt;
  final double actualAmount;
  final String? appliedBy; // farmer ID or system
  final String status; // "planned", "applied", "skipped", "failed"
  final String? notes;
  final double? efficacyRating; // 1-5 scale of effectiveness observed

  // Additional getters used by UI screens
  String get scheduleId => pesticideScheduleId;
  DateTime get applicationDate => appliedAt;
  bool get isExecuted => status == 'applied';
  String get pesticideType => notes ?? '';
  double get quantity => actualAmount;
  String get unit => 'ml';
  String get area => '';
  String get cropType => '';

  PesticideApplication({
    required this.id,
    required this.pesticideScheduleId,
    required this.appliedAt,
    required this.actualAmount,
    this.appliedBy,
    required this.status,
    this.notes,
    this.efficacyRating,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'pesticideScheduleId': pesticideScheduleId,
    'appliedAt': appliedAt.toIso8601String(),
    'actualAmount': actualAmount,
    'appliedBy': appliedBy,
    'status': status,
    'notes': notes,
    'efficacyRating': efficacyRating,
  };

  factory PesticideApplication.fromJson(Map<String, dynamic> json) =>
      PesticideApplication(
        id: json['id'],
        pesticideScheduleId: json['pesticideScheduleId'],
        appliedAt: DateTime.parse(json['appliedAt']),
        actualAmount: json['actualAmount'],
        appliedBy: json['appliedBy'],
        status: json['status'],
        notes: json['notes'],
        efficacyRating: json['efficacyRating'],
      );
}

/// Pesticide recommendation from AI/backend
class PesticideRecommendation {
  final String id;
  final String farmId;
  final String cropType;
  final String pesticideType;
  final String targetPest;
  final double recommendedAmount;
  final String amountUnit;
  final String applicationMethod;
  final int safetyIntervalDays;
  final String reason;
  final DateTime recommendedDate;
  final DateTime createdAt;

  PesticideRecommendation({
    required this.id,
    required this.farmId,
    required this.cropType,
    required this.pesticideType,
    required this.targetPest,
    required this.recommendedAmount,
    required this.amountUnit,
    required this.applicationMethod,
    required this.safetyIntervalDays,
    required this.reason,
    required this.recommendedDate,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'farmId': farmId,
    'cropType': cropType,
    'pesticideType': pesticideType,
    'targetPest': targetPest,
    'recommendedAmount': recommendedAmount,
    'amountUnit': amountUnit,
    'applicationMethod': applicationMethod,
    'safetyIntervalDays': safetyIntervalDays,
    'reason': reason,
    'recommendedDate': recommendedDate.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory PesticideRecommendation.fromJson(Map<String, dynamic> json) =>
      PesticideRecommendation(
        id: json['id'] ?? '',
        farmId: json['farmId'] ?? '',
        cropType: json['cropType'] ?? '',
        pesticideType: json['pesticideType'] ?? '',
        targetPest: json['targetPest'] ?? '',
        recommendedAmount: (json['recommendedAmount'] as num?)?.toDouble() ?? 0,
        amountUnit: json['amountUnit'] ?? '',
        applicationMethod: json['applicationMethod'] ?? '',
        safetyIntervalDays: json['safetyIntervalDays'] ?? 0,
        reason: json['reason'] ?? '',
        recommendedDate: json['recommendedDate'] != null
            ? DateTime.parse(json['recommendedDate'])
            : DateTime.now(),
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
      );
}
