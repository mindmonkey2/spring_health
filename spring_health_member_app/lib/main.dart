import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'screens/splash/splash_screen.dart';
import 'services/notification_service.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ✅ Initialize push notifications
  try {
    await NotificationService().initialize();
    debugPrint('✅ Notification service initialized successfully');
  } catch (e) {
    debugPrint('⚠️ Notification service initialization failed: $e');
    // App continues to work without notifications
  }

  // ✅ FIXED: Brightness.light = white icons, correct for neon dark theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light, // 🔧 was Brightness.dark
      systemNavigationBarColor: Color(0xFF0A0A0A), // 🆕 match backgroundBlack
      systemNavigationBarIconBrightness: Brightness.light, // 🆕 white nav icons
    ),
  );

  runApp(const SpringMemberApp());
}

class SpringMemberApp extends StatelessWidget {
  const SpringMemberApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spring Health',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      navigatorKey: NotificationService.navigatorKey, // 🆕 FCM tap navigation
      home: const SplashScreen(),
    );
  }
}
