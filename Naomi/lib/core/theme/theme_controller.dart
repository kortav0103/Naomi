import 'package:flutter/material.dart';

/// Bộ điều khiển chủ đề giao diện (Sáng / Tối AMOLED / Hệ thống) và ngôn ngữ đọc mặc định (FR-14, NFR-16)
class ThemeController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  String _preferredLanguage = 'all'; // 'all', 'vi', 'en'
  int _mainNavIndex = 0;
  int _libraryTabIndex = 0;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  String get preferredLanguage => _preferredLanguage;
  int get mainNavIndex => _mainNavIndex;
  int get libraryTabIndex => _libraryTabIndex;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }

  void toggleDarkMode(bool isDark) {
    setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  void setPreferredLanguage(String lang) {
    if (_preferredLanguage != lang) {
      _preferredLanguage = lang;
      notifyListeners();
    }
  }

  /// Điều hướng nhanh về Tủ sách Ngoại tuyến khi mất mạng (FR-13 - S09 -> S07)
  void navigateToOfflineLibrary() {
    _mainNavIndex = 1;
    _libraryTabIndex = 2; // Tab 3: Đã tải (Offline)
    notifyListeners();
  }

  void setMainNavIndex(int index) {
    if (_mainNavIndex != index) {
      _mainNavIndex = index;
      notifyListeners();
    }
  }

  void setLibraryTabIndex(int index) {
    if (_libraryTabIndex != index) {
      _libraryTabIndex = index;
      notifyListeners();
    }
  }
}
