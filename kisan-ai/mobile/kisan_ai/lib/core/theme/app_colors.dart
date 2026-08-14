import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds
  static const Color primaryBackground = Color(0xFF0A0F0D); // #0A0F0D
  static const Color surface = Color(0xFF111814); // #111814
  static const Color surfaceElevated = Color(0xFF1A2420); // #1A2420

  // Borders
  static const Color borderSubtle = Color(0xFF2A3830); // #2A3830

  // Accents
  static const Color accentGreen = Color(0xFF00E676); // #00E676
  static const Color accentPressed = Color(0xFF00C853); // #00C853
  static const Color accentGlow = Color.fromARGB(38, 0, 230, 118); // rgba(0,230,118,0.15)

  // Status colors
  static const Color warningAmber = Color(0xFFFFB300); // #FFB300
  static const Color dangerRed = Color(0xFFFF5252); // #FF5252
  static const Color infoBlue = Color(0xFF40C4FF); // #40C4FF
  static const Color successGreen = accentGreen;

  // NDVI colors
  static const Color ndviExcellent = Color(0xFF00E676); // #00E676
  static const Color ndviGood = Color(0xFF69F0AE); // #69F0AE
  static const Color ndviFair = Color(0xFFFFB300); // #FFB300
  static const Color ndviPoor = Color(0xFFFF5252); // #FF5252

  // Text colors
  static const Color textPrimary = Color(0xFFF0FFF4); // #F0FFF4
  static const Color textSecondary = Color(0xFF8BA898); // #8BA898
  static const Color textTertiary = Color(0xFF4A6358); // #4A6358

  // Input colors
  static const Color inputFill = Color(0xFF1A2420); // #1A2420
  static const Color inputBorderUnfocused = Color(0xFF2A3830); // #2A3830
  static const Color inputBorderFocused = Color(0xFF00E676); // #00E676
  static const Color inputLabelColor = Color(0xFF8BA898); // #8BA898
  static const Color inputTextColor = Color(0xFFF0FFF4); // #F0FFF4
  static const Color inputCursorColor = Color(0xFF00E676); // #00E676

  // Derived colors for UI
  static const Color cardBackground = surface;
  static const Color cardBorder = borderSubtle;
  static const Color elevatedCardGradientStart = Color(0xFF1A2420);
  static const Color elevatedCardGradientEnd = Color(0xFF111814);
  static const Color elevatedCardBorderTop = accentGreen;
  static const Color badgeBackgroundHealthy = Color(0x1F00E676); // rgba(0,230,118,0.12)
  static const Color badgeTextHealthy = accentGreen;
  static const Color badgeBackgroundWarning = Color(0x1FFFFB300); // rgba(255,179,0,0.12)
  static const Color badgeTextWarning = warningAmber;
  static const Color badgeBackgroundDanger = Color(0x1FFF5252); // rgba(255,82,82,0.12)
  static const Color badgeTextDanger = dangerRed;
  static const Color badgeBackgroundInfo = Color(0x1F40C4FF); // rgba(64,196,255,0.12)
  static const Color badgeTextInfo = infoBlue;
  static const Color dividerColor = borderSubtle;
  static const Color bottomNavBackground = surface;
  static const Color bottomNavBorder = borderSubtle;
  static const Color bottomNavActive = accentGreen;
  static const Color bottomNavInactive = textTertiary;
  static const Color fabBackground = accentGreen;
  static const Color fabIconColor = primaryBackground;
  static const Color fabShadowColor = Color(0x4D00E676); // rgba(0,230,118,0.3)
}
