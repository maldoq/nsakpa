import 'package:flutter/material.dart';

extension ThemeExtensions on BuildContext {
  /// Retourne les couleurs du thème actuel
  ColorScheme get colors => Theme.of(this).colorScheme;

  /// Couleur de fond principale
  Color get backgroundColor => Theme.of(this).scaffoldBackgroundColor;

  /// Couleur de surface (cards, etc)
  Color get surfaceColor => Theme.of(this).colorScheme.surface;

  /// Couleur de texte principale
  Color get textColor => Theme.of(this).colorScheme.onSurface;

  /// Couleur de texte secondaire
  Color get textSecondaryColor =>
      Theme.of(this).colorScheme.onSurface.withOpacity(0.6);

  /// Vérifie si le thème sombre est actif
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
