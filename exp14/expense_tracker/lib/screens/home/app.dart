import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/login.dart';
import 'guest_home.dart';
import 'user_home.dart';
import 'vip_home.dart';

// This widget checks authentication and routes to appropriate home page
class AppHome extends StatelessWidget {
  const AppHome({super.key});

  Future<String> _getUserType(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      
      if (!doc.exists) return 'guest';
      
      final data = doc.data();
      if (data != null && data['isVip'] == true) {
        return 'vip';
      }
      return 'user';
    } catch (e) {
      return 'guest';
    }
  }

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

        // No user logged in - redirect to login
        if (!snapshot.hasData || snapshot.data == null) {
          return const LoginPage();
        }

        final user = snapshot.data!;

        // Check if user is anonymous (guest)
        if (user.isAnonymous) {
          return const GuestHome();
        }

        // Check user type from Firestore for regular users
        return FutureBuilder<String>(
          future: _getUserType(user.uid),
          builder: (context, userTypeSnapshot) {
            if (userTypeSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final userType = userTypeSnapshot.data ?? 'user';

            // Route based on user type
            switch (userType) {
              case 'vip':
                return const VipHome();
              case 'user':
                return const UserHome();
              default:
                return const GuestHome();
            }
          },
        );
      },
    );
  }
}