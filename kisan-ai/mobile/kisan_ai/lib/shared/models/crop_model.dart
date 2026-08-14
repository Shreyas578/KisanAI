class Crop {
  final String id;
  final String name; // e.g., "Tomato", "Wheat", "Rice"
  final String scientificName; // e.g., "Solanum lycopersicum"
  final String variety; // Specific variety name
  final String category; // e.g., "vegetable", "grain", "fruit", "legume"
  final String season; // e.g., "kharif", "rabi", "zaid", "perennial"
  final int durationDays; // Days from planting to harvest
  final double waterRequirement; // mm per season
  final List<String> suitableSoilTypes; // e.g., ["loamy", "sandy loam", "clay loam"]
  final double optimalTemperatureMin; // Minimum optimal temperature in Celsius
  final double optimalTemperatureMax; // Maximum optimal temperature in Celsius
  final List<int> plantingMonths; // Months when planting is recommended (1-12)
  final List<int> harvestMonths; // Months when harvesting occurs (1-12)
  final bool isPerennial; // Whether the crop is perennial or annual

  Crop({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.variety,
    required this.category,
    required this.season,
    required this.durationDays,
    required this.waterRequirement,
    required this.suitableSoilTypes,
    required this.optimalTemperatureMin,
    required this.optimalTemperatureMax,
    required this.plantingMonths,
    required this.harvestMonths,
    required this.isPerennial,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'scientificName': scientificName,
        'variety': variety,
        'category': category,
        'season': season,
        'durationDays': durationDays,
        'waterRequirement': waterRequirement,
        'suitableSoilTypes': suitableSoilTypes,
        'optimalTemperatureMin': optimalTemperatureMin,
        'optimalTemperatureMax': optimalTemperatureMax,
        'plantingMonths': plantingMonths,
        'harvestMonths': harvestMonths,
        'isPerennial': isPerennial,
      };

  factory Crop.fromJson(Map<String, dynamic> json) => Crop(
        id: json['id'],
        name: json['name'],
        scientificName: json['scientificName'],
        variety: json['variety'],
        category: json['category'],
        season: json['season'],
        durationDays: json['durationDays'],
        waterRequirement: json['waterRequirement'],
        suitableSoilTypes: List<String>.from(json['suitableSoilTypes']),
        optimalTemperatureMin: json['optimalTemperatureMin'],
        optimalTemperatureMax: json['optimalTemperatureMax'],
        plantingMonths: List<int>.from(json['plantingMonths']),
        harvestMonths: List<int>.from(json['harvestMonths']),
        isPerennial: json['isPerennial'],
      );
}
