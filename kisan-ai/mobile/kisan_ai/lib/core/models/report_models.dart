import 'package:json_annotation/json_annotation.dart';

part 'report_models.g.dart';

// ============= 365-Day Plan Models =============

@JsonSerializable()
class ReportResponse {
  final String reportId;
  final PlanData plan;

  ReportResponse({required this.reportId, required this.plan});

  factory ReportResponse.fromJson(Map<String, dynamic> json) =>
      _$ReportResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ReportResponseToJson(this);
}

@JsonSerializable()
class PlanData {
  final List<MonthlyPlan> monthlyPlans;
  final HarvestInfo? harvestInfo;
  final FinancialSummary? financialSummary;
  final List<String>? recommendations;
  final List<String>? governmentSchemes;

  PlanData({
    required this.monthlyPlans,
    this.harvestInfo,
    this.financialSummary,
    this.recommendations,
    this.governmentSchemes,
  });

  factory PlanData.fromJson(Map<String, dynamic> json) =>
      _$PlanDataFromJson(json);
  Map<String, dynamic> toJson() => _$PlanDataToJson(this);
}

@JsonSerializable()
class MonthlyPlan {
  final String month;
  final List<String>? tasks;
  final List<String>? pestsToWatch;
  final List<DiseaseAlert>? diseaseAlerts;
  final List<Input>? inputs;
  final String? waterSchedule;
  final int? estimatedCost;

  MonthlyPlan({
    required this.month,
    this.tasks,
    this.pestsToWatch,
    this.diseaseAlerts,
    this.inputs,
    this.waterSchedule,
    this.estimatedCost,
  });

  factory MonthlyPlan.fromJson(Map<String, dynamic> json) =>
      _$MonthlyPlanFromJson(json);
  Map<String, dynamic> toJson() => _$MonthlyPlanToJson(this);
}

@JsonSerializable()
class DiseaseAlert {
  final String name;
  final String? severity;
  final String? preventiveMeasure;

  DiseaseAlert({required this.name, this.severity, this.preventiveMeasure});

  factory DiseaseAlert.fromJson(Map<String, dynamic> json) =>
      _$DiseaseAlertFromJson(json);
  Map<String, dynamic> toJson() => _$DiseaseAlertToJson(this);
}

@JsonSerializable()
class Input {
  final String name;
  final String? quantity;
  final int? cost;

  Input({required this.name, this.quantity, this.cost});

  factory Input.fromJson(Map<String, dynamic> json) => _$InputFromJson(json);
  Map<String, dynamic> toJson() => _$InputToJson(this);
}

@JsonSerializable()
class HarvestInfo {
  final String? expectedDate;
  final String? yieldRange;
  final String? bestSellingWindow;

  HarvestInfo({this.expectedDate, this.yieldRange, this.bestSellingWindow});

  factory HarvestInfo.fromJson(Map<String, dynamic> json) =>
      _$HarvestInfoFromJson(json);
  Map<String, dynamic> toJson() => _$HarvestInfoToJson(this);
}

@JsonSerializable()
class FinancialSummary {
  final int? totalCost;
  final Revenue? revenue;
  final NetProfit? netProfit;

  FinancialSummary({this.totalCost, this.revenue, this.netProfit});

  factory FinancialSummary.fromJson(Map<String, dynamic> json) =>
      _$FinancialSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$FinancialSummaryToJson(this);
}

@JsonSerializable()
class Revenue {
  final int? lowPrice;
  final int? avgPrice;
  final int? highPrice;

  Revenue({this.lowPrice, this.avgPrice, this.highPrice});

  factory Revenue.fromJson(Map<String, dynamic> json) =>
      _$RevenueFromJson(json);
  Map<String, dynamic> toJson() => _$RevenueToJson(this);
}

@JsonSerializable()
class NetProfit {
  final int? lowPrice;
  final int? avgPrice;
  final int? highPrice;

  NetProfit({this.lowPrice, this.avgPrice, this.highPrice});

  factory NetProfit.fromJson(Map<String, dynamic> json) =>
      _$NetProfitFromJson(json);
  Map<String, dynamic> toJson() => _$NetProfitToJson(this);
}

// ============= Crop Recommendations Models =============

