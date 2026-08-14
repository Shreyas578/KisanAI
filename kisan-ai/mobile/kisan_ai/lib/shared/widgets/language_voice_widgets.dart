import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/language_provider.dart';

class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLanguage = ref.watch(languageProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2420),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A3830)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentLanguage,
          icon: const Icon(Icons.language, color: Color(0xFF8BA898)),
          iconSize: 20,
          elevation: 16,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          underline: Container(height: 2, color: const Color(0xFF00E676)),
          onChanged: (String? newValue) {
            if (newValue != null && newValue != currentLanguage) {
              // Change language and save preference
              ref.read(languageProvider.notifier).changeLanguage(newValue);

              // Show confirmation
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Language changed to ${getLanguageName(newValue)}',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          items: supportedLanguages.entries.map<DropdownMenuItem<String>>((
            entry,
          ) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text(
                entry.value,
                style: const TextStyle(color: Colors.white),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class VoiceButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isListening;

  const VoiceButton({
    super.key,
    required this.onPressed,
    this.isListening = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isListening ? const Color(0xFFFF5252) : const Color(0xFF1A2420),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(
          isListening ? Icons.mic : Icons.mic_none,
          color: isListening ? Colors.white : const Color(0xFF8BA898),
          size: 24,
        ),
        onPressed: onPressed,
      ),
    );
  }
}

class TtsButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isSpeaking;

  const TtsButton({
    super.key,
    required this.onPressed,
    this.isSpeaking = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isSpeaking ? const Color(0xFF00E676) : const Color(0xFF1A2420),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(
          isSpeaking ? Icons.volume_up : Icons.volume_off,
          color: isSpeaking ? const Color(0xFF0A0F0D) : const Color(0xFF8BA898),
          size: 24,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
