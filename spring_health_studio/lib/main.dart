import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';
import 'screens/auth/login_screen.dart';
import 'screens/owner/owner_dashboard.dart';
import 'screens/receptionist/receptionist_dashboard.dart';
import 'screens/trainer/trainer_dashboard_screen.dart';
import 'screens/members/add_member_screen.dart';
import 'services/firestore_service.dart';
import 'models/user_model.dart';

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
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/login': (context) => const LoginScreen(),
        '/owner-dashboard': (context) => const OwnerDashboard(),
        '/receptionist-dashboard': (context) => const ReceptionistDashboard(),

        '/add-member': (context) => const AddMemberScreen(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/add-member':
            return MaterialPageRoute(builder: (_) => const AddMemberScreen());
          default:
            return null;
        }
      },
    );
  }
}

/// AuthWrapper — persists Firebase session across app restarts.
///
/// Architecture notes:
/// - StatefulWidget caches the role Future so it is not re-fetched on every
///   authStateChanges() emission (which happens several times per session).
/// - authStateChanges() emits null briefly on cold start BEFORE Firebase
///   restores the persisted local session. We guard against this by checking
///   FirebaseAuth.instance.currentUser synchronously — if a cached user exists
///   we hold a loading screen instead of bouncing to LoginScreen.
/// - ConnectionState.waiting covers the period before the first stream event.
///   Together the two guards eliminate the false-logout-on-restart bug.
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  String? _cachedUid;
  Future<Map<String, dynamic>>? _roleFuture;

  /// Returns a cached role future.
  /// Only calls Firestore again if the UID changes (e.g. different account).
  Future<Map<String, dynamic>> _getRoleFuture(String uid) {
    if (_cachedUid != uid || _roleFuture == null) {
      _cachedUid = uid;
      _roleFuture = FirestoreService().getUserRole(uid);
    }
    return _roleFuture!;
  }

  Widget _loadingScreen([String? message]) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.turquoise),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _errorScreen(String message) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                         size: 64, color: AppColors.error),
                        const SizedBox(height: 16),
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textPrimary, fontSize: 15),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.turquoise,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Logout and Retry'),
                        ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleNotFoundScreen(String uid) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber_rounded,
                         size: 64, color: MyApp.warmYellow),
                        const SizedBox(height: 16),
                        const Text(
                          'User role not assigned.',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Ask the administrator to assign your role in the system.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'UID: $uid',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.turquoise,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Logout'),
                        ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _accountNotConfiguredScreen(User user) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_off_outlined,
                         size: 64, color: MyApp.warmYellow),
                        const SizedBox(height: 16),
                        const Text(
                          'Account not configured',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Please contact your administrator to complete account setup.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Email: ${user.email ?? 'Unknown'}',
                          style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12),
                        ),
                        Text(
                          'UID: ${user.uid}',
                          style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 11),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.turquoise,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Logout'),
                        ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        // GUARD 1: Stream has not emitted yet — show loading.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loadingScreen();
        }

        // GUARD 2: Stream emitted null — check local cache first.
        // Firebase emits null briefly on cold start before the persisted
        // session token is restored from disk. currentUser is synchronous
        // and reflects the locally-cached state immediately.
        if (!snapshot.hasData || snapshot.data == null) {
          final cachedUser = FirebaseAuth.instance.currentUser;
          if (cachedUser != null) {
            // Session is being restored — hold on loading screen.
            return _loadingScreen('Restoring session...');
          }
          // Genuinely signed out — show login.
          return const LoginScreen();
        }

        // User confirmed authenticated — fetch role (cached after first load).
        final user = snapshot.data!;
        return FutureBuilder<Map<String, dynamic>>(
          future: _getRoleFuture(user.uid),
          builder: (context, roleSnapshot) {

            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return _loadingScreen('Loading your workspace...');
            }

            if (roleSnapshot.hasError) {
              return _errorScreen(
                'Could not load user data.\n${roleSnapshot.error}',
              );
            }

            final userData = roleSnapshot.data;
            if (userData == null || userData.isEmpty) {
              return _accountNotConfiguredScreen(user);
            }

            final role = userData['role'] as String?;

            if (role == null) {
              return _roleNotFoundScreen(user.uid);
            }

            // Role values in Firestore users collection are Title Case:
            // Owner | Receptionist | Trainer
            switch (role) {
              case 'Owner':
                return const OwnerDashboard();
              case 'Receptionist':
                return const ReceptionistDashboard();
              case 'Trainer':
                return TrainerDashboardScreen(
                  user: UserModel.fromMap(userData, user.uid),
                );
              default:
                return _errorScreen('Unknown role: $role');
            }
          },
        );
      },
    );
  }
}
