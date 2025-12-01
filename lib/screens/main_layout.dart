import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: CurvedNavigationBar(
        index: _calculateSelectedIndex(context),
        height: 60.0,
        items: const <Widget>[
          Icon(Icons.dashboard_outlined, size: 30, color: Colors.white),
          Icon(Icons.list_alt_outlined, size: 30, color: Colors.white),
          Icon(Icons.pie_chart_outline, size: 30, color: Colors.white),
          Icon(Icons.category_outlined, size: 30, color: Colors.white),
          Icon(Icons.settings_outlined, size: 30, color: Colors.white),
        ],
        color: AppColors.textPrimary, // Black background for nav bar
        buttonBackgroundColor:
            AppColors.primary, // Lime Green for selected item
        backgroundColor:
            Colors.transparent, // Transparent background behind the curve
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        onTap: (index) => _onItemTapped(index, context),
        letIndexChange: (index) => true,
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/transactions')) return 1;
    if (location.startsWith('/reports')) return 2;
    if (location.startsWith('/categories')) return 3;
    if (location.startsWith('/settings')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/transactions');
        break;
      case 2:
        context.go('/reports');
        break;
      case 3:
        context.go('/categories');
        break;
      case 4:
        context.go('/settings');
        break;
    }
  }
}
