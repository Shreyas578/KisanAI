import 'package:json_annotation/json_annotation.dart';

part 'market_models.g.dart';

// ============= Market Price Models =============

@JsonSerializable()
class MarketData {
  final String commodity;
  final String state;
  final List<MarketPrice> markets;

  MarketData({
    required this.commodity,
    required this.state,
    required this.markets,
  });

  factory MarketData.fromJson(Map<String, dynamic> json) =>
      _$MarketDataFromJson(json);
  Map<String, dynamic> toJson() => _$MarketDataToJson(this);
}

@JsonSerializable()
class MarketPrice {
  final String mandi;
  final int min;
  final int modal;
  final int max;
  final String? lastUpdated;

  MarketPrice({
    required this.mandi,
    required this.min,
    required this.modal,
    required this.max,
    this.lastUpdated,
  });

  factory MarketPrice.fromJson(Map<String, dynamic> json) =>
      _$MarketPriceFromJson(json);
  Map<String, dynamic> toJson() => _$MarketPriceToJson(this);
}

// ============= Price Forecast Models =============

@JsonSerializable()
class PriceForecast {
  final int predictedPrice;
  final int confidence;
  final String trend; // rising, falling, stable
  final List<String>? keyFactors;
  final String? bestSellStart;
  final String? bestSellEnd;
  final String? riskLevel;

  PriceForecast({
    required this.predictedPrice,
    required this.confidence,
    required this.trend,
    this.keyFactors,
    this.bestSellStart,
    this.bestSellEnd,
    this.riskLevel,
  });

  factory PriceForecast.fromJson(Map<String, dynamic> json) =>
      _$PriceForecastFromJson(json);
  Map<String, dynamic> toJson() => _$PriceForecastToJson(this);
}

// ============= Smart Price Models =============

@JsonSerializable()
class SmartPriceSuggestion {
  final int suggested;
  final int min;
  final int max;
  final int modal;
  final int confidence;
  final String reasoning;
  final Profitability? profitability;

  SmartPriceSuggestion({
    required this.suggested,
    required this.min,
    required this.max,
    required this.modal,
    required this.confidence,
    required this.reasoning,
    this.profitability,
  });

  factory SmartPriceSuggestion.fromJson(Map<String, dynamic> json) =>
      _$SmartPriceSuggestionFromJson(json);
  Map<String, dynamic> toJson() => _$SmartPriceSuggestionToJson(this);
}

@JsonSerializable()
class Profitability {
  final int costPerUnit;
  final int suggestedPrice;
  final int profitPerUnit;
  final String marginPercentage;

  Profitability({
    required this.costPerUnit,
    required this.suggestedPrice,
    required this.profitPerUnit,
    required this.marginPercentage,
  });

  factory Profitability.fromJson(Map<String, dynamic> json) =>
      _$ProfitabilityFromJson(json);
  Map<String, dynamic> toJson() => _$ProfitabilityToJson(this);
}

// ============= Price Alert Models =============

@JsonSerializable()
class CreateAlertRequest {
  final String commodity;
  final String state;
  final int targetPrice;
  final String condition; // above or below

  CreateAlertRequest({
    required this.commodity,
    required this.state,
    required this.targetPrice,
    required this.condition,
  });

  factory CreateAlertRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateAlertRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateAlertRequestToJson(this);
}

@JsonSerializable()
class PriceAlert {
  final String id;
  final String commodity;
  final String state;
  final int target_price;
  final String condition;
  final bool is_active;
  final String? last_triggered;
  final String? created_at;

  PriceAlert({
    required this.id,
    required this.commodity,
    required this.state,
    required this.target_price,
    required this.condition,
    required this.is_active,
    this.last_triggered,
    this.created_at,
  });

  factory PriceAlert.fromJson(Map<String, dynamic> json) =>
      _$PriceAlertFromJson(json);
  Map<String, dynamic> toJson() => _$PriceAlertToJson(this);
}

// ============= Demand Score Models =============

@JsonSerializable()
class DemandScore {
  final int demandScore;

  DemandScore({required this.demandScore});

  factory DemandScore.fromJson(Map<String, dynamic> json) =>
      _$DemandScoreFromJson(json);
  Map<String, dynamic> toJson() => _$DemandScoreToJson(this);
}
