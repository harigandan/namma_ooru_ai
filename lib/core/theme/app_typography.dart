import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography configuration with bilingual English & Tamil support
class AppTypography {
  AppTypography._();

  static TextStyle getHeading1(
      {Color color = AppColors.textPrimary, bool isTamil = false}) {
    final style = TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      height: 1.25,
      color: color,
    );
    return isTamil
        ? GoogleFonts.notoSansTamil(textStyle: style)
        : GoogleFonts.inter(textStyle: style);
  }

  static TextStyle getHeading2(
      {Color color = AppColors.textPrimary, bool isTamil = false}) {
    final style = TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
      height: 1.3,
      color: color,
    );
    return isTamil
        ? GoogleFonts.notoSansTamil(textStyle: style)
        : GoogleFonts.inter(textStyle: style);
  }

  static TextStyle getHeading3(
      {Color color = AppColors.textPrimary, bool isTamil = false}) {
    final style = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
      height: 1.35,
      color: color,
    );
    return isTamil
        ? GoogleFonts.notoSansTamil(textStyle: style)
        : GoogleFonts.inter(textStyle: style);
  }

  static TextStyle getSubheading(
      {Color color = AppColors.textSecondary, bool isTamil = false}) {
    final style = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 1.4,
      color: color,
    );
    return isTamil
        ? GoogleFonts.notoSansTamil(textStyle: style)
        : GoogleFonts.inter(textStyle: style);
  }

  static TextStyle getBodyLarge(
      {Color color = AppColors.textPrimary, bool isTamil = false}) {
    final style = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: color,
    );
    return isTamil
        ? GoogleFonts.notoSansTamil(textStyle: style)
        : GoogleFonts.inter(textStyle: style);
  }

  static TextStyle getBody(
      {Color color = AppColors.textPrimary, bool isTamil = false}) {
    final style = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: color,
    );
    return isTamil
        ? GoogleFonts.notoSansTamil(textStyle: style)
        : GoogleFonts.inter(textStyle: style);
  }

  static TextStyle getCaption(
      {Color color = AppColors.textSecondary, bool isTamil = false}) {
    final style = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.4,
      color: color,
    );
    return isTamil
        ? GoogleFonts.notoSansTamil(textStyle: style)
        : GoogleFonts.inter(textStyle: style);
  }

  static TextStyle getButtonLabel(
      {Color color = Colors.white, bool isTamil = false}) {
    final style = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
      color: color,
    );
    return isTamil
        ? GoogleFonts.notoSansTamil(textStyle: style)
        : GoogleFonts.inter(textStyle: style);
  }
}
