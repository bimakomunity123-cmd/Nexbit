import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens for the Nexbit landing page.
/// Mirrors the CSS custom properties from the HTML prototype 1:1
/// so the Flutter build stays visually consistent with it.
class NexbitColors {
  NexbitColors._();

  static const bg = Color(0xFF05070C);
  static const surface = Color(0xFF0C111C);
  static const surface2 = Color(0xFF121A29);
  static const panel = Color(0xFF0C111C);
  static const line = Color(0xFF1C2536);
  static const lineSoft = Color(0xFF161E2C);
  static const text = Color(0xFFE8ECF4);
  static const muted = Color(0xFF7C8AA3);
  static const muted2 = Color(0xFF4F5C72);
  static const accent = Color(0xFF2FE6C4); // teal-mint
  static const accent2 = Color(0xFF6E7BFF); // indigo
  static const up = Color(0xFF2FE6C4);
  static const down = Color(0xFFFF5D7A);

  static const accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accent2],
  );
}

class NexbitText {
  NexbitText._();

  static TextStyle display({
    double fontSize = 44,
    FontWeight weight = FontWeight.w700,
    Color color = NexbitColors.text,
    double? height,
    double letterSpacing = -1,
  }) =>
      GoogleFonts.spaceGrotesk(
        fontSize: fontSize,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  static TextStyle body({
    double fontSize = 16,
    FontWeight weight = FontWeight.w400,
    Color color = NexbitColors.muted,
    double? height,
  }) =>
      GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: weight,
        color: color,
        height: height,
      );

  static TextStyle mono({
    double fontSize = 14,
    FontWeight weight = FontWeight.w500,
    Color color = NexbitColors.text,
    double? letterSpacing,
  }) =>
      GoogleFonts.jetBrainsMono(
        fontSize: fontSize,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
      );
}

/// Breakpoint used to switch the hero from a two-column desktop
/// layout to a stacked mobile layout — matches the 980px CSS breakpoint.
const double kNexbitMobileBreakpoint = 980;
