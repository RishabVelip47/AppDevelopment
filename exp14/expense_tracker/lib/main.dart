// Complete main.dart with Onboarding Screen

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import your screens
import 'package:expense_tracker/getting_started.dart';
import 'package:expense_tracker/screens/auth/login.dart';
import 'package:expense_tracker/screens/home/user_home.dart';
import 'package:expense_tracker/screens/home/vip_home.dart';
import 'package:expense_tracker/screens/home/guest_home.dart';
import 'package:expense_tracker/screens/admin/admin_dashboard.dart';
import 'package:expense_tracker/screens/admin/admin_login.dart';
import 'package:expense_tracker/screens/currency_screen.dart';
import 'package:expense_tracker/screens/currency_comparison_screen.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SplashWrapper(), // Start with splash/onboarding check
      routes: {
        '/getting-started': (context) => const GettingStartedPage(),
        '/login': (context) => const LoginPage(),
        '/userHome': (context) => const UserHome(),
        '/vipHome': (context) => const VipHome(),
        '/guestHome': (context) => const GuestHome(),
          '/adminLogin': (context) => AdminLoginPage(),
        '/admin': (context) => const AdminDashboard(),
        
      },
    );
  }
}

// Splash Wrapper - Checks if user has seen onboarding
class SplashWrapper extends StatefulWidget {
  const SplashWrapper({super.key});

  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    // Wait a bit for splash effect
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    if (!mounted) return;

    if (!hasSeenOnboarding) {
      // First time - show onboarding
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const GettingStartedPage()),
      );
    } else {
      // Not first time - go to auth wrapper
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade900,
              Colors.blue.shade700,
              Colors.blue.shade500,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  size: 80,
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Expense Tracker',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Manage your finances smartly',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Auth Wrapper to handle routing based on user type
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // User not logged in
        if (!snapshot.hasData || snapshot.data == null) {
          return const LoginPage();
        }

        final user = snapshot.data!;

        // Anonymous user (Guest)
        if (user.isAnonymous) {
          return const GuestHome();
        }

        // Logged in user - Check role from Firestore
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              // User document doesn't exist, go to login
              return const LoginPage();
            }

            final userData = userSnapshot.data!.data() as Map<String, dynamic>?;

            if (userData == null) {
              return const LoginPage();
            }

            // Check if user is admin
            final isAdmin = userData['isAdmin'] ?? false;
            if (isAdmin) {
              return const AdminDashboard();
            }

            // Check if user is VIP
            final isVip = userData['isVip'] ?? false;
            if (isVip) {
              return const VipHome();
            }

            // Regular user
            return const UserHome();
          },
        );
      },
    );
  }
}
// ------------------ EXTRA DRAWER FOR CURRENCY SCREENS ------------------

class AppMenuDrawer extends StatelessWidget {
  const AppMenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              "Menu",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),

          // In your main.dart or home_screen.dart
          ListTile(
            leading: const Icon(Icons.currency_exchange),
            title: const Text('Currency Exchange'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CurrencyScreen(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.compare_arrows),
            title: const Text('Compare Currencies'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CurrencyComparisonScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}