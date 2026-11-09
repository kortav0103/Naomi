import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Bộ điều khiển chủ đề giao diện (Sáng / Tối AMOLED / Hệ thống) và ngôn ngữ đọc mặc định (FR-14, NFR-16)
class ThemeController extends ChangeNotifier {
  final FlutterSecureStorage? secureStorage;

  static const String _keyThemeMode = 'naomi_theme_mode';
  static const String _keyPreferredLanguage = 'naomi_preferred_language';

  ThemeMode _themeMode = ThemeMode.dark;
  String _preferredLanguage = 'en'; // English only ('en')
  int _mainNavIndex = 0;
  int _libraryTabIndex = 0;

  ThemeController({this.secureStorage});

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  String get preferredLanguage => _preferredLanguage;
  int get mainNavIndex => _mainNavIndex;
  int get libraryTabIndex => _libraryTabIndex;

  /// Nạp các tùy chọn đã lưu từ bộ nhớ cục bộ
  Future<void> loadPreferences() async {
    if (secureStorage == null) return;
    try {
      final savedTheme = await secureStorage!.read(key: _keyThemeMode);
      if (savedTheme != null) {
        if (savedTheme == 'light') {
          _themeMode = ThemeMode.light;
        } else if (savedTheme == 'dark') {
          _themeMode = ThemeMode.dark;
        } else if (savedTheme == 'system') {
          _themeMode = ThemeMode.system;
        }
      }

      _preferredLanguage = 'en';
      notifyListeners();
    } catch (_) {}
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
      secureStorage?.write(key: _keyThemeMode, value: mode.name);
    }
  }

  void toggleDarkMode(bool isDark) {
    setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  void setPreferredLanguage(String lang) {
    const enforcedLang = 'en';
    if (_preferredLanguage != enforcedLang) {
      _preferredLanguage = enforcedLang;
      notifyListeners();
    }
    secureStorage?.write(key: _keyPreferredLanguage, value: enforcedLang);
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
