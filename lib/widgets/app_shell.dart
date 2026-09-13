import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: const Border(top: BorderSide(color: AppColors.stroke)),
          boxShadow: [
            BoxShadow(
              color: AppColors.electric.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          height: 72,
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) => navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          ),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.bolt_outlined, size: 26),
              selectedIcon: Icon(Icons.bolt, color: AppColors.lime, size: 26),
              label: 'Coach',
            ),
            NavigationDestination(
              icon: Icon(Icons.fitness_center_outlined, size: 26),
              selectedIcon:
                  Icon(Icons.fitness_center, color: AppColors.lime, size: 26),
              label: 'Log',
            ),
            NavigationDestination(
              icon: Icon(Icons.health_and_safety_outlined, size: 26),
              selectedIcon: Icon(
                Icons.health_and_safety,
                color: AppColors.lime,
                size: 26,
              ),
              label: 'Rehab',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline, size: 26),
              selectedIcon: Icon(Icons.person, color: AppColors.lime, size: 26),
              label: 'You',
            ),
          ],
        ),
      ),
    );
  }
}
