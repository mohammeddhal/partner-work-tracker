import 'package:flutter/material.dart';

class AppColors {
  // Brand / Primary Colors (Unified Modern Royal & Slate Palette)
  static const Color primary = Color(0xFF1E3A8A); // Deep Royal Blue
  static const Color primaryLight = Color(0xFF2563EB); // Vibrant Blue
  static const Color primaryDark = Color(0xFF1E293B); // Slate Dark

  static const Color accent = Color(0xFF10B981); // Emerald Green (Success / Active)
  static const Color accentLight = Color(0xFF34D399);
  static const Color accentDark = Color(0xFF047857);

  static const Color warning = Color(0xFFF59E0B); // Amber / Overtime
  static const Color danger = Color(0xFFEF4444); // Crimson / Delete / Stop
  static const Color info = Color(0xFF0284C7); // Sky Blue / Info

  // Partner Theme Badges
  static const Color partner1 = Color(0xFF2563EB); // Mohammad (Blue)
  static const Color partner2 = Color(0xFF7C3AED); // Masoud (Purple)
  static const Color partner3 = Color(0xFFDB2777); // Future Partner (Pink)

  // Unified Light Mode Colors
  static const Color background = Color(0xFFF8FAFC); // Clean Slate 50
  static const Color surface = Color(0xFFFFFFFF); // Pure White
  static const Color card = Color(0xFFFFFFFF); // Card background
  static const Color cardAlt = Color(0xFFF1F5F9); // Light Slate card
  static const Color border = Color(0xFFE2E8F0); // Subtle Slate border
  static const Color borderSubtle = Color(0xFFF1F5F9);

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400

  // Status indicators
  static const Color statusActive = Color(0xFF10B981);
  static const Color statusCompleted = Color(0xFF2563EB);
  static const Color statusReview = Color(0xFFF59E0B);
  static const Color statusClosed = Color(0xFF64748B);

  // Backward compatibility aliases
  static const Color lightBg = background;
  static const Color lightSurface = surface;
  static const Color lightCard = card;
  static const Color lightBorder = border;
  static const Color lightTextPrimary = textPrimary;
  static const Color lightTextSecondary = textSecondary;
  static const Color lightTextMuted = textMuted;

  static const Color darkBg = background;
  static const Color darkSurface = surface;
  static const Color darkCard = card;
  static const Color darkBorder = border;
  static const Color darkTextPrimary = textPrimary;
  static const Color darkTextSecondary = textSecondary;
  static const Color darkTextMuted = textMuted;
}
