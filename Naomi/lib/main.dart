import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection_container.dart' as di;
import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'features/comic/presentation/bloc/discover/discover_bloc.dart';
import 'features/comic/presentation/screens/discover_screen.dart';

void main() async {
  // Đảm bảo Flutter Engine đã sẵn sàng trước khi nạp Database/Services
  WidgetsFlutterBinding.ensureInitialized();

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
      home: BlocProvider(
        create: (_) => sl<DiscoverBloc>(),
        child: const DiscoverScreen(),
      ),
    );
  }
}
