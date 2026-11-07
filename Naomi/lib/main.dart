import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'core/di/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'core/widgets/mobile_simulator_wrapper.dart';
import 'features/auth/presentation/screens/login_screen.dart';

void main() async {
  // Đảm bảo Flutter Engine đã sẵn sàng trước khi nạp Database/Services
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo SQLite FFI khi chạy trên môi trường Desktop (Windows / macOS / Linux)
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Khởi tạo Dependency Injection (Hạ tầng mạng, CSDL SQLite, Secure Storage, MangaDex)
  await di.init();

  runApp(const NaomiApp());
}

class NaomiApp extends StatelessWidget {
  const NaomiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = di.sl<ThemeController>();

    return ListenableBuilder(
      listenable: themeController,
      builder: (context, _) {
        return MaterialApp(
          title: 'Naomi',
          debugShowCheckedModeBanner: false,
          scrollBehavior: const MobileTouchScrollBehavior(),
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeController.themeMode,
          builder: (context, child) {
            return MobileSimulatorWrapper(
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: const LoginScreen(),
        );
      },
    );
  }
}
