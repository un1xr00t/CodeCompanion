import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors (GitHub-inspired with iOS 26 glass aesthetic)
  static const Color primary = Color(0xFF238636);
  static const Color primaryDark = Color(0xFF1F6E2E);
  static const Color primaryLight = Color(0xFF2EA043);
  
  // GitHub Brand
  static const Color githubBlack = Color(0xFF24292F);
  static const Color githubGray = Color(0xFF57606A);
  
  // iOS 26 Liquid Glass - Background Colors
  static const Color glassBackgroundLight = Color(0xFFF5F5F7);
  static const Color glassBackgroundDark = Color(0xFF000000);
  
  static const Color glassSurfaceLight = Color(0xFFFFFFFF);
  static const Color glassSurfaceDark = Color(0xFF1C1C1E);
  
  // Glass overlay colors for blur effects
  static Color glassOverlayLight = Colors.white.withOpacity(0.7);
  static Color glassOverlayDark = Colors.black.withOpacity(0.5);
  
  // iOS 26 Accent Colors
  static const Color accentBlue = Color(0xFF007AFF);
  static const Color accentPurple = Color(0xFF5E5CE6);
  static const Color accentPink = Color(0xFFFF2D55);
  static const Color accentTeal = Color(0xFF5AC8FA);
  static const Color accentIndigo = Color(0xFF5856D6);
  
  // Text Colors
  static const Color textPrimaryLight = Color(0xFF000000);
  static const Color textSecondaryLight = Color(0xFF3C3C43);
  static const Color textTertiaryLight = Color(0xFF8E8E93);
  
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFEBEBF5);
  static const Color textTertiaryDark = Color(0xFF8E8E93);
  
  // Contribution Grid Colors (Enhanced with glass effect)
  static const Color contributionLevel0 = Color(0xFFEBEDF0);
  static const Color contributionLevel1 = Color(0xFF9BE9A8);
  static const Color contributionLevel2 = Color(0xFF40C463);
  static const Color contributionLevel3 = Color(0xFF30A14E);
  static const Color contributionLevel4 = Color(0xFF216E39);
  
  // Dark mode contribution colors
  static const Color contributionLevel0Dark = Color(0xFF161B22);
  static const Color contributionLevel1Dark = Color(0xFF0E4429);
  static const Color contributionLevel2Dark = Color(0xFF006D32);
  static const Color contributionLevel3Dark = Color(0xFF26A641);
  static const Color contributionLevel4Dark = Color(0xFF39D353);
  
  // Status Colors
  static const Color success = Color(0xFF34C759);
  static const Color error = Color(0xFFFF3B30);
  static const Color warning = Color(0xFFFF9500);
  static const Color info = Color(0xFF007AFF);
  
  // Glass card border colors
  static Color glassBorderLight = Colors.white.withOpacity(0.2);
  static Color glassBorderDark = Colors.white.withOpacity(0.1);
}