import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService auth = AuthService();
    final user = auth.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.signOut();
              if (context.mounted) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const LoginPage()));
              }
            },
          )
        ],
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.deepPurple, Colors.black],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_user,
                  size: 80, color: Colors.tealAccent),
              const SizedBox(height: 20),
              Text(
                "Welcome, ${user?.email ?? user?.phoneNumber ?? 'User'}!",
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              const Text("You are now logged in!",
                  style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }
}
