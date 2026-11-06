import 'package:flutter/material.dart';

/// Bảng màu chuẩn Muted Minimal theo đặc tả UI/UX Mục 1.6
class AppColors {
  // Primary & Accent
  static const Color primary = Color(0xFF7066A6); // Tím oải hương thanh lịch
  static const Color primaryDark = Color(0xFF534A85);
  static const Color primaryLight = Color(0xFF9086C4);

  // Backgrounds
  static const Color darkBackground = Color(0xFF111116); // AMOLED Dark tiết kiệm pin (NFR-16)
  static const Color lightBackground = Color(0xFFF8F8FC); // Nền sáng dịu mắt

  // Surfaces & Cards
  static const Color darkSurface = Color(0xFF1A1A22); // Nền card tối
  static const Color lightSurface = Color(0xFFFFFFFF); // Nền card sáng
  static const Color darkCardElevated = Color(0xFF22222D);

  // Borders & Dividers
  static const Color darkBorder = Color(0xFF2C2C38);
  static const Color lightBorder = Color(0xFFE5E5EE);

  // Text Colors
  static const Color darkTextPrimary = Color(0xFFEDEDF2);
  static const Color darkTextSecondary = Color(0xFF8E8E9E);
  static const Color darkTextMuted = Color(0xFF5A5A6E);

  static const Color lightTextPrimary = Color(0xFF1B1B24);
  static const Color lightTextSecondary = Color(0xFF6B6B7B);
  static const Color lightTextMuted = Color(0xFF9B9BAA);

  // Status & Feedback
  static const Color success = Color(0xFF4E9E6F);
  static const Color warning = Color(0xFFD49B42);
  static const Color error = Color(0xFFD9534F);
}