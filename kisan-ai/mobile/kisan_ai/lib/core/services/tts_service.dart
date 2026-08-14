import 'package:flutter_tts/flutter_tts.dart';

/// Singleton TTS service wrapping flutter_tts.
/// Supports all 11 Indian languages + English with speed control.
class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;
  bool _initialized = false;

  // Language code → BCP-47 locale mapping for flutter_tts
  static const Map<String, String> _localeMap = {
    'en': 'en-IN',
    'hi': 'hi-IN',
    'mr': 'mr-IN',
    'te': 'te-IN',
    'ta': 'ta-IN',
    'kn': 'kn-IN',
    'bn': 'bn-IN',
    'pa': 'pa-IN',
    'gu': 'gu-IN',
    'ml': 'ml-IN',
    'or': 'or-IN',
  };

  bool get isSpeaking => _isSpeaking;

  Future<void> initialize() async {
    if (_initialized) return;
    await _tts.setLanguage('en-IN');
    await _tts.setSpeechRate(0.5);  // Slightly slower for farmers
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    _tts.setStartHandler(() => _isSpeaking = true);
    _tts.setCompletionHandler(() => _isSpeaking = false);
    _tts.setCancelHandler(() => _isSpeaking = false);
    _tts.setErrorHandler((msg) => _isSpeaking = false);

    _initialized = true;
  }

  /// Speak [text] in [languageCode] at [rate] (0.1–1.0, default 0.5).
  Future<void> speak(String text, {String languageCode = 'en', double rate = 0.5}) async {
    await initialize();
    if (_isSpeaking) await stop();

    final locale = _localeMap[languageCode] ?? 'en-IN';
    await _tts.setLanguage(locale);
    await _tts.setSpeechRate(rate.clamp(0.1, 1.0));
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
    _isSpeaking = false;
  }

  Future<void> pause() async {
    await _tts.pause();
    _isSpeaking = false;
  }

  /// Set speech rate globally (0.1 = very slow, 1.0 = fast)
  Future<void> setRate(double rate) async {
    await _tts.setSpeechRate(rate.clamp(0.1, 1.0));
  }

  void dispose() {
    _tts.stop();
  }
}
