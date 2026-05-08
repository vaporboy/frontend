import 'package:flutter/material.dart';

/// Convenience accessors for semantic status colors on [ColorScheme].
///
/// Prefer `SoliplexTheme.of(context).colors.info` (etc.) in widget code
/// so colors are tenant-overridable. This extension exists for call sites
/// that only have a [ColorScheme].
extension SymbolicColors on ColorScheme {
  bool get isDarkMode => brightness == Brightness.dark;

  Color get info => brightness == Brightness.light
      ? const Color(0xFF2196F3)
      : const Color(0xFF64B5F6);

  Color get warning => brightness == Brightness.light
      ? const Color(0xFFFF9800)
      : const Color(0xFFFFB74D);

  Color get danger => brightness == Brightness.light
      ? const Color(0xFFF44336)
      : const Color(0xFFE57373);

  Color get success => brightness == Brightness.light
      ? const Color(0xFF4CAF50)
      : const Color(0xFF81C784);
}
