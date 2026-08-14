class FarmReport {
  final String id;
  final String farmerId;
  final String farmId;
  final String title;
  final String? description;
  final DateTime generatedAt;
  final DateTime validUntil;
  
  // Farm Health Metrics
  double overallHealthScore; // 0-100
  String healthStatus; // "excellent", "good", "fair", "poor", "critical"
  
  // Yield Prediction
  double predictedYield; // Expected yield in units
  String yieldUnit; // e.g., "kg", "quintal", "tons"
  double confidenceLevel; // 0-100
  
  // Risk Assessment
  List<String> riskFactors;
  List<String> recommendations;
  
  // Financial Projections
  double estimatedRevenue;
  double estimatedCost;
  double estimatedProfit;
  
  // Action Items
  List<ActionItem> actionItems;
  
  // Environmental Factors
  WeatherSummary weatherSummary;
  SoilHealth soilHealth;
  
  FarmReport({
    required this.id,
    required this.farmerId,
    required this.farmId,
    required this.title,
    this.description,
    required this.generatedAt,
    required this.validUntil,
    required this.overallHealthScore,
    required this.healthStatus,
    required this.predictedYield,
    required this.yieldUnit,
    required this.confidenceLevel,
    required this.riskFactors,
    required this.recommendations,
    required this.estimatedRevenue,
    required this.estimatedCost,
    required this.estimatedProfit,
    required this.actionItems,
    required this.weatherSummary,
    required this.soilHealth,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'farmerId': farmerId,
        'farmId': farmId,
        'title': title,
        'description': description,
        'generatedAt': generatedAt.toIso8601String(),
        'validUntil': validUntil.toIso8601String(),
        'overallHealthScore': overallHealthScore,
        'healthStatus': healthStatus,
        'predictedYield': predictedYield,
        'yieldUnit': yieldUnit,
        'confidenceLevel': confidenceLevel,
        'riskFactors': riskFactors,
        'recommendations': recommendations,
        'estimatedRevenue': estimatedRevenue,
        'estimatedCost': estimatedCost,
        'estimatedProfit': estimatedProfit,
        'actionItems': actionItems.map((e) => e.toJson()).toList(),
        'weatherSummary': weatherSummary.toJson(),
        'soilHealth': soilHealth.toJson(),
      };

  factory FarmReport.fromJson(Map<String, dynamic> json) => FarmReport(
        id: json['id'],
        farmerId: json['farmerId'],
        farmId: json['farmId'],
        title: json['title'],
        description: json['description'],
        generatedAt: DateTime.parse(json['generatedAt']),
        validUntil: DateTime.parse(json['validUntil']),
        overallHealthScore: json['overallHealthScore'],
        healthStatus: json['healthStatus'],
        predictedYield: json['predictedYield'],
        yieldUnit: json['yieldUnit'],
        confidenceLevel: json['confidenceLevel'],
        riskFactors: List<String>.from(json['riskFactors']),
        recommendations: List<String>.from(json['recommendations']),
        estimatedRevenue: json['estimatedRevenue'],
        estimatedCost: json['estimatedCost'],
        estimatedProfit: json['estimatedProfit'],
        actionItems: List<ActionItem>.from(json['actionItems'].map((x) => ActionItem.fromJson(x))),
        weatherSummary: WeatherSummary.fromJson(json['weatherSummary']),
        soilHealth: SoilHealth.fromJson(json['soilHealth']),
      );
}

class ActionItem {
  final String id;
  final String title;
  final String description;
  final String priority; // "high", "medium", "low"
  final String status; // "pending", "in_progress", "completed"
  final DateTime dueDate;
  final String category; // "irrigation", "fertilization", "pesticide", etc.
  
  ActionItem({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.dueDate,
    required this.category,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'priority': priority,
        'status': status,
        'dueDate': dueDate.toIso8601String(),
        'category': category,
      };

  factory ActionItem.fromJson(Map<String, dynamic> json) => ActionItem(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        priority: json['priority'],
        status: json['status'],
        dueDate: DateTime.parse(json['dueDate']),
        category: json['category'],
      );
}

class WeatherSummary {
  final double temperatureAvg;
  final double rainfallTotal;
  final double humidityAvg;
  final String condition; // "sunny", "rainy", "cloudy", etc.
  
  WeatherSummary({
    required this.temperatureAvg,
    required this.rainfallTotal,
    required this.humidityAvg,
    required this.condition,
  });

  Map<String, dynamic> toJson() => {
        'temperatureAvg': temperatureAvg,
        'rainfallTotal': rainfallTotal,
        'humidityAvg': humidityAvg,
        'condition': condition,
      };

  factory WeatherSummary.fromJson(Map<String, dynamic> json) => WeatherSummary(
        temperatureAvg: json['temperatureAvg'],
        rainfallTotal: json['rainfallTotal'],
        humidityAvg: json['humidityAvg'],
        condition: json['condition'],
      );
}

class SoilHealth {
  final double phLevel;
  final double nitrogen;
  final double phosphorus;
  final double potassium;
  final double organicMatter;
  final String texture; // "sandy", "loamy", "clay", etc.
  
  SoilHealth({
    required this.phLevel,
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.organicMatter,
    required this.texture,
  });

  Map<String, dynamic> toJson() => {
        'phLevel': phLevel,
        'nitrogen': nitrogen,
        'phosphorus': phosphorus,
        'potassium': potassium,
        'organicMatter': organicMatter,
        'texture': texture,
      };

  factory SoilHealth.fromJson(Map<String, dynamic> json) => SoilHealth(
        phLevel: json['phLevel'],
        nitrogen: json['nitrogen'],
        phosphorus: json['phosphorus'],
        potassium: json['potassium'],
        organicMatter: json['organicMatter'],
        texture: json['texture'],
      );
}
