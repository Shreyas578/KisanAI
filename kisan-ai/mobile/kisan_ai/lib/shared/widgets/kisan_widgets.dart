import 'package:flutter/material.dart';
import 'package:kisan_ai/core/theme/app_theme.dart';

import 'package:go_router/go_router.dart';

/// Kisan Header - Simple header for use in slivers
class KisanAppBar extends StatelessWidget {
  final String title;
  final bool showBackButton;
  final bool showSearch;
  final List<Widget>? actions;

  const KisanAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.showSearch = false,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A0F0D), Color(0xFF1A2420)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            if (showBackButton)
              GestureDetector(
                onTap: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    context.go('/farmer/home');
                  }
                },
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            if (showBackButton) const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: AppTypography.titleLarge.copyWith(color: Colors.white),
              ),
            ),
            if (showSearch)
              GestureDetector(
                onTap: () {
                  // Show search dialog or navigate to search screen
                  showSearchDialog(context);
                },
                child: const Icon(Icons.search, color: Colors.white, size: 24),
              ),
            if (showSearch) const SizedBox(width: 12),
            if (actions != null) ...[const SizedBox(width: 12), ...actions!],
          ],
        ),
      ),
    );
  }
}

/// Show search dialog
void showSearchDialog(BuildContext context) {
  final TextEditingController searchController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Search Products'),
      backgroundColor: AppColors.primaryBackground,
      content: TextField(
        controller: searchController,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Enter search term...',
          hintStyle: const TextStyle(color: AppColors.textSecondary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.borderSubtle),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final query = searchController.text.trim();
            if (query.isNotEmpty) {
              Navigator.pop(context);
              // Navigate to search results screen using GoRouter
              // Using context.go with query parameter
              // context.go('/search?q=${Uri.encodeComponent(query)}');
              // For now, just pop and let the router handle it
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Searching for: $query')));
            }
          },
          child: const Text('Search'),
        ),
      ],
    ),
  );
}

/// Kisan Button following the design system specifications
class KisanButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final double width;
  final double height;
  final Widget? icon;
  final bool isLoading;

  const KisanButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isPrimary = true,
    this.width = double.infinity,
    this.height = 48.0,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary
              ? (isEnabled
                    ? AppColors.accentGreen
                    : AppColors.accentGreen.withValues(alpha: 0.5))
              : (isEnabled
                    ? AppColors.surface
                    : AppColors.surface.withValues(alpha: 0.5)),
          foregroundColor: isPrimary
              ? (isEnabled
                    ? AppColors.primaryBackground
                    : AppColors.primaryBackground.withValues(alpha: 0.5))
              : (isEnabled
                    ? AppColors.textPrimary
                    : AppColors.textPrimary.withValues(alpha: 0.5)),
          disabledBackgroundColor: isPrimary
              ? AppColors.accentGreen.withValues(alpha: 0.5)
              : AppColors.surface.withValues(alpha: 0.5),
          disabledForegroundColor: isPrimary
              ? AppColors.primaryBackground.withValues(alpha: 0.5)
              : AppColors.textPrimary.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[icon!, const SizedBox(width: 8)],
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'SpaceGrotesk',
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Kisan Input Field following the design system specifications
class KisanInput extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final int? maxLines;

  const KisanInput({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: AppTypography.labelMedium.copyWith(
              color: enabled
                  ? AppColors.textSecondary
                  : AppColors.textSecondary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          enabled: enabled,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTypography.labelMedium.copyWith(
              fontSize: 14,
              color: enabled
                  ? AppColors.textTertiary
                  : AppColors.textTertiary.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: enabled
                ? AppColors.inputFill
                : AppColors.inputFill.withValues(alpha: 0.5),
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    color: enabled
                        ? AppColors.textSecondary
                        : AppColors.textSecondary.withValues(alpha: 0.5),
                    size: 20,
                  )
                : null,
            suffixIcon: suffixIcon != null
                ? GestureDetector(
                    onTap: onSuffixTap,
                    child: Icon(
                      suffixIcon,
                      color: enabled
                          ? AppColors.textSecondary
                          : AppColors.textSecondary.withValues(alpha: 0.5),
                      size: 20,
                    ),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.inputBorderUnfocused,
                width: 1.0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.inputBorderUnfocused,
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.inputBorderFocused,
                width: 2.0,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.dangerRed, width: 1.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.dangerRed, width: 2.0),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            isDense: true,
          ),
          style: TextStyle(
            fontSize: 16,
            color: enabled
                ? AppColors.textPrimary
                : AppColors.textPrimary.withValues(alpha: 0.5),
          ),
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          validator: validator,
        ),
      ],
    );
  }
}

/// Kisan Card following the design system specifications
class KisanCard extends StatelessWidget {
  final Widget child;
  final bool isElevated;
  final Color? color;
  final double elevation;

  const KisanCard({
    super.key,
    required this.child,
    this.isElevated = true,
    this.color,
    this.elevation = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:
            color ??
            (isElevated ? AppColors.surface : AppColors.primaryBackground),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isElevated
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}

/// Kisan Shimmer widget for loading states
class KisanShimmer extends StatefulWidget {
  final Widget child;

  const KisanShimmer({super.key, required this.child});

  @override
  State<KisanShimmer> createState() => _KisanShimmerState();
}

class _KisanShimmerState extends State<KisanShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.35,
      end: 0.85,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(opacity: _animation.value, child: widget.child);
      },
    );
  }
}