@JsonSerializable()
class RecommendationsResponse {
  final String reportId;
  final RecommendationData recommendations;

  RecommendationsResponse({
    required this.reportId,
    required this.recommendations,
  });

  factory RecommendationsResponse.fromJson(Map<String, dynamic> json) =>
      _$RecommendationsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$RecommendationsResponseToJson(this);
}

@JsonSerializable()
class RecommendationData {
  final List<CropRecommendation>? recommendations;
  final BestRecommendation? bestRecommendation;
  final QuickStartPlan? quickStartPlan;

  RecommendationData({
    this.recommendations,
    this.bestRecommendation,
    this.quickStartPlan,
  });

  factory RecommendationData.fromJson(Map<String, dynamic> json) =>
      _$RecommendationDataFromJson(json);
  Map<String, dynamic> toJson() => _$RecommendationDataToJson(this);
}

@JsonSerializable()
class CropRecommendation {
  final int rank;
  final String cropName;
  final int suitabilityScore;
  final String? reason;
  final MarketPriceRange? marketPrice;
  final String? sixMonthForecast;
  final String? expectedYield;
  final int? waterRequirementMatch;
  final int? profitPerAcre;
  final String? riskLevel;
  final String? sowingWindow;
  final List<String>? benefits;
  final List<String>? challenges;

  CropRecommendation({
    required this.rank,
    required this.cropName,
    required this.suitabilityScore,
    this.reason,
    this.marketPrice,
    this.sixMonthForecast,
    this.expectedYield,
    this.waterRequirementMatch,
    this.profitPerAcre,
    this.riskLevel,
    this.sowingWindow,
    this.benefits,
    this.challenges,
  });

  factory CropRecommendation.fromJson(Map<String, dynamic> json) =>
      _$CropRecommendationFromJson(json);
  Map<String, dynamic> toJson() => _$CropRecommendationToJson(this);
}

@JsonSerializable()
class MarketPriceRange {
  final int? min;
  final int? avg;
  final int? max;

  MarketPriceRange({this.min, this.avg, this.max});

  factory MarketPriceRange.fromJson(Map<String, dynamic> json) =>
      _$MarketPriceRangeFromJson(json);
  Map<String, dynamic> toJson() => _$MarketPriceRangeToJson(this);
}

@JsonSerializable()
class BestRecommendation {
  final String? crop;
  final String? reason;
  final int? expectedProfit;

  BestRecommendation({this.crop, this.reason, this.expectedProfit});

  factory BestRecommendation.fromJson(Map<String, dynamic> json) =>
      _$BestRecommendationFromJson(json);
  Map<String, dynamic> toJson() => _$BestRecommendationToJson(this);
}

@JsonSerializable()
class QuickStartPlan {
  @JsonKey(name: 'week1')
  final List<String>? week1;
  @JsonKey(name: 'week2')
  final List<String>? week2;
  @JsonKey(name: 'week3')
  final List<String>? week3;
  @JsonKey(name: 'week4')
  final List<String>? week4;

  QuickStartPlan({this.week1, this.week2, this.week3, this.week4});

  factory QuickStartPlan.fromJson(Map<String, dynamic> json) =>
      _$QuickStartPlanFromJson(json);
  Map<String, dynamic> toJson() => _$QuickStartPlanToJson(this);
}

// ============= Report Listing Models =============

@JsonSerializable()
class ReportDataResponse {
  final String id;
  final String farm_profile_id;
  final String? report_type;
  final Map<String, dynamic>? report_data;
  final String? generated_at;

  ReportDataResponse({
    required this.id,
    required this.farm_profile_id,
    this.report_type,
    this.report_data,
    this.generated_at,
  });

  factory ReportDataResponse.fromJson(Map<String, dynamic> json) =>
      _$ReportDataResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ReportDataResponseToJson(this);
}

@JsonSerializable()
class ReportSummary {
  final String id;
  final String farm_profile_id;
  final String? report_type;
  final String? generated_at;

  ReportSummary({
    required this.id,
    required this.farm_profile_id,
    this.report_type,
    this.generated_at,
  });

  factory ReportSummary.fromJson(Map<String, dynamic> json) =>
      _$ReportSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$ReportSummaryToJson(this);
}
