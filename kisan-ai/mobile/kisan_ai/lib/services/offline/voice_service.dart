import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

/// Service for voice input and output
class VoiceService {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _isListening = false;
  bool _isInitialized = false;

  /// Initialize voice services
  Future<void> initialize() async {
    try {
      final available = await _speechToText.initialize(
        onError: (error) => print('❌ Speech error: $error'),
        onStatus: (status) => print('📢 Speech status: $status'),
      );

      if (!available) {
        print('⚠️ Speech recognition not available on this device');
      }

      await _tts.setLanguage('en-IN');
      _isInitialized = true;
      print('✅ Voice service initialized');
    } catch (e) {
      print('❌ Voice init error: $e');
    }
  }

  /// Start listening for speech
  void startListening({
    required Function(String) onResult,
    required Function(String) onError,
  }) {
    if (!_isInitialized || !_speechToText.isNotListening) {
      onError('Speech recognition not ready');
      return;
    }

    _isListening = true;
    _speechToText.listen(
      onResult: (result) {
        onResult(result.recognizedWords);
        if (result.finalResult) {
          _isListening = false;
        }
      },
      onError: (error) {
        onError(error.errorMsg);
        _isListening = false;
      },
    );
  }

  /// Stop listening
  Future<void> stopListening() async {
    await _speechToText.stop();
    _isListening = false;
  }

  /// Text to speech
  Future<void> speak(String text) async {
    try {
      await _tts.speak(text);
    } catch (e) {
      print('❌ TTS error: $e');
    }
  }

  /// Stop speaking
  Future<void> stopSpeaking() async {
    await _tts.stop();
  }

  bool get isListening => _isListening;
  bool get isInitialized => _isInitialized;
}
