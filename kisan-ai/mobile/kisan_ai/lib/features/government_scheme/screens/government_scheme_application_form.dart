import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan_ai/features/government_scheme/state/government_scheme_provider.dart';
import 'package:kisan_ai/features/government_scheme/services/government_scheme_service.dart';
import 'package:kisan_ai/core/router/app_router.dart';
import 'package:kisan_ai/core/theme/app_theme.dart';
import 'package:kisan_ai/shared/widgets/kisan_widgets.dart';
import 'package:kisan_ai/shared/models/government_scheme_model.dart';

class GovernmentSchemeApplicationForm extends ConsumerStatefulWidget {
  final String schemeId;

  const GovernmentSchemeApplicationForm({
    Key? key,
    required this.schemeId,
  }) : super(key: key);

  @override
  ConsumerState<GovernmentSchemeApplicationForm> createState() => _GovernmentSchemeApplicationFormState();
}

class _GovernmentSchemeApplicationFormState
    extends ConsumerState<GovernmentSchemeApplicationForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSubmitting = false;

  // Form fields
  String _fullName = '';
  String _mobileNumber = '';
  String _email = '';
  String _address = '';
  String _dateOfBirth = '';
  String _gender = '';
  String _category = '';
  String _education = '';
  String _occupation = '';
  String _annualIncome = '';
  String _bankAccountNumber = '';
  String _bankIFSC = '';
  String _landArea = '';
  String _irrigationType = '';
  String _primaryCrop = '';
  String _experienceInFarming = '';

  // Document files
  final List<String> _documentTypes = [
    'Identity Proof (Aadhaar/PAN/Voter ID)',
    'Address Proof',
    'Land Ownership Documents',
    'Bank Passbook Copy',
    'Income Certificate',
    'Caste Certificate (if applicable)',
    'Passport Size Photograph',
  ];
  final List<bool> _documentUploaded = List.generate(7, (_) => false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: KisanAppBar(
                title: 'Apply for Scheme',
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accentGreen,
                        ),
                      )
                    : Form(
                        key: _formKey,
                        child: ListView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            // Scheme Info
                            _buildSchemeInfoSection(),
                            const SizedBox(height: 24),
                            // Personal Information
                            _buildSectionHeader('Personal Information'),
                            _buildTextFormField(
                              label: 'Full Name *',
                              hint: 'Enter your full name',
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'Please enter your name'
                                      : null,
                              onSaved: (value) => _fullName = value!,
                            ),
                            const SizedBox(height: 16),
                            _buildTextFormField(
                              label: 'Mobile Number *',
                              hint: 'Enter your mobile number',
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your mobile number';
                                }
                                if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                                  return 'Please enter a valid 10-digit mobile number';
                                }
                                return null;
                              },
                              onSaved: (value) => _mobileNumber = value!,
                            ),
                            const SizedBox(height: 16),
                            _buildTextFormField(
                              label: "Email Address *",
                              hint: "Enter your email address",
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return null; // Optional field
                                }
                                if (!RegExp(
                                        r"^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$")
                                    .hasMatch(value)) {
                                  return "Please enter a valid email address";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildTextFormField(
                              label: 'Date of Birth *',
                              hint: 'DD/MM/YYYY',
                              keyboardType: TextInputType.datetime,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your date of birth';
                                }
                                // Simple validation - in reality you'd use a date picker
                                if (!RegExp(
                                        r'^\d{2}/\d{2}/\d{4}$')
                                    .hasMatch(value)) {
                                  return 'Please enter date in DD/MM/YYYY format';
                                }
                                return null;
                              },
                              onSaved: (value) => _dateOfBirth = value!,
                            ),
                            const SizedBox(height: 16),
                            _buildDropdownFormField(
                              label: 'Gender *',
                              value: _gender,
                              items: ['Male', 'Female', 'Other'],
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'Please select your gender'
                                      : null,
                              onSaved: (value) => _gender = value!,
                            ),
                            const SizedBox(height: 16),
                            // Farm Information
                            _buildSectionHeader('Farm Information'),
                            _buildTextFormField(
                              label: 'Land Area (in acres) *',
                              hint: 'Enter your land area',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your land area';
                                }
                                if (double.tryParse(value) == null ||
                                    double.parse(value) <= 0) {
                                  return 'Please enter a valid area';
                                }
                                return null;
                              },
                              onSaved: (value) => _landArea = value!,
                            ),
                            const SizedBox(height: 16),
                            _buildTextFormField(
                              label: 'Primary Crop *',
                              hint: 'Enter your main crop',
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'Please enter your primary crop'
                                      : null,
                              onSaved: (value) => _primaryCrop = value!,
                            ),
                            const SizedBox(height: 16),
                            _buildDropdownFormField(
                              label: 'Irrigation Type',
                              value: _irrigationType,
                              items: [
                                'Rainfed',
                                'Irrigated',
                                'Canal',
                                'Tube Well',
                                'Drip',
                                'Sprinkler'
                              ],
                              onSaved: (value) => _irrigationType = value ?? '',
                            ),
                            const SizedBox(height: 16),
                            _buildTextFormField(
                              label: 'Experience in Farming (years)',
                              hint: 'Enter your farming experience',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return null; // Optional
                                }
                                if (int.tryParse(value) == null ||
                                    int.parse(value) < 0) {
                                  return 'Please enter valid years';
                                }
                                return null;
                              },
                              onSaved: (value) => _experienceInFarming = value ?? '',
                            ),
                            const SizedBox(height: 16),
                            // Financial Information
                            _buildSectionHeader('Financial Information'),
                            _buildTextFormField(
                              label: 'Annual Income (₹) *',
                              hint: 'Enter your annual income',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your annual income';
                                }
                                if (int.tryParse(value) == null ||
                                    int.parse(value) < 0) {
                                  return 'Please enter valid income';
                                }
                                return null;
                              },
                              onSaved: (value) => _annualIncome = value!,
                            ),
                            const SizedBox(height: 16),
                            _buildTextFormField(
                              label: 'Bank Account Number *',
                              hint: 'Enter your bank account number',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your bank account number';
                                }
                                if (!RegExp(r'^\d{9,18}$')
                                    .hasMatch(value)) {
                                  return 'Please enter a valid account number';
                                }
                                return null;
                              },
                              onSaved: (value) => _bankAccountNumber = value!,
                            ),
                            const SizedBox(height: 16),
                            _buildTextFormField(
                              label: 'Bank IFSC Code *',
                              hint: 'Enter your bank IFSC code',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your bank IFSC code';
                                }
                                if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$')
                                    .hasMatch(value)) {
                                  return 'Please enter a valid IFSC code';
                                }
                                return null;
                              },
                              onSaved: (value) => _bankIFSC = value!,
                            ),
                            const SizedBox(height: 16),
                            // Documents Section
                            _buildSectionHeader('Document Upload'),
                            _buildDocumentsSection(),
                            const SizedBox(height: 24),
                            // Submit Button
                            Center(
                              child: _isSubmitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primaryBackground,
                                      ),
                                    )
                                  : KisanButton(
                                      text: 'Submit Application',
                                      isPrimary: true,
                                      onPressed: _isLoading
                                          ? null
                                          : _submitApplication,
                                    ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            const SliverFillRemaining(
              hasScrollBody: false,
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchemeInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Scheme Information',
            style: AppTypography.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'You are applying for a government scheme. Please fill in all the required details accurately.',
            style: AppTypography.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: AppTypography.titleMedium,
      ),
    );
  }

  Widget _buildTextFormField({
    required String label,
    required String hint,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelMedium,
        ),
        const SizedBox(height: 8),
        TextFormField(
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.inputBorderUnfocused,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.inputBorderUnfocused,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.inputBorderFocused,
                width: 2.0,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
          ),
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          onSaved: onSaved,
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownFormField({
    required String label,
    required String? value,
    required List<String> items,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
    void Function(String?)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelMedium,
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: (value == null || value.isEmpty) ? null : value,
              items: items
                  .map((item) => DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          style: AppTypography.bodyLarge.copyWith(
                            color: item == value
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                if (onChanged != null) onChanged(value);
                if (onSaved != null) onSaved(value);
              },
              dropdownColor: AppColors.surface,
            ),
          ),
        ),
          if (validator != null &&
              value != null &&
              value.isNotEmpty &&
              validator(value) != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                validator(value)!,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.dangerRed,
                ),
              ),
            ),
        ],
      );
    }

  Widget _buildDocumentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Required Documents',
          style: AppTypography.bodyMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(_documentTypes.length, (index) {
            return FilterChip(
              label: Text(_documentTypes[index]),
              selected: _documentUploaded[index],
              onSelected: (selected) {
                setState(() {
                  _documentUploaded[index] = selected;
                });
              },
              backgroundColor: AppColors.surfaceElevated,
              selectedColor: Colors.green.withValues(alpha: 0.1),
              labelStyle: TextStyle(
                color: _documentUploaded[index]
                    ? Colors.green
                    : AppColors.textSecondary,
              ),
              checkmarkColor: Colors.green,
              avatar: _documentUploaded[index]
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : const Icon(Icons.upload_file),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          '* Please upload all required documents before submitting',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  void _submitApplication() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Check if all required documents are uploaded
      final allDocsUploaded =
          _documentUploaded.every((element) => element == true);
      if (!allDocsUploaded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Please upload all required documents before submitting'),
            backgroundColor: AppColors.dangerRed,
          ),
        );
        return;
      }

      setState(() => _isSubmitting = true);

      try {
        // TODO: Get current user ID from auth
        final String farmerId = 'current_farmer_id';

        // Create application object
        final application = FarmerSchemeApplication(
          id: '',
          schemeId: widget.schemeId,
          farmerId: farmerId,
          applicationDate: DateTime.now(),
          status: 'submitted',
          createdAt: DateTime.now(),
          // In a real app, you would include all the form data here
          // For now, we're just submitting a basic application
        );

        // Submit application via service
        final governmentSchemeService =
            ref.read(governmentSchemeServiceProvider);
        await governmentSchemeService.applyForScheme(application);

        if (mounted) {
          setState(() => _isSubmitting = false);
          // Clear form
          _formKey.currentState!.reset();
          setState(() {
            _documentUploaded.fillRange(0, _documentUploaded.length, false);
          });

          // Show success message and navigate back
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Application submitted successfully!'),
              backgroundColor: AppColors.accentGreen,
            ),
          );

          // Navigate back to scheme detail or home
          // In a real app, you might show a confirmation screen first
          if (mounted) {
            // Navigate back after a delay
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                // You could navigate to a confirmation screen or back to scheme detail
                // For now, just go back
                Navigator.of(context).pop();
              }
            });
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to submit application: $e'),
              backgroundColor: AppColors.dangerRed,
            ),
          );
        }
      }
    }
  }
}