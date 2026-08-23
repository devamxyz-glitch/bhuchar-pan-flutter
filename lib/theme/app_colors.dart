import 'package:flutter/material.dart';

/// Centralized luxury color palette for Bhuchar Pan.
/// Inspired by Apple, Rolex, and Tesla dark luxury design systems.
abstract class AppColors {
  // Pure Black & Dark Surfaces
  static const Color pureBlack = Color(0xFF000000);
  static const Color cardDark = Color(0xFF0A0A0A);
  static const Color surfaceDark = Color(0xFF121212);
  static const Color surfaceLightDark = Color(0xFF1E1E1E);
  static const Color glassBackground = Color(0xFF0F0F0F);

  // Metallic Gold Accents
  static const Color goldPrimary = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFE5C058);
  static const Color goldDark = Color(0xFFB89221);
  static const Color goldDeep = Color(0xFF8A6B22);
  static const Color goldAmbient = Color(0xFF2A200A);

  // Text & Content
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0x99FFFFFF);
  static const Color textMuted = Color(0x66FFFFFF);
  static const Color textGold = Color(0xFFD4AF37);

  // State & Feedback
  static const Color error = Color(0xFFFF4D4D);
  static const Color success = Color(0xFF4DFF88);
  static const Color warning = Color(0xFFFFB800);

  // Luxury Gradients
  static const LinearGradient goldGradient = LinearGradient(
    colors: [goldLight, goldDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color(0x1AD4AF37),
      Color(0x05D4AF37),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}