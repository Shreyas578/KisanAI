import 'dart:typed_data';

/// Disease Detection Service
/// Note: Offline TFLite model support removed to fix build issues
/// Current implementation: Online detection via Groq Vision API only
/// TODO: Re-add tflite_flutter when compatible version is available
class DiseaseDetectionService {
  static final DiseaseDetectionService _instance =
      DiseaseDetectionService._internal();
  factory DiseaseDetectionService() => _instance;
  DiseaseDetectionService._internal();

  bool _isModelLoaded = false;

  Future<void> loadModel() async {
    // Offline model disabled - online mode only
    _isModelLoaded = true;
  }

  Future<DiseaseDetectionResult> detectDisease(Uint8List imageBytes) async {
    // Placeholder - actual disease detection happens via backend API
    // This method is deprecated in favor of DiseaseDetectionController
    throw Exception(
      'Use DiseaseDetectionController for disease detection via Groq Vision API',
    );
  }

  List<String> getDetectableDiseases() => [];
  bool get isModelLoaded => _isModelLoaded;

  void dispose() {
    _isModelLoaded = false;
  }
}

class DiseaseDetectionResult {
  final String diseaseName;
  final double confidence;
  final Map<String, double> allPredictions;
  final DateTime timestamp;

  DiseaseDetectionResult({
    required this.diseaseName,
    required this.confidence,
    required this.allPredictions,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'diseaseName': diseaseName,
    'confidence': confidence,
    'allPredictions': allPredictions,
    'timestamp': timestamp.toIso8601String(),
  };

  factory DiseaseDetectionResult.fromJson(Map<String, dynamic> json) =>
      DiseaseDetectionResult(
        diseaseName: json['diseaseName'] as String,
        confidence: json['confidence'] as double,
        allPredictions: Map<String, double>.from(json['allPredictions'] as Map),
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}
