import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'ai_service_base.dart';

/// Manages AI service selection based on connectivity and availability
class AiServiceManager {
  final Map<AiModelType, BaseAiService> _services = {};
  AiModelType _preferredModel = AiModelType.groqLlama370b;
  AiModelType? _currentModel;
  bool _isInitializing = false;

  /// Initialize the AI service manager
  Future<void> initialize() async {
    if (_isInitializing) return;
    _isInitializing = true;

    try {
      // Initialize connectivity listener
      _connectivitySubscription = Connectivity()
          .onConnectivityChanged
          .listen(_onConnectivityChanged);

      // Initialize preferred services
      await _initializeService(_preferredModel);

      // Also initialize fallback offline services
      await _initializeService(AiModelType.mistral7bGguf);
      await _initializeService(AiModelType.nllb200);
      await _initializeService(AiModelType.whisperTiny);
      await _initializeService(AiModelType.ruleBased);

      // Determine initial active model based on connectivity
      await _updateActiveModel();
    } finally {
      _isInitializing = false;
    }
  }

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  /// Handle connectivity changes
  void _onConnectivityChanged(List<ConnectivityResult> results) {
    _updateActiveModel();
  }

  /// Update the active model based on current connectivity and availability
  Future<void> _updateActiveModel() async {
    final hasInternet = await _hasInternetConnectivity();

    if (hasInternet &&
        _services[_preferredModel] != null &&
        await _services[_preferredModel]!.isReady()) {
      _currentModel = _preferredModel;
    } else {
      // Fallback to best available offline model
      _currentModel = _getBestAvailableOfflineModel();
    }

    debugPrint('AI Service Manager: Active model set to $_currentModel');
  }

  /// Check if we have internet connectivity
  Future<bool> _hasInternetConnectivity() async {
    try {
      final results = await Connectivity().checkConnectivity();
      return results.any((r) =>
          r != ConnectivityResult.none);
    } catch (e) {
      return false;
    }
  }

  /// Get the best available offline model based on capabilities
  AiModelType _getBestAvailableOfflineModel() {
    // Check available offline models in order of preference
    final offlineModels = [
      AiModelType.mistral7bGguf, // Best for text generation
      AiModelType.ruleBased,     // Fallback
    ];

    for (final modelType in offlineModels) {
      if (_services[modelType] != null) {
        return modelType;
      }
    }

    // Last resort
    return AiModelType.ruleBased;
  }

  /// Initialize a specific AI service
  Future<void> _initializeService(AiModelType type) async {
    if (_services.containsKey(type)) return;

    try {
      // Import and initialize the specific service implementation
      switch (type) {
        case AiModelType.groqLlama370b:
        case AiModelType.groqMixtral8x22b:
          // Import Groq service when needed
          // final service = GroqAiService(apiKey: _getApiKey());
          // await service.initialize();
          // _services[type] = service;
          break;
        case AiModelType.mistral7bGguf:
          // Import Mistral service when needed
          // final service = MistralLocalService();
          // await service.initialize();
          // _services[type] = service;
          break;
        case AiModelType.nllb200:
          // Import NLLB service when needed
          // final service = NllbLocalService();
          // await service.initialize();
          // _services[type] = service;
          break;
        case AiModelType.whisperTiny:
          // Import Whisper service when needed
          // final service = WhisperLocalService();
          // await service.initialize();
          // _services[type] = service;
          break;
        case AiModelType.ruleBased:
          // Import rule-based service when needed
          // final service = RuleBasedAiService();
          // await service.initialize();
          // _services[type] = service;
          break;
      }
    } catch (e, stackTrace) {
      debugPrint('Failed to initialize AI service $type: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  /// Get the currently active AI service
  BaseAiService? get currentService {
    if (_currentModel == null) return null;
    return _services[_currentModel];
  }

  /// Get the current active model type of the currently active model
  AiModelType? get currentModelType => _currentModel;

  /// Set preferred model (will switch to it if available and appropriate)
  Future<void> setPreferredModel(AiModelType type) async {
    _preferredModel = type;
    await _initializeService(type);
    await _updateActiveModel();
  }

  /// Check if a specific model is available and ready
  Future<bool> isModelAvailable(AiModelType type) async {
    if (!_services.containsKey(type)) {
      await _initializeService(type);
    }
    final service = _services[type];
    return service != null && await service.isReady();
  }

  /// Clean up resources
  Future<void> dispose() async {
    await _connectivitySubscription?.cancel();
    for (final service in _services.values) {
      await service.dispose();
    }
    _services.clear();
  }
}

/// Singleton instance for easy access
final AiServiceManager aiServiceManager = AiServiceManager();