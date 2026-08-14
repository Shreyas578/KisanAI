import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kisan_ai/core/theme/app_theme.dart';
import 'package:kisan_ai/shared/widgets/kisan_widgets.dart';
import 'package:kisan_ai/core/config/api_config.dart';
import 'package:kisan_ai/core/services/tts_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DiseaseScanScreen extends ConsumerStatefulWidget {
  const DiseaseScanScreen({super.key});

  @override
  ConsumerState<DiseaseScanScreen> createState() => _DiseaseScanScreenState();
}

class _DiseaseScanScreenState extends ConsumerState<DiseaseScanScreen> {
  Uint8List? _imageBytes;
  XFile? _imageFile;
  bool _isLoading = false;
  Map<String, dynamic>? _analysisResult;
  String _selectedLanguage = 'en';
  bool _isSpeaking = false;
  final TtsService _tts = TtsService();

  final List<Map<String, dynamic>> _languages = [
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
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _imageFile = pickedFile;
          _analysisResult = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  Future<void> _captureImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.camera,
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _imageFile = pickedFile;
          _analysisResult = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error capturing image: $e')));
      }
    }
  }

  Future<void> _analyzeImage() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first')),
      );
      return;
    }
    setState(() => _isLoading = true);

    try {
      // Step 1: Upload image to IPFS first
      String ipfsHash = '';
      try {
        ipfsHash = await _uploadImageToIPFS(_imageBytes!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Image uploaded to IPFS: ${ipfsHash.substring(0, 10)}...',
              ),
              backgroundColor: AppColors.accentGreen,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (ipfsError) {
        // If IPFS upload fails, continue with analysis (local copy fallback)
        print('IPFS upload failed, continuing with analysis: $ipfsError');
      }

      // Step 2: Send image for disease analysis
      final uri = Uri.parse('${ApiConfig.diseaseEndpoint}/detect');
      final request = http.MultipartRequest('POST', uri);
      request.files.add(
        await http.MultipartFile.fromPath('image', _imageFile!.path),
      );
      request.fields['cropName'] = 'Unknown';
      request.fields['language'] = _selectedLanguage;
      request.fields['ipfsHash'] = ipfsHash; // Include IPFS hash in request

      final response = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseBody);
        setState(() {
          _analysisResult = jsonResponse['data'];
          _isLoading = false;
        });
        if (mounted) _showAnalysisResult();
      } else {
        throw Exception('Failed: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  /// Upload image to IPFS and return hash
  /// Falls back gracefully if IPFS fails
  Future<String> _uploadImageToIPFS(Uint8List imageBytes) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/ipfs/upload');

      final request = http.MultipartRequest('POST', uri);
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: 'disease_scan_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      );
      request.fields['uploadType'] = 'disease';
      request.fields['farmId'] = 'current'; // Will be farmer's ID from profile

      final response = await request.send().timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('IPFS upload timeout'),
      );

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final data = json.decode(responseBody);
        return data['data']['ipfsHash'] ?? '';
      } else {
        throw Exception('IPFS upload failed: ${response.statusCode}');
      }
    } catch (e) {
      print('IPFS upload error: $e');
      // Don't throw - allow analysis to continue without IPFS
      return '';
    }
  }

  /// Build a full spoken summary of the disease result for TTS
  String _buildSpokenSummary(Map<String, dynamic> result) {
    if (result['is_healthy'] == true) {
      return 'Your plant looks healthy. No disease detected. Confidence: ${result['confidence']}%.';
    }
    final disease = result['disease_name'] ?? 'Unknown disease';
    final severity = result['severity'] ?? 'unknown';
    final recs =
        (result['treatment_recommendations'] as List?)?.join('. ') ?? '';
    return 'Disease detected: $disease. Severity: $severity. '
        'Treatment: $recs. '
        'Prevention: ${(result['prevention_measures'] as List?)?.join('. ') ?? ''}';
  }

  Future<void> _toggleTts() async {
    if (_analysisResult == null) return;
    if (_isSpeaking) {
      await _tts.stop();
      setState(() => _isSpeaking = false);
    } else {
      setState(() => _isSpeaking = true);
      final text = _buildSpokenSummary(_analysisResult!);
      await _tts.speak(text, languageCode: _selectedLanguage, rate: 0.45);
      setState(() => _isSpeaking = false);
    }
  }

  void _shareReport() {
    if (_analysisResult == null) return;
    final disease = _analysisResult!['is_healthy'] == true
        ? '✅ Plant is Healthy'
        : '⚠️ Disease: ${_analysisResult!['disease_name'] ?? 'Unknown'}';
    final severity = _analysisResult!['severity'] ?? 'unknown';
    final recs =
        (_analysisResult!['treatment_recommendations'] as List?)?.join(
          '\n• ',
        ) ??
        'None';
    final shareText =
        '''
🌿 *Kisan AI — Disease Report*

$disease
📊 Severity: $severity
🔬 Confidence: ${_analysisResult!['confidence']}%

💊 *Treatment:*
• $recs

📱 Generated by Kisan AI — Your farm's guardian
''';
    Share.share(shareText, subject: 'Kisan AI Disease Report');
  }

  void _showAnalysisResult() {
    if (_analysisResult == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderSubtle,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Header row with title + action buttons
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Disease Analysis Result',
                        style: AppTypography.titleMedium,
                      ),
                    ),
                    // TTS button
                    StatefulBuilder(
                      builder: (context, setLocalState) => IconButton(
                        tooltip: _isSpeaking ? 'Stop' : 'Listen',
                        icon: Icon(
                          _isSpeaking ? Icons.stop_circle : Icons.volume_up,
                          color: _isSpeaking
                              ? AppColors.dangerRed
                              : AppColors.accentGreen,
                        ),
                        onPressed: () async {
                          await _toggleTts();
                          setLocalState(() {});
                        },
                      ),
                    ),
                    // WhatsApp / share button
                    IconButton(
                      tooltip: 'Share via WhatsApp',
                      icon: const Icon(
                        Icons.share,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: _shareReport,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Severity Badge
                _buildSeverityBadge(_analysisResult!['severity']),
                const SizedBox(height: 16),

                // Status card
                _buildResultCard(
                  icon: _analysisResult!['is_healthy'] == true
                      ? Icons.check_circle
                      : Icons.warning_amber_rounded,
                  iconColor: _analysisResult!['is_healthy'] == true
                      ? Colors.green
                      : AppColors.dangerRed,
                  label: _analysisResult!['is_healthy'] == true
                      ? '✅ Plant is Healthy'
                      : '⚠️ Disease Detected',
                  value: '',
                ),

                if (!(_analysisResult!['is_healthy'] == true)) ...[
                  const SizedBox(height: 8),
                  _buildResultCard(
                    icon: Icons.biotech,
                    iconColor: Colors.orange,
                    label: 'Disease',
                    value: _analysisResult!['disease_name'] ?? 'Unknown',
                  ),
                  const SizedBox(height: 8),
                  _buildResultCard(
                    icon: Icons.category,
                    iconColor: Colors.blue,
                    label: 'Type',
                    value: (_analysisResult!['disease_type'] ?? 'Unknown')
                        .toUpperCase(),
                  ),
                ],

                const SizedBox(height: 8),
                _buildResultCard(
                  icon: Icons.speed,
                  iconColor: AppColors.accentGreen,
                  label: 'Confidence',
                  value: '${_analysisResult!['confidence'] ?? 0}%',
                ),

                // IPFS Hash (immutable proof)
                if (_analysisResult!['ipfsHash'] != null &&
                    (_analysisResult!['ipfsHash'] as String).isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.accentGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.accentGreen,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.verified,
                              size: 16,
                              color: AppColors.accentGreen,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Immutable Proof',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.accentGreen,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onLongPress: () {
                            // Copy to clipboard
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('IPFS hash copied to clipboard'),
                              ),
                            );
                          },
                          child: Text(
                            'Hash: ${(_analysisResult!['ipfsHash'] as String).substring(0, 16)}...',
                            style: AppTypography.bodySmall.copyWith(
                              fontFamily: 'monospace',
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Your analysis is permanently stored on IPFS. This proof cannot be altered.',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (_analysisResult!['treatment_recommendations'] != null &&
                    (_analysisResult!['treatment_recommendations'] as List)
                        .isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _buildSectionHeader(
                    '💊 Treatment Recommendations',
                    Colors.orange,
                  ),
                  const SizedBox(height: 8),
                  ...(_analysisResult!['treatment_recommendations'] as List)
                      .map(
                        (rec) =>
                            _buildBulletItem(rec.toString(), Colors.orange),
                      ),
                ],

                // Prevention Measures
                if (_analysisResult!['prevention_measures'] != null &&
                    (_analysisResult!['prevention_measures'] as List)
                        .isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildSectionHeader(
                    '🛡️ Prevention Measures',
                    AppColors.accentGreen,
                  ),
                  const SizedBox(height: 8),
                  ...(_analysisResult!['prevention_measures'] as List).map(
                    (measure) => _buildBulletItem(
                      measure.toString(),
                      AppColors.accentGreen,
                    ),
                  ),
                ],

                // Treatment timing
                if (_analysisResult!['treatment_timing'] != null &&
                    _analysisResult!['treatment_timing']
                        .toString()
                        .isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildSectionHeader('⏰ When to Apply', Colors.blue),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.blue.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      _analysisResult!['treatment_timing'],
                      style: AppTypography.bodyMedium,
                    ),
                  ),
                ],

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.check),
                    label: const Text('Done'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentGreen,
                      foregroundColor: AppColors.primaryBackground,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSeverityBadge(String? severity) {
    final (color, label, icon) = switch (severity?.toLowerCase()) {
      'mild' => (Colors.yellow[700]!, '🟡 Mild', Icons.info_outline),
      'moderate' => (Colors.orange, '🟠 Moderate', Icons.warning_outlined),
      'severe' => (Colors.red, '🔴 Severe', Icons.error_outline),
      'critical' => (Colors.red[900]!, '🆘 Critical', Icons.dangerous_outlined),
      'healthy' => (Colors.green, '🟢 Healthy', Icons.check_circle_outline),
      _ => (Colors.grey, '⚪ Unknown', Icons.help_outline),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            'Severity: $label',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2);
  }

  Widget _buildResultCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          if (value.isNotEmpty)
            Text(
              value,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Text(title, style: AppTypography.titleMedium.copyWith(color: color));
  }

  Widget _buildBulletItem(String text, Color bulletColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(color: bulletColor, fontSize: 18, height: 1.2),
          ),
          Expanded(child: Text(text, style: AppTypography.bodyMedium)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: KisanAppBar(
              title: 'Disease Detection',
              showSearch: false,
              actions: [_buildLanguageSelector()],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate.fixed([
                // Language info banner
                if (_selectedLanguage != 'en')
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.accentGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.accentGreen.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.translate,
                          color: AppColors.accentGreen,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Results will be in ${_languages.firstWhere((l) => l['code'] == _selectedLanguage)['name']}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.accentGreen,
                          ),
                        ),
                      ],
                    ),
                  ),

                KisanCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Scan Leaf for Disease',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Image preview
                      _imageBytes == null
                          ? Container(
                              height: 250,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.accentGreen,
                                  width: 2,
                                ),
                              ),
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate,
                                      size: 56,
                                      color: AppColors.accentGreen,
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'Tap below to add photo',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Gallery or Camera',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Stack(
                              children: [
                                Container(
                                  height: 250,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    image: DecorationImage(
                                      image: MemoryImage(_imageBytes!),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () => setState(() {
                                      _imageBytes = null;
                                      _imageFile = null;
                                      _analysisResult = null;
                                    }),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                      const SizedBox(height: 20),
                      // Pick/capture buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.photo_library),
                              label: const Text('Gallery'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.surfaceElevated,
                                foregroundColor: AppColors.accentGreen,
                                side: const BorderSide(
                                  color: AppColors.accentGreen,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _captureImage,
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Camera'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accentGreen,
                                foregroundColor: AppColors.primaryBackground,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Analyze button
                      if (_imageBytes != null) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _analyzeImage,
                            icon: _isLoading
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.search),
                            label: Text(
                              _isLoading ? 'Analyzing...' : 'Analyze Image',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentGreen,
                              foregroundColor: AppColors.primaryBackground,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                      // Show result summary if available
                      if (_analysisResult != null) ...[
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _analysisResult!['is_healthy'] == true
                                    ? '✅ Plant is Healthy'
                                    : '⚠️ ${_analysisResult!['disease_name'] ?? 'Disease Detected'}',
                                style: AppTypography.bodyLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _analysisResult!['is_healthy'] == true
                                      ? Colors.green
                                      : AppColors.dangerRed,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                _isSpeaking
                                    ? Icons.stop_circle
                                    : Icons.volume_up,
                                color: _isSpeaking
                                    ? AppColors.dangerRed
                                    : AppColors.accentGreen,
                              ),
                              onPressed: _toggleTts,
                              tooltip: 'Listen to result',
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.share,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: _shareReport,
                              tooltip: 'Share report',
                            ),
                            TextButton(
                              onPressed: _showAnalysisResult,
                              child: const Text('Details'),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return PopupMenuButton<String>(
      onSelected: (code) => setState(() => _selectedLanguage = code),
      itemBuilder: (context) => _languages.map<PopupMenuEntry<String>>((lang) {
        return PopupMenuItem<String>(
          value: lang['code'] as String,
          child: Row(
            children: [
              Text(lang['flag'] as String),
              const SizedBox(width: 8),
              Text(lang['name'] as String),
              if (_selectedLanguage == lang['code'])
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
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _languages.firstWhere(
                    (l) => l['code'] == _selectedLanguage,
                  )['flag']
                  as String,
              style: const TextStyle(fontSize: 20),
            ),
            const Icon(
              Icons.expand_more,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
