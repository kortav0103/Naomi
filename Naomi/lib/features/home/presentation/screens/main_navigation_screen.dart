import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../comic/presentation/bloc/discover/discover_bloc.dart';
import '../../../comic/presentation/screens/discover_screen.dart';
import '../../../library/presentation/screens/library_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    BlocProvider(
      create: (_) => sl<DiscoverBloc>(),
      child: const DiscoverScreen(),
    ),
    const LibraryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.darkBorder, width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          backgroundColor: AppColors.darkBackground,
          indicatorColor: AppColors.primary.withValues(alpha: 0.2),
          elevation: 0,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.explore_outlined, color: AppColors.darkTextSecondary),
              selectedIcon: Icon(Icons.explore_rounded, color: AppColors.primaryLight),
              label: 'Khám phá',
            ),
            NavigationDestination(
              icon: Icon(Icons.bookmark_border_rounded, color: AppColors.darkTextSecondary),
              selectedIcon: Icon(Icons.bookmark_rounded, color: AppColors.primaryLight),
              label: 'Tủ sách',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined, color: AppColors.darkTextSecondary),
              selectedIcon: Icon(Icons.settings_rounded, color: AppColors.primaryLight),
              label: 'Cài đặt',
            ),
          ],
        ),
      ),
    );
  }
}
