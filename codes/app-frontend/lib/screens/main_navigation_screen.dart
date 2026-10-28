import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'scan_screen.dart';
import 'history_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(
            onGoToScan: () => _onTabSelected(1),
            onGoToHistory: () => _onTabSelected(2),
          ),
          ScanScreen(
            onBackToHome: () => _onTabSelected(0),
          ),
          const HistoryScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppTheme.borderLight, width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      index: 0,
                      icon: Icons.home_rounded,
                      label: 'Home',
                    ),
                    _buildNavItem(
                      index: 1,
                      icon: Icons.qr_code_scanner_rounded,
                      label: 'Scan',
                    ),
                    _buildNavItem(
                      index: 2,
                      icon: Icons.access_time_rounded,
                      label: 'History',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Home indicator from Figma (#2:2231 / #2:2146)
                Container(
                  width: 128,
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: AppTheme.filterActiveGradient,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onTabSelected(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Figma #2:2228 / layout_fa7c620e: 54x30 capsule
          Container(
            width: 54,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: isActive ? AppTheme.navActivePillGradient : null,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isActive ? AppTheme.primaryPurple : AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? AppTheme.primaryPurple : AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
