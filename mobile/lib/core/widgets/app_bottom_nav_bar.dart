import 'package:flutter/material.dart';

class AppNavItem {
  final IconData icon;
  final String label;
  const AppNavItem({required this.icon, required this.label});
}

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final List<AppNavItem> items;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      backgroundColor: theme.colorScheme.surface,
      indicatorColor: theme.colorScheme.primaryContainer,
      destinations: items.map((item) {
        return NavigationDestination(
          icon: Icon(item.icon, size: 28),
          selectedIcon: Icon(item.icon, size: 28, color: theme.colorScheme.onPrimaryContainer),
          label: item.label,
        );
      }).toList(),
    );
  }
}
