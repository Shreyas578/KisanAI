class Disease {
  final String id;
  final String name; // Common name of the disease
  final String scientificName; // Scientific/pathogen name
  final String description; // Detailed description
  final List<String> symptoms; // List of symptoms
  final String causalOrganism; // Fungus, bacteria, virus, etc.
  final List<String> affectedCrops; // List of crop names or IDs
  final List<String> preventiveMeasures; // Prevention methods
  final List<String> treatmentOptions; // Treatment options (organic/chemical)
  final String severityLevel; // "low", "medium", "high"
  final String imageUrl; // URL to reference image
  final List<String> favorableConditions; // Conditions that promote the disease
  final DateTime createdAt;
  final DateTime updatedAt;

  Disease({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.description,
    required this.symptoms,
    required this.causalOrganism,
    required this.affectedCrops,
    required this.preventiveMeasures,
    required this.treatmentOptions,
    required this.severityLevel,
    required this.imageUrl,
    required this.favorableConditions,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'scientificName': scientificName,
        'description': description,
        'symptoms': symptoms,
        'causalOrganism': causalOrganism,
        'affectedCrops': affectedCrops,
        'preventiveMeasures': preventiveMeasures,
        'treatmentOptions': treatmentOptions,
        'severityLevel': severityLevel,
        'imageUrl': imageUrl,
        'favorableConditions': favorableConditions,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Disease.fromJson(Map<String, dynamic> json) => Disease(
        id: json['id'],
        name: json['name'],
        scientificName: json['scientificName'],
        description: json['description'],
        symptoms: List<String>.from(json['symptoms']),
        causalOrganism: json['causalOrganism'],
        affectedCrops: List<String>.from(json['affectedCrops']),
        preventiveMeasures: List<String>.from(json['preventiveMeasures']),
        treatmentOptions: List<String>.from(json['treatmentOptions']),
        severityLevel: json['severityLevel'],
        imageUrl: json['imageUrl'],
        favorableConditions: List<String>.from(json['favorableConditions']),
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
      );
}
