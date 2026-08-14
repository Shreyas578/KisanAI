import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan_ai/core/theme/app_theme.dart';
import 'package:kisan_ai/features/auth/state/auth_provider.dart';
import 'package:kisan_ai/providers/farmer_profile_provider.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  bool _isSaving = false;
  bool _hasAvatar = false; // simulates a picked image

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    final profile = ref.read(farmerProfileProvider);

    _nameController = TextEditingController(text: user?.name ?? profile?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? profile?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? profile?.phone ?? '');
    _locationController = TextEditingController(
        text: profile != null
            ? [profile.village, profile.district, profile.state]
                .where((s) => s.isNotEmpty)
                .join(', ')
            : '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    // Simulate image picking — in production, use image_picker package
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _hasAvatar = true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile photo selected! Tap Save to apply.'),
          backgroundColor: AppColors.accentGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    // Simulate API save delay
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✅ Profile updated successfully!'),
          backgroundColor: AppColors.accentGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final initial = (user?.name.isNotEmpty == true) ? user!.name[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F0D),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0D1F17), Color(0xFF0A0F0D)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Edit Profile',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold,
                            color: Color(0xFFF0FFF4))),
                  ),
                  TextButton(
                    onPressed: _isSaving ? null : _saveProfile,
                    child: _isSaving
                        ? const SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(
                                color: Color(0xFF00E676), strokeWidth: 2))
                        : const Text('Save',
                            style: TextStyle(
                                color: Color(0xFF00E676),
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Avatar section
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 56,
                              backgroundColor: _hasAvatar
                                  ? const Color(0xFF00E676).withOpacity(0.2)
                                  : const Color(0xFF00E676),
                              child: _hasAvatar
                                  ? const Icon(Icons.person, size: 56, color: Color(0xFF00E676))
                                  : Text(initial,
                                      style: const TextStyle(
                                          fontSize: 36, fontWeight: FontWeight.bold,
                                          color: Color(0xFF0A0F0D))),
                            ),
                            Positioned(
                              bottom: 0, right: 0,
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  width: 36, height: 36,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF00E676), shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.camera_alt,
                                      color: Color(0xFF0A0F0D), size: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('Tap the camera icon to change your photo',
                          style: TextStyle(fontSize: 12, color: Color(0xFF8BA898))),
                      const SizedBox(height: 32),

                      // Form fields
                      _buildField(
                        label: 'Full Name',
                        controller: _nameController,
                        icon: Icons.person_outline,
                        validator: (v) => v == null || v.isEmpty ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        label: 'Email Address',
                        controller: _emailController,
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty) return null; // optional
                          if (!v.contains('@')) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        label: 'Phone Number',
                        controller: _phoneController,
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        readOnly: true, // phone is identity, not editable
                        hint: 'Phone cannot be changed',
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        label: 'Location (Village, District, State)',
                        controller: _locationController,
                        icon: Icons.location_on_outlined,
                        hint: 'e.g., Karnal, Haryana',
                      ),
                      const SizedBox(height: 32),

                      // Save button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00E676),
                            foregroundColor: const Color(0xFF0A0F0D),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: _isSaving
                              ? const CircularProgressIndicator(
                                  color: Color(0xFF0A0F0D), strokeWidth: 2)
                              : const Text('Save Changes',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool readOnly = false,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF8BA898))),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          readOnly: readOnly,
          style: TextStyle(
              color: readOnly ? const Color(0xFF4A5E58) : const Color(0xFFF0FFF4),
              fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF4A5E58), fontSize: 14),
            prefixIcon: Icon(icon, color: const Color(0xFF00E676), size: 20),
            filled: true,
            fillColor: readOnly ? const Color(0xFF0D1207) : const Color(0xFF1A2420),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2E3D38)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2E3D38)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00E676), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF5252)),
            ),
          ),
        ),
      ],
    );
  }
}
