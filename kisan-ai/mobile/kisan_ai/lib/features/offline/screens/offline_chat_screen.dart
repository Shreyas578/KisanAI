import 'package:flutter/material.dart';
import 'package:kisan_ai/services/offline/offline_chat_service.dart';
import 'package:kisan_ai/services/offline/voice_service.dart';

/// Screen for offline chat with Mistral 7B
class OfflineChatScreen extends StatefulWidget {
  const OfflineChatScreen({super.key});

  @override
  State<OfflineChatScreen> createState() => _OfflineChatScreenState();
}

class _OfflineChatScreenState extends State<OfflineChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final OfflineChatService _chatService = OfflineChatService();
  final VoiceService _voiceService = VoiceService();

  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _ollamaAvailable = false;
  bool _voiceEnabled = false;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _checkOllamaAvailability();
    _initializeVoiceService();
  }

  Future<void> _initializeVoiceService() async {
    try {
      await _voiceService.initialize();
      setState(() => _voiceEnabled = true);
      print('✅ Voice service initialized');
    } catch (e) {
      print('⚠️ Voice init error: $e');
      _addSystemMessage('ℹ️ Voice features not available: $e');
    }
  }

  Future<void> _checkOllamaAvailability() async {
    final available = await _chatService.isOllamaAvailable();
    setState(() => _ollamaAvailable = available);

    if (!available) {
      _addSystemMessage(
        '⚠️ Ollama not detected. Start Ollama with: ollama run mistral',
      );
    }
  }

  void _addSystemMessage(String message) {
    _messages.add(ChatMessage(text: message, isUser: false, isSystem: true));
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();

    // Add user message
    setState(() {
      _messages.add(ChatMessage(text: message, isUser: true));
      _isLoading = true;
    });

    _scrollToBottom();

    if (!_ollamaAvailable) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: 'Ollama not running. Please install and start Ollama.',
            isUser: false,
          ),
        );
        _isLoading = false;
      });
      return;
    }

    try {
      String responseText = '';

      await _chatService
          .sendMessage(
            message,
            farmerName: 'Farmer',
            crop: 'Wheat',
            language: 'en',
          )
          .forEach((chunk) {
            responseText += chunk;
            setState(() {
              if (_messages.isNotEmpty && !_messages.last.isUser) {
                _messages.last.text = responseText;
              } else {
                _messages.add(ChatMessage(text: responseText, isUser: false));
              }
            });
            _scrollToBottom();
          });

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(text: 'Error: $e', isUser: false, isError: true),
        );
        _isLoading = false;
      });
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  /// Start voice listening
  void _startVoiceInput() async {
    if (!_voiceEnabled) {
      _addSystemMessage('❌ Voice not available on this device');
      return;
    }

    setState(() => _isListening = true);

    _voiceService.startListening(
      onResult: (text) {
        setState(() {
          _messageController.text = text;
          if (text.isNotEmpty && text.endsWith('.')) {
            // Auto-send if sentence ends with period
            _isListening = false;
            _sendMessage();
          }
        });
      },
      onError: (error) {
        setState(() => _isListening = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Voice error: $error')));
        print('❌ Voice input error: $error');
      },
    );

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎤 Listening... Speak now'),
        duration: Duration(seconds: 30),
      ),
    );
  }

  /// Stop voice listening
  Future<void> _stopVoiceInput() async {
    await _voiceService.stopListening();
    setState(() => _isListening = false);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _voiceService.stopSpeaking();
    _voiceService.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🤖 Offline Chat'), centerTitle: true),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),

          // Voice indicator
          if (_isListening)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.blue.shade50,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mic, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Text('🎤 Listening...', style: TextStyle(color: Colors.blue)),
                ],
              ),
            ),

          // Input area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                // Voice button
                if (_voiceEnabled)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FloatingActionButton(
                      heroTag: 'voice-button',
                      mini: true,
                      onPressed: _isListening
                          ? _stopVoiceInput
                          : _startVoiceInput,
                      backgroundColor: _isListening ? Colors.red : Colors.blue,
                      child: Icon(_isListening ? Icons.mic_off : Icons.mic),
                    ),
                  ),

                // Text input
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ask about farming...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    enabled: _ollamaAvailable && !_isLoading && !_isListening,
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 8),

                // Send button
                FloatingActionButton(
                  heroTag: 'send-button',
                  onPressed: _ollamaAvailable && !_isLoading
                      ? _sendMessage
                      : null,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Align(
        alignment: message.isUser
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: message.isError
                ? Colors.red.shade100
                : message.isSystem
                ? Colors.grey.shade200
                : message.isUser
                ? Colors.blue.shade500
                : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message.text,
            style: TextStyle(
              color: message.isUser ? Colors.white : Colors.black87,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class ChatMessage {
  String text;
  final bool isUser;
  final bool isSystem;
  final bool isError;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.isSystem = false,
    this.isError = false,
  });
}
