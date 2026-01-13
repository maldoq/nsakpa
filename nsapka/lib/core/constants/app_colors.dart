import 'package:flutter/material.dart';

/// Couleurs de l'application N'SAPKA
/// Palette inspirée de l'artisanat africain avec des tons chauds et accueillants
class AppColors {
  // Couleurs principales
  static const Color primary = Color(0xFFB8860B); // Or foncé (DarkGoldenrod)
  static const Color primaryLight = Color(0xFFDAA520); // Or (Goldenrod)
  static const Color primaryDark = Color(0xFF8B6914); // Or très foncé
  
  // Couleurs secondaires - tons terre et artisanaux
  static const Color secondary = Color(0xFF8B4513); // Marron selle (SaddleBrown)
  static const Color secondaryLight = Color(0xFFCD853F); // Pérou
  static const Color secondaryDark = Color(0xFF654321); // Marron foncé
  
  // Couleurs d'accentuation
  static const Color accent = Color(0xFFFF8C00); // Orange foncé
  static const Color accentLight = Color(0xFFFFA500); // Orange
  
  // Couleurs tertiaires - tons naturels
  static const Color terracotta = Color(0xFFE07A5F); // Terracotta
  static const Color sand = Color(0xFFF4E4C1); // Sable
  static const Color clay = Color(0xFFD4A574); // Argile
  
  // Couleurs de fond
  static const Color background = Color(0xFFFFFAF0); // Blanc floral
  static const Color backgroundDark = Color(0xFFF5F5DC); // Beige
  static const Color surface = Color(0xFFFFFFFF); // Blanc
  
  // Couleurs de texte
  static const Color textPrimary = Color(0xFF2C1810); // Marron très foncé
  static const Color textSecondary = Color(0xFF5D4037); // Marron
  static const Color textLight = Color(0xFF8D6E63); // Marron clair
  static const Color textWhite = Color(0xFFFFFFFF); // Blanc
  
  // Couleurs d'état
  static const Color success = Color(0xFF4CAF50); // Vert
  static const Color error = Color(0xFFD32F2F); // Rouge
  static const Color warning = Color(0xFFFFA726); // Orange clair
  static const Color info = Color(0xFF29B6F6); // Bleu clair
  
  // Couleurs de bordure et divider
  static const Color border = Color(0xFFD7CCC8); // Marron très clair
  static const Color divider = Color(0xFFEFEBE9); // Beige très clair
  
  // Couleurs de gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient warmGradient = LinearGradient(
    colors: [accent, primaryLight, terracotta],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Overlay colors
  static const Color overlay = Color(0x80000000); // Noir semi-transparent
  static const Color overlayLight = Color(0x40000000); // Noir léger
}
