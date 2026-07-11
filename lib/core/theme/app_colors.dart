import 'package:flutter/material.dart';

/// Definición centralizada de todos los colores de la aplicación
abstract class AppColors {
  // Neutrales
  static const Color dark = Color(0xFF0B1020);
  static const Color darkCard = Color(0xFF151B2E);
  static const Color lightText = Color(0xFFE2E8F0);
  static const Color secondaryText = Color(0xFF94A3B8);
  static const Color border = Color(0xFF334155);

  // Primarios
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);

  // Secundarios
  static const Color secondary = Color(0xFFEC4899);
  static const Color secondaryLight = Color(0xFFF472B6);
  static const Color secondaryDark = Color(0xFFBE185D);

  // Terciarios
  static const Color tertiary = Color(0xFFF97316);
  static const Color tertiaryLight = Color(0xFFFB923C);
  static const Color tertiaryDark = Color(0xFFEA580C);

  // Estados
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0x1A10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0x1AF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0x1AEF4444);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0x1A3B82F6);

  // Especiales
  static const Color gold = Color(0xFFD4AF37);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color cyan = Color(0xFF06B6D4);
  static const Color lime = Color(0xFF84CC16);

  // Para anatomía
  static const Color anatomyRed = Color(0xFFEF4444);

  // Para fisiología
  static const Color physiologyBlue = Color(0xFF3B82F6);

  // Para bioquímica
  static const Color biochemistryGreen = Color(0xFF10B981);

  // Para farmacología
  static const Color pharmacologyOrange = Color(0xFFF59E0B);

  // Para histología
  static const Color histologyPurple = Color(0xFF8B5CF6);

  // Light theme
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF1E293B);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // Overlay
  static const Color overlay = Color(0xFF000000);
  static const Color overlayLight = Color(0xFFFFFFFF);

  /// Método auxiliar para obtener opacidad
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  /// Gradientes comunes
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient rainbowGradient = LinearGradient(
    colors: [primary, secondary, tertiary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
