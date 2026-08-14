import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan_ai/core/router/app_router.dart';
import 'package:kisan_ai/core/theme/app_theme.dart';
import 'package:kisan_ai/core/theme/app_colors.dart';
import 'package:kisan_ai/core/theme/app_typography.dart';
import 'package:kisan_ai/shared/widgets/kisan_widgets.dart';
import 'package:kisan_ai/shared/widgets/language_voice_widgets.dart';
import '../state/auth_provider.dart';
import '../models/auth_model.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedRole = 'farmer';
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Passwords do not match'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);
      ref.read(authProvider.notifier).register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole,
      );
    }
  }

  void _navigateToLogin() {
    ref.read(appRouterProvider).pop();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Handle auth state changes
    authState.when(
      data: (state) {
        if (state.authenticated) {
          // User is registered and logged in, navigate to home
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Navigate based on user role
            switch (state.user?.role) {
              case 'farmer':
                ref.read(appRouterProvider).pushReplacement('/farmer/home');
                break;
              case 'buyer':
                ref.read(appRouterProvider).pushReplacement('/buyer/home');
                break;
              case 'supplier':
                ref.read(appRouterProvider).pushReplacement('/supplier/home');
                break;
              default:
                ref.read(appRouterProvider).pushReplacement('/onboarding');
                break;
            }
          });
        }
        return null; // Required for when() callback
      },
      loading: () => null,
      error: (error, stackTrace) => null,
    );

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo
                Container(
                  width: 100,
                  height: 100,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: AppColors.accentGreen.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.agriculture,
                    size: 40,
                    color: AppColors.accentGreen,
                  ),
                ),
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Join Kisan AI to start your farming journey',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    color: Color(0xFF8BA898),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Name Field
                Text(
                  'Full Name',
                  style: AppTypography.labelMedium,
                ),
                const SizedBox(height: 8),
                KisanInput(
                  controller: _nameController,
                  labelText: 'Full Name',
                  hintText: 'Enter your full name',
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    if (value.length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email Field
                Text(
                  'Email Address',
                  style: AppTypography.labelMedium,
                ),
                const SizedBox(height: 8),
                KisanInput(
                  controller: _emailController,
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Phone Field
                Text(
                  'Phone Number',
                  style: AppTypography.labelMedium,
                ),
                const SizedBox(height: 8),
                KisanInput(
                  controller: _phoneController,
                  labelText: 'Phone',
                  hintText: 'Enter your phone number',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    // Simple phone validation - adjust as needed for your region
                    if (!RegExp(r'^\+?[\d\s\-\(\)]{10,}$')
                        .hasMatch(value)) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Role Selection
                Text(
                  'I am a...',
                  style: AppTypography.labelMedium,
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Column(
                    children: [
                      _buildRoleOption('farmer', 'Farmer', Icons.agriculture),
                      _buildRoleOption('buyer', 'Buyer', Icons.shopping_cart),
                      _buildRoleOption('supplier', 'Supplier', Icons.storefront),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Password Field
                Text(
                  'Password',
                  style: AppTypography.labelMedium,
                ),
                const SizedBox(height: 8),
                KisanInput(
                  controller: _passwordController,
                  labelText: 'Password',
                  hintText: 'Create a password',
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  obscureText: _obscurePassword,
                  onSuffixTap: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Confirm Password Field
                Text(
                  'Confirm Password',
                  style: AppTypography.labelMedium,
                ),
                const SizedBox(height: 8),
                KisanInput(
                  controller: _confirmPasswordController,
                  labelText: 'Confirm Password',
                  hintText: 'Repeat your password',
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: _obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  obscureText: _obscureConfirmPassword,
                  onSuffixTap: () {
                    setState(() =>
                        _obscureConfirmPassword = !_obscureConfirmPassword);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Register Button
                KisanButton(
                  text: _isLoading ? 'Creating Account...' : 'Register',
                  onPressed: _isLoading ? null : _register,
                  isPrimary: true,
                  width: double.infinity,
                  height: 56,
                ),
                const SizedBox(height: 24),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account?",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8BA898),
                      ),
                    ),
                    TextButton(
                      onPressed: _navigateToLogin,
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accentGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Terms and Conditions
                RichText(
                  text: TextSpan(
                    text: 'By registering, you agree to our ',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8BA898),
                    ),
                    children: [
                      const TextSpan(
                        text: 'Terms of Service',
                        style: TextStyle(
                          color: AppColors.accentGreen,
                        ),
                      ),
                      const TextSpan(text: ' and '),
                      const TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: AppColors.accentGreen,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleOption(String value, String label, IconData icon) {
    final isSelected = _selectedRole == value;
    return InkWell(
      onTap: () {
        setState(() => _selectedRole = value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected
                  ? AppColors.accentGreen
                  : AppColors.borderSubtle,
              width: isSelected ? 2 : 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.accentGreen : Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? Colors.white
                      : Color(0xFF8BA898),
                ),
              ),
            ),
            isSelected
                ? const Icon(
                    Icons.check_circle,
                    color: AppColors.accentGreen,
                    size: 20,
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}