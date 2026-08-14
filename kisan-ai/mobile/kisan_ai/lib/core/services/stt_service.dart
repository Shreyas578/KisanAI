import 'package:speech_to_text/speech_to_text.dart';

/// Singleton STT service wrapping speech_to_text.
/// Supports multilingual input with live transcript callbacks.
class SttService {
  static final SttService _instance = SttService._internal();
  factory SttService() => _instance;
  SttService._internal();

  final SpeechToText _stt = SpeechToText();
  bool _isListening = false;
  bool _isAvailable = false;

  // Language code → speech_to_text locale ID mapping
  static const Map<String, String> _localeMap = {
    'en': 'en_IN',
    'hi': 'hi_IN',
    'mr': 'mr_IN',
    'te': 'te_IN',
    'ta': 'ta_IN',
    'kn': 'kn_IN',
    'bn': 'bn_IN',
    'pa': 'pa_IN',
    'gu': 'gu_IN',
    'ml': 'ml_IN',
    'or': 'or_IN',
  };

  bool get isListening => _isListening;
  bool get isAvailable => _isAvailable;

  /// Initialize and request microphone permission.
  /// Returns true if speech recognition is available on this device.
  Future<bool> initialize() async {
    _isAvailable = await _stt.initialize(
      onError: (error) {
        _isListening = false;
        print('[STT] Error: $error');
      },
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          _isListening = false;
        }
      },
    );
    return _isAvailable;
  }

  /// Start listening in [languageCode].
  /// [onResult] is called with partial transcript as the user speaks.
  /// [onFinal] is called with the final confirmed transcript.
  Future<void> startListening({
    String languageCode = 'en',
    required Function(String) onResult,
    Function(String)? onFinal,
    Duration listenFor = const Duration(seconds: 30),
  }) async {
    if (!_isAvailable) {
      final ok = await initialize();
      if (!ok) return;
    }
    if (_isListening) return;

    final locale = _localeMap[languageCode] ?? 'en_IN';
    _isListening = true;

    await _stt.listen(
      localeId: locale,
      listenFor: listenFor,
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      onResult: (result) {
        onResult(result.recognizedWords);
        if (result.finalResult && onFinal != null) {
          onFinal(result.recognizedWords);
          _isListening = false;
        }
      },
    );
  }

  Future<void> stopListening() async {
    await _stt.stop();
    _isListening = false;
  }

  Future<void> cancelListening() async {
    await _stt.cancel();
    _isListening = false;
  }
}
