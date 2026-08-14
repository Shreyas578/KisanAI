import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/config/api_config.dart';
import '../providers/registration_state_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../farm_report/state/farm_report_notifier.dart';
/// Step 5: Review & Submit Registration
/// Final review of all entered data with farm report preview while generating
class Step5ReviewSubmitScreen extends ConsumerStatefulWidget {
  final VoidCallback onPrevious;

  const Step5ReviewSubmitScreen({Key? key, required this.onPrevious})
    : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _Step5ReviewSubmitScreenState();
}

class _Step5ReviewSubmitScreenState
    extends ConsumerState<Step5ReviewSubmitScreen> {
  late TextEditingController _passwordController;
  bool _passwordVisible = false;
  bool _isSubmitting = false;
  String? _submissionError;
  Map<String, dynamic>? _registrationSummary;
  bool _summaryLoaded = false;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
    _loadRegistrationSummary();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadRegistrationSummary() async {
    final sessionToken = ref.read(registrationStateProvider).sessionToken;
    if (sessionToken == null) {
      if (mounted) {
        setState(() {
          _summaryLoaded = true;
          _submissionError = 'Session token not found. Please go back and try again.';
        });
      }
      return;
    }

    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/api/auth/register/summary'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'sessionToken': sessionToken}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _registrationSummary = data['summary'];
            _summaryLoaded = true;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _summaryLoaded = true;
          });
        }
      }
    } catch (e) {
      print('Error loading summary: $e');
      setState(() {
        _summaryLoaded = true;
      });
    }
  }

  Future<void> _submitRegistration() async {
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your password to confirm')),
      );
      return;
    }

    final sessionToken = ref.read(registrationStateProvider).sessionToken;
    if (sessionToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session token missing.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submissionError = null;
    });

    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/api/auth/register/complete'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'sessionToken': sessionToken,
              'password': _passwordController.text,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final token = data['token'] as String? ?? '';
        final userId = data['userId'] as String? ?? data['user']?['id'] as String? ?? '';

        // Save token
        ref.read(registrationTokenProvider.notifier).state = token;

        // Persist token to SharedPreferences
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', token);
          if (userId.isNotEmpty) await prefs.setString('user_id', userId);
        } catch (_) {}

        final userRole = data['user']?['role'] as String? ?? 'farmer';

        if (mounted) {
          if (userRole == 'farmer') {
            // Show farm report generation loading dialog
            _showReportGeneratingDialog();

            // Trigger farm report generation and wait for it
            final reportResponse = await _triggerFarmReportGeneration(token, userId);

            if (mounted) {
              Navigator.of(context, rootNavigator: true).pop(); // Close dialog
              if (reportResponse != null && reportResponse.statusCode == 200) {
                final body = jsonDecode(reportResponse.body);
                final reportType = body['report']?['type'] ?? 'unknown';
                final reportData = body['report']?['data'] ?? body['data'];
                ref.read(farmReportNotifierProvider.notifier).setReport(reportType, reportData);
              }
              context.go('/farm-report');
            }
          } else {
            // Navigate directly to respective dashboard without report dialog
            if (userRole == 'buyer') {
              context.go('/farmer/home'); // TODO: Implement buyer dashboard
            } else if (userRole == 'supplier') {
              context.go('/farmer/home'); // TODO: Implement supplier dashboard
            } else {
              context.go('/farmer/home');
            }
          }
        }
      } else {
        final error = jsonDecode(response.body);
        setState(() {
          if (response.statusCode == 409) {
            _submissionError = 'You are already registered! Please go back and log in.';
          } else {
            _submissionError = error['error'] ?? 'Registration failed';
          }
        });
      }
    } catch (e) {
      setState(() {
        _submissionError = 'Network error: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  /// Shows a beautiful loading dialog while the farm report is being generated
  void _showReportGeneratingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          backgroundColor: Colors.green.shade50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              // Animated farm icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.agriculture,
                  size: 44,
                  color: Colors.green.shade700,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '🌾 Generating Your Farm Report',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'AI is analyzing your farm details and creating a personalized plan...',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.green.shade700,
                ),
              ),
              const SizedBox(height: 20),
              LinearProgressIndicator(
                backgroundColor: Colors.green.shade100,
                valueColor: AlwaysStoppedAnimation(Colors.green.shade600),
              ),
              const SizedBox(height: 12),
              Text(
                'This takes about 30 seconds',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<http.Response?> _triggerFarmReportGeneration(String token, String userId) async {
    try {
      return await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/farm-report/generate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'userId': userId}),
      ).timeout(const Duration(seconds: 60));
    } catch (e) {
      // Non-fatal — report will be generated lazily when farmer opens Farm Report tab
      debugPrint('[FarmReport] Background generation failed: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_summaryLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: 1.0,
            minHeight: 8,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation(Colors.green.shade700),
          ),
          const SizedBox(height: 20),

          Text(
            'Step 5 of 5 - Final Review',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 10),

          Text(
            'Review Your Farm Registration',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),

          Text(
            'Once submitted, a personalized farm report will be generated for you.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 30),

          // Personal Details Section
          _buildSectionHeader('Personal Details'),
          _buildSummaryCard(
            icon: Icons.person,
            title: 'Name',
            value: _registrationSummary?['personal']['name'] ?? 'N/A',
          ),
          _buildSummaryCard(
            icon: Icons.phone,
            title: 'Phone',
            value: _registrationSummary?['personal']['phone'] ?? 'N/A',
          ),
          _buildSummaryCard(
            icon: Icons.email,
            title: 'Email',
            value:
                _registrationSummary?['personal']['email'] ??
                'Not provided',
          ),
          _buildSummaryCard(
            icon: Icons.language,
            title: 'Preferred Language',
            value:
                (_registrationSummary?['personal']['language'] ??
                        'English')
                    .toString()
                    .toUpperCase(),
          ),
          const SizedBox(height: 20),

          // Location Section
          if (_registrationSummary?['personal']?['role'] == 'farmer' && _registrationSummary?['location'] != null) ...[
            _buildSectionHeader('Farm Location'),
            _buildSummaryCard(
              icon: Icons.location_on,
              title: 'State',
              value: _registrationSummary?['location']['state'] ?? 'N/A',
            ),
            _buildSummaryCard(
              icon: Icons.location_on_outlined,
              title: 'District',
              value:
                  _registrationSummary?['location']['district'] ?? 'N/A',
            ),
            _buildSummaryCard(
              icon: Icons.home,
              title: 'Village',
              value:
                  _registrationSummary?['location']['village'] ?? 'N/A',
            ),
            _buildSummaryCard(
              icon: Icons.pin_drop,
              title: 'Coordinates',
              value:
                  '${_registrationSummary?['location']['lat']}, ${_registrationSummary?['location']['lng']}',
            ),
            const SizedBox(height: 20),
          ],

          // Land Details Section
          if (_registrationSummary?['personal']?['role'] == 'farmer' && _registrationSummary?['landDetails'] != null) ...[
            _buildSectionHeader('Land Details'),
            _buildSummaryCard(
              icon: Icons.agriculture,
              title: 'Land Size',
              value:
                  '${_registrationSummary?['landDetails']['landAcres']} acres',
            ),
            _buildSummaryCard(
              icon: Icons.terrain,
              title: 'Soil Type',
              value:
                  _registrationSummary?['landDetails']['soilType'] ??
                  'N/A',
            ),
            _buildSummaryCard(
              icon: Icons.water_drop,
              title: 'Water Source',
              value:
                  _registrationSummary?['landDetails']['waterSource'] ??
                  'N/A',
            ),
            _buildSummaryCard(
              icon: Icons.water,
              title: 'Irrigation Type',
              value:
                  _registrationSummary?['landDetails']['irrigationType'] ??
                  'Not specified',
            ),
            const SizedBox(height: 20),
          ],

          // Crop Selection Section
          if (_registrationSummary?['personal']?['role'] == 'farmer' && _registrationSummary?['cropSelection'] != null) ...[
            _buildSectionHeader('Crop Information'),
            if (_registrationSummary?['cropSelection']['isDecided'] ==
                true)
              Column(
                children: [
                  _buildSummaryCard(
                    icon: Icons.grass,
                    title: 'Crop',
                    value:
                        _registrationSummary?['cropSelection']['cropName'] ??
                        'N/A',
                  ),
                  if (_registrationSummary?['cropSelection']['seedVariety'] !=
                      null)
                    _buildSummaryCard(
                      icon: Icons.local_florist,
                      title: 'Seed Variety',
                      value:
                          _registrationSummary?['cropSelection']['seedVariety'],
                    ),
                  if (_registrationSummary?['cropSelection']['sowingDate'] !=
                      null)
                    _buildSummaryCard(
                      icon: Icons.calendar_today,
                      title: 'Sowing Date',
                      value: DateFormat('dd MMM yyyy').format(
                        DateTime.parse(
                          _registrationSummary?['cropSelection']['sowingDate'],
                        ),
                      ),
                    ),
                ],
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: Border.all(color: Colors.blue.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You haven\'t decided on a specific crop yet. We\'ll provide personalized crop recommendations based on your farm details.',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 30),
          ],

          // Information Box
          if (_registrationSummary?['personal']?['role'] == 'farmer')
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                border: Border.all(color: Colors.green.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green.shade700,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'What Happens Next',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildNextStepBullet(
                    'Your farm profile is created with all details',
                  ),
                  _buildNextStepBullet(
                    'A personalized farm report is generated within 30 seconds',
                  ),
                  _buildNextStepBullet(
                    'You get weather updates specific to your location',
                  ),
                  _buildNextStepBullet(
                    'Market prices for your region are tracked',
                  ),
                  _buildNextStepBullet(
                    'Monthly guidance based on your crop and location',
                  ),
                ],
              ),
            ),
          if (_registrationSummary?['personal']?['role'] == 'farmer')
            const SizedBox(height: 30),

          // Password confirmation
          Text(
            'Confirm Password',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _passwordController,
            obscureText: !_passwordVisible,
            decoration: InputDecoration(
              hintText: 'Enter your password to confirm',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _passwordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _passwordVisible = !_passwordVisible;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
          ),
          const SizedBox(height: 15),

          // Error message if any
          if (_submissionError != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border.all(color: Colors.red.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _submissionError!,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.red.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 30),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitRegistration,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Submitting...',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      'Complete Registration',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),

          // Back button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _isSubmitting
                  ? null
                  : () {
                      widget.onPrevious();
                    },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: Colors.green.shade700),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Back',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade900,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.green.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade900,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextStepBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check, color: Colors.green.shade700, size: 20),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.green.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
