import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // === VIBRANT COLOR PALETTE ===

  // Primary Vibrant Colors (Much Brighter!)
  static const Color lavender = Color(0xFFA78BFA);        // Main brand - rich purple
  static const Color mintGreen = Color(0xFF6EE7B7);       // Success/Growth - bright mint
  static const Color peach = Color(0xFFFBBF24);           // Warmth/Energy - bright amber
  static const Color skyBlue = Color(0xFF60A5FA);         // Calm/Trust - vibrant blue
  static const Color softPurple = Color(0xFFC084FC);      // Care/Love - bright purple
  static const Color lemon = Color(0xFFFDE047);           // Joy/Optimism - bright yellow
  static const Color lightPurple = Color(0xFFD8B4FE);     // Gentle purple

  // Neutral & Backgrounds (Slightly Off-White)
  static const Color cream = Color(0xFFFFFBF5);           // Main background - very light cream
  static const Color softGray = Color(0xFFF8F9FA);        // Cards/Surfaces - near white
  static const Color mistyWhite = Color(0xFFFFFFFF);      // Pure white
  static const Color paleGray = Color(0xFFE5E7EB);        // Visible borders
  
  // Text Colors (Strong & Readable)
  static const Color deepLavender = Color(0xFF5B21B6);    // Primary text - deep purple
  static const Color softCharcoal = Color(0xFF374151);    // Body text - dark gray
  static const Color deepCharcoal = Color(0xFF1F2937);    // Very dark text for high contrast
  static const Color lightGray = Color(0xFF6B7280);       // Secondary text
  static const Color mutedGray = Color(0xFF9CA3AF);       // Placeholder text
  
  // Vibrant Gradient Combinations (Brighter!)
  static const List<Color> primaryGradient = [lavender, Color(0xFF8B5CF6)];
  static const List<Color> mintGradient = [mintGreen, Color(0xFF34D399)];
  static const List<Color> peachGradient = [peach, Color(0xFFF59E0B)];
  static const List<Color> skyGradient = [skyBlue, Color(0xFF3B82F6)];
  static const List<Color> purpleGradient = [softPurple, Color(0xFFA855F7)];
  static const List<Color> sunsetGradient = [Color(0xFFF59E0B), Color(0xFFEC4899)];
  static const List<Color> oceanGradient = [Color(0xFF06B6D4), Color(0xFF10B981)];
  static const List<Color> dreamGradient = [Color(0xFF8B5CF6), Color(0xFFEC4899)];
  static const List<Color> forestGradient = [Color(0xFF10B981), Color(0xFF059669)];
  
  // Semantic Colors (Bright & Clear)
  static const Color success = Color(0xFF10B981);          // Bright green
  static const Color warning = Color(0xFFF59E0B);          // Bright amber
  static const Color error = Color(0xFFEF4444);            // Bright red
  static const Color info = Color(0xFF3B82F6);             // Bright blue
  
  // Legacy Support (keeping for compatibility)
  static const Color primaryBlue = skyBlue;               // Map to pastel equivalent
  static const Color growthGreen = mintGreen;             // Map to pastel equivalent
  static const Color mindfulOrange = peach;              // Map to pastel equivalent
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color transparent = Colors.transparent;
  static const Color textPrimary = deepLavender;
  static const Color textSecondary = lightGray;
  static const Color textLight = mutedGray;
  static const Color backgroundPrimary = cream;
  static const Color backgroundSecondary = softGray;
  static const Color backgroundCard = mistyWhite;
  static const Color backgroundWhite = mistyWhite;
  static const Color darkGray = softCharcoal;
  
  // Shadow Colors (More Visible)
  static const Color shadowLight = Color(0x10000000);     // Light shadow
  static const Color shadowMedium = Color(0x1A000000);    // Medium shadow
  static const Color shadowDark = Color(0x30000000);      // Dark shadow
  static const Color shadowPastel = Color(0x20A78BFA);    // Purple tinted shadow
  
  // Helper Methods for Dynamic Colors
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }
  
  static LinearGradient createGradient(List<Color> colors, {
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      colors: colors,
      begin: begin,
      end: end,
    );
  }
}