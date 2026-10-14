import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/auth/login_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  await AuthService().initialize();
  runApp(const WillowApp());
}

class WillowApp extends StatelessWidget {
  const WillowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Willow - Food Safety Scanner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: ListenableBuilder(
        listenable: AuthService(),
        builder: (context, _) {
          if (AuthService().isAuthenticated) {
            return const MainNavigationScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
