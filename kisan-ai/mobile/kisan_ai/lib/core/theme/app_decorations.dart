import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppDecorations {
  static const double borderRadius = 16.0;
  static const double elevatedBorderRadius = 16.0;
  static const double cardBorderRadius = 16.0;
  static final RoundedRectangleBorder cardShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(cardBorderRadius),
    side: const BorderSide(
      color: AppColors.borderSubtle,
      width: 0.5,
    ),
  );

  static final BoxDecoration cardDecoration = BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(cardBorderRadius),
    border: Border.all(
      color: AppColors.borderSubtle,
      width: 0.5,
    ),
  );

  static final BoxDecoration elevatedCardDecoration = BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF1A2420), // #1A2420
        Color(0xFF111814), // #111814
      ],
    ),
    borderRadius: BorderRadius.circular(elevatedBorderRadius),
    border: const Border(
      top: BorderSide(
        color: AppColors.accentGreen, // #00E676
        width: 1.5,
      ),
      left: BorderSide(
        color: AppColors.borderSubtle,
        width: 0.5,
      ),
      right: BorderSide(
        color: AppColors.borderSubtle,
        width: 0.5,
      ),
      bottom: BorderSide(
        color: AppColors.borderSubtle,
        width: 0.5,
      ),
    ),
  );

  static final BoxDecoration heroCardDecoration = elevatedCardDecoration;

  static final BoxShape circle = BoxShape.circle;

  static final BoxDecoration avatarBackground = BoxDecoration(
    color: AppColors.surfaceElevated,
    shape: BoxShape.circle,
  );

  static final BoxDecoration chipDecoration = BoxDecoration(
    color: AppColors.surfaceElevated,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: AppColors.borderSubtle,
    ),
  );

  static final BoxDecoration selectedChipDecoration = BoxDecoration(
    color: AppColors.accentGreen.withOpacity(0.08),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: AppColors.accentGreen,
    ),
  );

  static BoxDecoration statusBadgeBackground(String status) {
    switch (status.toLowerCase()) {
      case 'healthy':
      case 'active':
        return BoxDecoration(
          color: AppColors.accentGreen.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
        );
      case 'warning':
      case 'fair':
        return BoxDecoration(
          color: AppColors.warningAmber.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
        );
      case 'danger':
      case 'error':
        return BoxDecoration(
          color: AppColors.dangerRed.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
        );
      case 'info':
      case 'pending':
        return BoxDecoration(
          color: AppColors.infoBlue.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
        );
      default:
        return BoxDecoration(
          color: AppColors.borderSubtle.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
        );
    }
  }

  static final BoxDecoration inputDecoration = BoxDecoration(
    color: AppColors.surfaceElevated,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: AppColors.borderSubtle,
    ),
  );

  static final BoxDecoration focusedInputDecoration = BoxDecoration(
    color: AppColors.surfaceElevated,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: AppColors.accentGreen,
    ),
  );

  static const BoxShadow cardShadow = BoxShadow(
    color: Colors.black26,
    blurRadius: 4,
    offset: Offset(0, 2),
  );

  static const BoxShadow elevatedCardShadow = BoxShadow(
    color: Color.fromARGB(77, 0, 230, 118), // rgba(0,230,118,0.3)
    blurRadius: 20,
    offset: Offset(0, 8),
  );

  static const List<BoxShadow> fabShadow = [
    BoxShadow(
      color: Color.fromARGB(77, 0, 230, 118), // rgba(0,230,118,0.3)
      blurRadius: 20,
      offset: Offset(0, 8),
    )
  ];
}