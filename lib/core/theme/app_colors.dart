import 'package:flutter/material.dart';

class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  //---------------------------------------------------------------------------
  // BACKGROUND COLORS
  //---------------------------------------------------------------------------

  /// Main background color - White
  static const Color background = Colors.white;

  /// Notification card background - Blue with 7% opacity
  static Color notificationCardBg = primaryWithOpacity(0.07);

  //---------------------------------------------------------------------------
  // TEXT COLORS
  //---------------------------------------------------------------------------

  /// Heading text color - Black
  static const Color headingText = Color(0xFF000000);

  /// Body text color - Medium Gray
  static const Color bodyText = Color(0xFF8E8E93);

  /// Label text color - Dark Gray
  static const Color labelText = Color(0xFF1E1E1E);

  static const Color borderGrey = Color(0xFFC7C7CC);

  /// Primary text color (alias for headingText for backward compatibility)
  static const Color primaryText = headingText;

  /// Secondary text color (alias for bodyText for backward compatibility)
  static const Color secondaryText = bodyText;

  /// Tertiary text color (alias for labelText for backward compatibility)
  static const Color tertiaryText = labelText;

  //---------------------------------------------------------------------------
  // BUTTON & BRAND COLORS
  //---------------------------------------------------------------------------

  /// Primary brand color - Blue
  static const Color primary = Color(0xFF0088FF);

  /// Gradient blue - End color
  static const Color gradientBlueEnd = Color(0xFF5D6EFC);

  //---------------------------------------------------------------------------
  // STATUS COLORS
  //---------------------------------------------------------------------------

  /// Success/Green text - Bright Green
  static const Color success = Color(0xFF009F00);

  /// Error/Red text - Bright Red
  static const Color error = Color(0xFFD90000);

  /// Warning text/icon - Amber/Orange
  static const Color warning = Color(0xFFF59E0B);

  //---------------------------------------------------------------------------
  // SEMANTIC COLORS
  //---------------------------------------------------------------------------

  /// Border color - Blue (matching button border)
  static const Color border = Color(0xFF0088FF);

  /// Success surface - Light Green
  static const Color successSurface = Color(0xFF009F00);

  /// Disabled/Inactive surface
  static const Color disabledSurface = Color(0xFF1E1E1E);

  /// Secondary surface (for alternate backgrounds)
  static const Color secondarySurface = Color(0xFFF2F2F7);

  //---------------------------------------------------------------------------
  // COMMON COLORS
  //---------------------------------------------------------------------------

  /// White color
  static const Color white = Colors.white;

  /// Black color
  static const Color black = Colors.black;

  //---------------------------------------------------------------------------
  // CONVENIENCE GETTERS WITH OPACITY
  //---------------------------------------------------------------------------

  /// Get primary color with custom opacity
  static Color primaryWithOpacity(double opacity) =>
      primary.withOpacity(opacity.clamp(0.0, 1.0));

  /// Get weekly color with custom opacity
  static Color weeklyWithOpacity(double opacity) =>
      primary.withValues(alpha: opacity.clamp(0.0, 1.0));

  /// Get "Upcoming" border color with custom opacity
  static Color upcomingWithOpacity(double opacity) =>
      tertiaryText.withValues(alpha: opacity.clamp(0.0, 1.0));

  /// Get error color with custom opacity
  static Color errorWithOpacity(double opacity) =>
      error.withOpacity(opacity.clamp(0.0, 1.0));

  /// Get success color with custom opacity
  static Color successWithOpacity(double opacity) =>
      success.withOpacity(opacity.clamp(0.0, 1.0));

  /// Get warning color with custom opacity
  static Color warningWithOpacity(double opacity) =>
      warning.withOpacity(opacity.clamp(0.0, 1.0));

  /// Get gradient blue start with custom opacity
  static Color gradientBlueStartWithOpacity(double opacity) =>
      primary.withOpacity(opacity.clamp(0.0, 1.0));

  /// Get gradient blue end with custom opacity
  static Color gradientBlueEndWithOpacity(double opacity) =>
      gradientBlueEnd.withOpacity(opacity.clamp(0.0, 1.0));

  //---------------------------------------------------------------------------
  // MATERIAL THEME COLOR SCHEMES
  //---------------------------------------------------------------------------

  /// Light Theme Color Scheme
  static ColorScheme get lightScheme => const ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: white,
    secondary: success,
    onSecondary: white,
    tertiary: warning,
    onTertiary: white,
    error: error,
    onError: white,
    surface: background,
    onSurface: headingText,
    surfaceContainerHighest: secondarySurface,
    onSurfaceVariant: bodyText,
    outline: borderGrey,
    outlineVariant: borderGrey,
    scrim: black,
    shadow: Color(0x1A000000),
    inverseSurface: headingText,
    onInverseSurface: background,
    primaryContainer: primary,
    onPrimaryContainer: white,
    secondaryContainer: success,
    onSecondaryContainer: white,
    tertiaryContainer: warning,
    onTertiaryContainer: white,
    errorContainer: error,
    onErrorContainer: white,
  );
}

extension AppColorExtensions on BuildContext {
  /// Get light theme color scheme
  ColorScheme get lightScheme => AppColors.lightScheme;
}
