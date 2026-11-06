import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'core/di/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/login_screen.dart';

void main() async {
  // Đảm bảo Flutter Engine đã sẵn sàng trước khi nạp Database/Services
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo SQLite FFI khi chạy trên môi trường Desktop (Windows / macOS / Linux)
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
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
    return MaterialApp(
      title: 'Naomi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Mặc định chế độ tối AMOLED theo đặc tả
      home: const LoginScreen(),
    );
  }
}
