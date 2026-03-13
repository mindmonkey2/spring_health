import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';
import 'screens/auth/login_screen.dart';
import 'screens/owner/owner_dashboard.dart';
import 'screens/receptionist/receptionist_dashboard.dart';
import 'screens/members/add_member_screen.dart';
import 'services/firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Legacy color references for backward compatibility
  static const Color sageGreen = AppColors.success;
  static const Color tealAqua = AppColors.turquoise;
  static const Color navyBlue = AppColors.textPrimary;
  static const Color warmYellow = AppColors.warning;
  static const Color lightBackground = AppColors.background;
  static const Color darkText = AppColors.textPrimary;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spring Health Studio',
      debugShowCheckedModeBanner: false,
      // Using centralized theme system
      theme: AppTheme.lightTheme,
      // Routes
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/login': (context) => const LoginScreen(),
        '/owner-dashboard': (context) => const OwnerDashboard(),
        '/receptionist-dashboard': (context) => const ReceptionistDashboard(),
        '/add-member': (context) => const AddMemberScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/login') {
          return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
        if (settings.name == '/add-member') {
          return MaterialPageRoute(builder: (_) => const AddMemberScreen());
        }
        return null;
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return FutureBuilder<Map<String, dynamic>>(
            future: FirestoreService().getUserRole(snapshot.data!.uid),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading user data...'),
                      ],
                    ),
                  ),
                );
              }

              if (roleSnapshot.hasError) {
                return Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${roleSnapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                          },
                          child: const Text('Logout and Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (roleSnapshot.hasData && roleSnapshot.data!.isNotEmpty) {
                final userData = roleSnapshot.data!;
                final role = userData['role'] as String?;

                if (role == null) {
                  return Scaffold(
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.warning, size: 64, color: MyApp.warmYellow),
                          const SizedBox(height: 16),
                          const Text('User role not found'),
                          const SizedBox(height: 8),
                          Text('UID: ${snapshot.data!.uid}'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                            },
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (role == 'Owner') {
                  return const OwnerDashboard();
                } else if (role == 'Receptionist') {
                  return const ReceptionistDashboard();
                } else {
                  return Scaffold(
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text('Unknown role: $role'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                            },
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              }

              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person_off, size: 64, color: MyApp.warmYellow),
                      const SizedBox(height: 16),
                      const Text('User account not configured'),
                      const SizedBox(height: 8),
                      Text('Email: ${snapshot.data!.email}'),
                      Text('UID: ${snapshot.data!.uid}'),
                      const SizedBox(height: 16),
                      const Text(
                        'Please contact administrator to set up your account',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                        },
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }

        return const LoginScreen();
      },
    );
  }
}
