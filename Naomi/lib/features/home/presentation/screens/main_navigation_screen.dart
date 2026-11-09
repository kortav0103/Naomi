import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/theme_context_extension.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../comic/presentation/bloc/discover/discover_bloc.dart';
import '../../../comic/presentation/screens/discover_screen.dart';
import '../../../library/presentation/screens/library_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../widgets/floating_mini_player.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final ThemeController _themeController = sl<ThemeController>();

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
    return ListenableBuilder(
      listenable: _themeController,
      builder: (context, _) {
        final currentIndex = _themeController.mainNavIndex;

        return Scaffold(
          backgroundColor: context.backgroundColor,
          body: IndexedStack(
            index: currentIndex,
            children: _screens,
          ),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mini Player nổi toàn cục phát nhạc nền Ambient (FR-05 & FR-09)
              const FloatingMiniPlayer(),
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: context.borderColor, width: 1),
                  ),
                ),
                child: NavigationBar(
                  selectedIndex: currentIndex,
                  elevation: 0,
                  onDestinationSelected: (index) {
                    _themeController.setMainNavIndex(index);
                  },
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.explore_outlined),
                      selectedIcon: Icon(Icons.explore_rounded),
                      label: 'Discover',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.bookmark_border_rounded),
                      selectedIcon: Icon(Icons.bookmark_rounded),
                      label: 'Library',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings_rounded),
                      label: 'Settings',
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
