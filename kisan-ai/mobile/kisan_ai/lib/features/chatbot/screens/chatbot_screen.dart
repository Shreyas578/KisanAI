import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan_ai/core/theme/app_theme.dart';
import 'package:kisan_ai/core/theme/app_colors.dart';
import 'package:kisan_ai/features/chatbot/state/chatbot_provider.dart';
import 'package:kisan_ai/features/chatbot/state/chat_message_notifier.dart';
import 'package:kisan_ai/shared/models/chat_model.dart';
import 'package:kisan_ai/shared/widgets/offline_banner.dart';
import 'package:kisan_ai/core/services/tts_service.dart';
import 'package:kisan_ai/core/services/stt_service.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ChatbotScreen extends ConsumerStatefulWidget {
  const ChatbotScreen({super.key});

  @override
  ConsumerState<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends ConsumerState<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final TtsService _tts = TtsService();
  final SttService _stt = SttService();

  final List<Map<String, dynamic>> _supportedLanguages = [
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
    {'code': 'hi', 'name': 'हिन्दी', 'flag': '🇮🇳'},
    {'code': 'mr', 'name': 'मराठी', 'flag': '🇮🇳'},
    {'code': 'ta', 'name': 'தமிழ்', 'flag': '🇮🇳'},
    {'code': 'te', 'name': 'తెలుగు', 'flag': '🇮🇳'},
    {'code': 'kn', 'name': 'ಕನ್ನಡ', 'flag': '🇮🇳'},
    {'code': 'bn', 'name': 'বাংলা', 'flag': '🇮🇳'},
    {'code': 'gu', 'name': 'ગુજરાતી', 'flag': '🇮🇳'},
    {'code': 'pa', 'name': 'ਪੰਜਾਬੀ', 'flag': '🇮🇳'},
    {'code': 'ml', 'name': 'മലയാളം', 'flag': '🇮🇳'},
  ];

  @override
  void initState() {
    super.initState();
    _initVoice();
  }

  Future<void> _initVoice() async {
    await _stt.initialize();
    await _tts.initialize();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _tts.stop();
    _stt.cancelListening();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage([String? overrideText]) async {
    final text = (overrideText ?? _messageController.text).trim();
    if (text.isEmpty) return;

    _messageController.clear();

    final messageNotifier = ref.read(chatMessageNotifierProvider.notifier);
    ref.read(chatLoadingProvider.notifier).state = true;

    try {
      // Add user message to state
      messageNotifier.addUserMessage(text);
      _scrollToBottom();

      // Get chatbot service and send message
      final chatbotService = await ref.read(chatbotServiceProvider.future);
      final userMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        conversationId: 'default_conversation',
        senderId: 'user',
        senderName: 'You',
        isFromBot: false,
        messageType: 'text',
        content: text,
        timestamp: DateTime.now(),
        isRead: true,
      );

      final language = ref.read(selectedLanguageProvider);
      final response = await chatbotService
          .sendMessage(userMessage, language: language)
          .timeout(const Duration(seconds: 30));

      // Add bot response to state
      messageNotifier.addBotMessage(response.content);
      _scrollToBottom();

      // Auto-read response if enabled
      final autoRead = ref.read(autoReadBotRepliesProvider);
      if (autoRead) {
        final language = ref.read(selectedLanguageProvider);
        await _tts.speak(response.content, languageCode: language, rate: 0.5);
      }

      ref.read(chatLoadingProvider.notifier).state = false;
    } catch (e) {
      ref.read(chatLoadingProvider.notifier).state = false;
      final messageNotifier = ref.read(chatMessageNotifierProvider.notifier);
      messageNotifier.addBotMessage(
        '⚠️ Error: Unable to get response.\n${e.toString()}',
      );
      _scrollToBottom();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.dangerRed,
          ),
        );
      }
    }
  }

  Future<void> _toggleMic() async {
    final isListening = ref.read(isListeningProvider);

    if (isListening) {
      await _stt.stopListening();
      ref.read(isListeningProvider.notifier).state = false;
      ref.read(liveTranscriptProvider.notifier).state = '';

      if (_messageController.text.trim().isNotEmpty) {
        _sendMessage(_messageController.text.trim());
      }
      return;
    }

    if (!_stt.isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Speech recognition not available on this device'),
        ),
      );
      return;
    }

    ref.read(isListeningProvider.notifier).state = true;
    ref.read(liveTranscriptProvider.notifier).state = '';
    await _tts.stop();

    final language = ref.read(selectedLanguageProvider);
    await _stt.startListening(
      languageCode: language,
      onResult: (text) {
        ref.read(liveTranscriptProvider.notifier).state = text;
        _messageController.text = text;
        _messageController.selection = TextSelection.fromPosition(
          TextPosition(offset: text.length),
        );
      },
      onFinal: (text) {
        ref.read(isListeningProvider.notifier).state = false;
        ref.read(liveTranscriptProvider.notifier).state = '';
        if (text.trim().isNotEmpty) {
          _sendMessage(text);
        }
      },
    );
  }

  void _speakMessage(String text) async {
    final isSpeaking = ref.read(isSpeakingProvider);
    if (isSpeaking) {
      await _tts.stop();
      ref.read(isSpeakingProvider.notifier).state = false;
    } else {
      ref.read(isSpeakingProvider.notifier).state = true;
      final language = ref.read(selectedLanguageProvider);
      await _tts.speak(text, languageCode: language);
      ref.read(isSpeakingProvider.notifier).state = false;
    }
  }

  void _changeLanguage(String languageCode) {
    ref.read(selectedLanguageProvider.notifier).state = languageCode;
    final lang = _supportedLanguages.firstWhere(
      (l) => l['code'] == languageCode,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Language: ${lang['name']}'),
        backgroundColor: AppColors.accentGreen,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessageNotifierProvider);
    final isLoading = ref.watch(chatLoadingProvider);
    final selectedLanguage = ref.watch(selectedLanguageProvider);
    final isSpeaking = ref.watch(isSpeakingProvider);
    final isListening = ref.watch(isListeningProvider);
    final liveTranscript = ref.watch(liveTranscriptProvider);
    final autoReadBotReplies = ref.watch(autoReadBotRepliesProvider);

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            const OfflineBanner(),
            const SizedBox(height: 8),
            Expanded(
              child: Column(
                children: [
                  _buildChatHeader(
                    selectedLanguage,
                    autoReadBotReplies,
                    () => ref.read(autoReadBotRepliesProvider.notifier).state =
                        !autoReadBotReplies,
                  ),
                  // Live transcript indicator
                  if (isListening) _buildLiveTranscriptBanner(liveTranscript),
                  Expanded(
                    child: messages.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            itemCount: messages.length + (isLoading ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == messages.length) {
                                return _buildTypingIndicator();
                              }
                              return _buildMessageBubble(messages[index]);
                            },
                          ),
                  ),
                  _buildInputArea(isLoading, isListening),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveTranscriptBanner(String liveTranscript) {
    return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.dangerRed.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.dangerRed.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.mic, color: AppColors.dangerRed, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  liveTranscript.isEmpty ? 'Listening...' : liveTranscript,
                  style: AppTypography.bodySmall.copyWith(
                    color: liveTranscript.isEmpty
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                    fontStyle: liveTranscript.isEmpty
                        ? FontStyle.italic
                        : FontStyle.normal,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
          duration: 1500.ms,
          color: AppColors.dangerRed.withValues(alpha: 0.3),
        );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.smart_toy, size: 64, color: AppColors.accentGreen),
          const SizedBox(height: 16),
          Text('Ask Kisan AI anything!', style: AppTypography.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Tap 🎤 to speak or type your question',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildSuggestionChip('🌱 Best crop for my land'),
              _buildSuggestionChip('💧 Irrigation advice'),
              _buildSuggestionChip('🐛 Pest control tips'),
              _buildSuggestionChip('💰 Market prices today'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return GestureDetector(
      onTap: () => _sendMessage(text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Text(text, style: AppTypography.bodySmall),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.accentGreen,
            child: Icon(
              Icons.smart_toy,
              color: AppColors.primaryBackground,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(200),
                const SizedBox(width: 4),
                _buildDot(400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int delayMs) {
    return Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.textSecondary,
            shape: BoxShape.circle,
          ),
        )
        .animate(
          delay: Duration(milliseconds: delayMs),
          onPlay: (c) => c.repeat(),
        )
        .scaleXY(begin: 0.5, end: 1.0, duration: 400.ms)
        .then()
        .scaleXY(begin: 1.0, end: 0.5, duration: 400.ms);
  }

  Widget _buildChatHeader(
    String language,
    bool autoRead,
    VoidCallback onToggle,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.accentGreen,
            child: Icon(
              Icons.smart_toy,
              color: AppColors.primaryBackground,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kisan AI Assistant', style: AppTypography.titleMedium),
                Text(
                  'Online • Ask in any language',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Tooltip(
            message: autoRead ? 'Auto-read ON' : 'Auto-read OFF',
            child: IconButton(
              icon: Icon(
                autoRead ? Icons.volume_up : Icons.volume_off,
                color: autoRead
                    ? AppColors.accentGreen
                    : AppColors.textSecondary,
              ),
              onPressed: onToggle,
            ),
          ),
          PopupMenuButton<String>(
            onSelected: _changeLanguage,
            itemBuilder: (context) =>
                _supportedLanguages.map<PopupMenuEntry<String>>((lang) {
                  return PopupMenuItem<String>(
                    value: lang['code'] as String,
                    child: Row(
                      children: [
                        Text(lang['flag'] as String),
                        const SizedBox(width: 8),
                        Text(lang['name'] as String),
                        if (language == lang['code'])
                          const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Icon(
                              Icons.check,
                              size: 16,
                              color: AppColors.accentGreen,
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _supportedLanguages.firstWhere(
                          (l) => l['code'] == language,
                        )['flag']
                        as String,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _supportedLanguages.firstWhere(
                          (l) => l['code'] == language,
                        )['name']
                        as String,
                    style: AppTypography.bodySmall,
                  ),
                  const Icon(
                    Icons.expand_more,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(bool isLoading, bool isListening) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isListening
                  ? AppColors.dangerRed
                  : AppColors.surfaceElevated,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                isListening ? Icons.mic : Icons.mic_none,
                color: isListening ? Colors.white : AppColors.textSecondary,
              ),
              onPressed: isLoading ? null : _toggleMic,
              tooltip: isListening ? 'Stop recording' : 'Speak',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isListening
                      ? AppColors.dangerRed
                      : AppColors.borderSubtle,
                ),
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: isListening ? 'Listening...' : 'Type a message...',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
                maxLines: null,
                onSubmitted: isLoading ? null : (_) => _sendMessage(),
                enabled: !isLoading,
              ),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: const BoxDecoration(
              color: AppColors.accentGreen,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white),
              onPressed: isLoading ? null : () => _sendMessage(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final bool isUser = !message.isFromBot;
    final DateTime timestamp = message.timestamp.toLocal();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser)
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.accentGreen,
              child: Icon(
                Icons.smart_toy,
                color: AppColors.primaryBackground,
                size: 18,
              ),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: GestureDetector(
              onLongPress: isUser ? null : () => _speakMessage(message.content),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.72,
                ),
                decoration: BoxDecoration(
                  color: isUser ? AppColors.accentGreen : AppColors.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: isUser
                        ? const Radius.circular(16)
                        : Radius.zero,
                    bottomRight: !isUser
                        ? const Radius.circular(16)
                        : Radius.zero,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.content,
                        style: TextStyle(
                          color: isUser
                              ? AppColors.primaryBackground
                              : AppColors.textPrimary,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 10,
                              color: isUser
                                  ? AppColors.primaryBackground.withValues(
                                      alpha: 0.7,
                                    )
                                  : AppColors.textSecondary,
                            ),
                          ),
                          if (!isUser) ...[
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => _speakMessage(message.content),
                              child: Icon(
                                Icons.volume_up,
                                size: 12,
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (isUser)
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.surface,
              child: Icon(Icons.person, color: AppColors.textPrimary, size: 18),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.1);
  }
}
