import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'dart:convert';
import 'package:flutter/services.dart';

/// On-device disease detection using TFLite
class DiseaseDetectionService {
  late Interpreter _interpreter;
  List<String> _labels = [];
  bool _isInitialized = false;
  
  /// Initialize TFLite model
  Future<void> initialize() async {
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/models/crop_disease_model.tflite',
      );
      
      // Load labels
      await _loadLabels();
      
      _isInitialized = true;
      print('✅ TFLite model loaded');
    } catch (e) {
      print('❌ Failed to load TFLite: $e');
      _isInitialized = false;
    }
  }
  
  /// Load disease labels
  Future<void> _loadLabels() async {
    try {
      final labelData = await rootBundle.loadString('assets/models/disease_labels.json');
      final json = jsonDecode(labelData) as Map<String, dynamic>;
      _labels = List<String>.from(json['labels'] as List);
    } catch (e) {
      print('Error loading labels: $e');
      _labels = ['Healthy', 'Disease'];
    }
  }
  
  /// Detect disease from image
  Future<DiseaseDetectionResult> detectDisease(
    Uint8List imageBytes, {
    required String cropType,
  }) async {
    if (!_isInitialized) {
      throw Exception('Model not initialized');
    }
    
    try {
      // Decode and resize image
      final image = img.decodeImage(imageBytes);
      if (image == null) throw Exception('Failed to decode image');
      
      final resized = img.copyResize(image, width: 224, height: 224);
      
      // Prepare input
      final input = _imageToInput(resized);
      
      // Run inference
      final output = List<double>.filled(
        _labels.length > 0 ? _labels.length : 10,
        0.0,
      );
      _interpreter.run(input, output);
      
      // Get predictions
      final predictions = _getTopPredictions(output);
      
      if (predictions.isEmpty) {
        return DiseaseDetectionResult(
          disease: 'Unable to detect',
          confidence: 0.0,
          treatment: 'Could not analyze image',
          alternatives: [],
        );
      }
      
      return DiseaseDetectionResult(
        disease: predictions[0]['label'] as String,
        confidence: predictions[0]['confidence'] as double,
        treatment: _getTreatmentAdvice(predictions[0]['label'] as String),
        alternatives: predictions
            .skip(1)
            .take(2)
            .map((p) => p['label'] as String)
            .toList(),
      );
    } catch (e) {
      print('❌ Disease detection error: $e');
      rethrow;
    }
  }
  
  /// Convert image to model input
  List<List<List<List<double>>>> _imageToInput(img.Image image) {
    final input = List.generate(
      1,
      (_) => List.generate(
        224,
        (y) => List.generate(
          224,
          (x) {
            final pixel = image.getPixelSafe(x, y);
            return [
              (pixel.r as int) / 255.0,
              (pixel.g as int) / 255.0,
              (pixel.b as int) / 255.0,
            ];
          },
        ),
      ),
    );
    return input;
  }
  
  /// Get top predictions
  List<Map<String, dynamic>> _getTopPredictions(List<double> output) {
    final predictions = <Map<String, dynamic>>[];
    
    for (int i = 0; i < output.length && i < _labels.length; i++) {
      predictions.add({
        'label': _labels[i],
        'confidence': output[i],
      });
    }
    
    predictions.sort((a, b) =>
        (b['confidence'] as double).compareTo(a['confidence'] as double));
    
    return predictions;
  }
  
  /// Get treatment advice
  String _getTreatmentAdvice(String disease) {
    final treatments = {
      'Healthy': '✅ Your crop is healthy! Continue regular maintenance.',
      'Early_Blight': 'Spray copper fungicide. Remove infected leaves.',
      'Late_Blight': 'Use systemic fungicide. Improve drainage.',
      'Leaf_Spot': 'Apply neem oil. Increase plant spacing.',
      'Powdery_Mildew': 'Use sulfur dust. Improve air circulation.',
      'Rust': 'Spray copper fungicide.',
      'Leaf_Blight': 'Apply fungicide immediately. Remove affected leaves.',
      'Anthracnose': 'Use copper-based fungicide.',
    };
    
    return treatments[disease] ?? 'Consult with agricultural expert.';
  }
  
  /// Dispose
  void dispose() {
    _interpreter.close();
  }
}

/// Disease detection result
class DiseaseDetectionResult {
  final String disease;
  final double confidence;
  final String treatment;
  final List<String> alternatives;
  
  DiseaseDetectionResult({
    required this.disease,
    required this.confidence,
    required this.treatment,
    required this.alternatives,
  });
  
  Map<String, dynamic> toJson() => {
    'disease': disease,
    'confidence': (confidence * 100).toStringAsFixed(1),
    'treatment': treatment,
    'alternatives': alternatives,
  };
}
