import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'scan_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeScreen(onGoToHistory: () => _onTabSelected(2)),
      const ScanScreen(),
      const HistoryScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: Color(0xFFEFEFF3), width: 1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_outlined, Icons.home_rounded, "Home"),
                _buildScanNavItem(1),
                _buildNavItem(2, Icons.history_rounded, Icons.history_rounded, "History"),
                _buildNavItem(3, Icons.person_outline_rounded, Icons.person_rounded, "Profile"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData inactiveIcon,
    IconData activeIcon,
    String label,
  ) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onTabSelected(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? activeIcon : inactiveIcon,
            color: isSelected ? AppTheme.primaryPink : const Color(0xFFB0B0BB),
            size: 24,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppTheme.primaryPink : const Color(0xFFB0B0BB),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanNavItem(int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onTabSelected(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.pinkGradient : null,
          color: isSelected ? null : const Color(0xFFF5F5FA),
          borderRadius: BorderRadius.circular(26),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryPink.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.document_scanner_rounded,
              color: isSelected ? Colors.white : AppTheme.textPrimary,
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              "Scan",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
