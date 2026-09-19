import 'package:flutter/material.dart';

/// Placeholder palette — replace with the school's actual brand colors,
/// ideally fetched at runtime from `GET general-settings` rather than
/// hardcoded (see AuthRepository.fetchGeneralSettings).
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF1E5AA8);
  static const Color primaryDark = Color(0xFF123B73);
  static const Color secondary = Color(0xFFF5A623);

  static const Color background = Color(0xFFF6F8FB);
  static const Color surface = Colors.white;

  static const Color textPrimary = Color(0xFF1B1F24);
  static const Color textSecondary = Color(0xFF6B7480);

  static const Color success = Color(0xFF2E9E5B);
  static const Color error = Color(0xFFD64545);
  static const Color warning = Color(0xFFE0A11C);
}
