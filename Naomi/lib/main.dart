import 'package:flutter/material.dart';
import 'core/di/injection_container.dart' as di;
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';

void main() async {
  // Đảm bảo Flutter Engine đã sẵn sàng trước khi nạp Database/Services
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Dependency Injection (Hạ tầng mạng, CSDL SQLite, Secure Storage)
  await di.init();

  runApp(const NaomiApp());
}

class NaomiApp extends StatelessWidget {
  const NaomiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Naomi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Mặc định chế độ tối AMOLED theo đặc tả
      home: const SplashScreen(),
    );
  }
}

/// Màn hình khởi động tạm thời để xác nhận hệ sinh thái Core đã hoạt động
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                size: 44,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'NAOMI',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: 4,
                color: AppColors.darkTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ambient Manga Reader & Tracker',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.darkTextSecondary,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.darkBorder),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded, size: 16, color: AppColors.success),
                  SizedBox(width: 8),
                  Text(
                    'Core Infrastructure Ready',
                    style: TextStyle(fontSize: 12, color: AppColors.darkTextPrimary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}