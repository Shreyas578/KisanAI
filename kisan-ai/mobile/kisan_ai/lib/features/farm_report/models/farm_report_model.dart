/// Farm Report Data Model
class FarmReportData {
  final String reportId;
  final String farmerId;
  final String reportType; // '365_day_plan' or 'crop_recommendation'
  final String cropName;
  final DateTime createdAt;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status; // 'draft', 'generated', 'reviewed'
  final Map<String, dynamic> reportContent;
  final List<String> recommendations;
  final List<Map<String, dynamic>> tasks;
  final Map<String, dynamic>? estimatedCosts;
  final String? summary;

  FarmReportData({
    required this.reportId,
    required this.farmerId,
    required this.reportType,
    required this.cropName,
    required this.createdAt,
    this.startDate,
    this.endDate,
    this.status = 'generated',
    this.reportContent = const {},
    this.recommendations = const [],
    this.tasks = const [],
    this.estimatedCosts,
    this.summary,
  });

  /// Create copy with changes
  FarmReportData copyWith({
    String? reportId,
    String? farmerId,
    String? reportType,
    String? cropName,
    DateTime? createdAt,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    Map<String, dynamic>? reportContent,
    List<String>? recommendations,
    List<Map<String, dynamic>>? tasks,
    Map<String, dynamic>? estimatedCosts,
    String? summary,
  }) {
    return FarmReportData(
      reportId: reportId ?? this.reportId,
      farmerId: farmerId ?? this.farmerId,
      reportType: reportType ?? this.reportType,
      cropName: cropName ?? this.cropName,
      createdAt: createdAt ?? this.createdAt,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      reportContent: reportContent ?? this.reportContent,
      recommendations: recommendations ?? this.recommendations,
      tasks: tasks ?? this.tasks,
      estimatedCosts: estimatedCosts ?? this.estimatedCosts,
      summary: summary ?? this.summary,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'reportId': reportId,
    'farmerId': farmerId,
    'reportType': reportType,
    'cropName': cropName,
    'createdAt': createdAt.toIso8601String(),
    'startDate': startDate?.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'status': status,
    'reportContent': reportContent,
    'recommendations': recommendations,
    'tasks': tasks,
    'estimatedCosts': estimatedCosts,
    'summary': summary,
  };

  /// Create from JSON
  factory FarmReportData.fromJson(Map<String, dynamic> json) => FarmReportData(
    reportId: json['reportId'] ?? '',
    farmerId: json['farmerId'] ?? '',
    reportType: json['reportType'] ?? 'crop_recommendation',
    cropName: json['cropName'] ?? '',
    createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    startDate: DateTime.tryParse(json['startDate'] ?? ''),
    endDate: DateTime.tryParse(json['endDate'] ?? ''),
    status: json['status'] ?? 'generated',
    reportContent: json['reportContent'] ?? {},
    recommendations: List<String>.from(json['recommendations'] ?? []),
    tasks: List<Map<String, dynamic>>.from(json['tasks'] ?? []),
    estimatedCosts: json['estimatedCosts'],
    summary: json['summary'],
  );
}
