import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Extension hỗ trợ truy xuất màu sắc phản hồi linh hoạt theo chế độ Sáng / Tối (Light / Dark)
extension ThemeContextExtension on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get backgroundColor => isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;
  Color get surfaceColor => isDarkMode ? AppColors.darkSurface : AppColors.lightSurface;
  Color get cardColor => isDarkMode ? AppColors.darkCardElevated : AppColors.lightSurface;
  Color get borderColor => isDarkMode ? AppColors.darkBorder : AppColors.lightBorder;
  Color get textPrimary => isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
  Color get textSecondary => isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  Color get textMuted => isDarkMode ? AppColors.darkTextMuted : AppColors.lightTextMuted;
}
