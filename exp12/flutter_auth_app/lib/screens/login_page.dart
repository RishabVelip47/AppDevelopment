import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'dashboard_page.dart';
import 'phone_auth_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _auth = AuthService();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool showPassword = false;
  bool isLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E1E2C), Color(0xFF232D3F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Welcome",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.tealAccent,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isLogin ? "Login to continue" : "Create your account",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.email, color: Colors.tealAccent),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.tealAccent),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: passwordController,
                    obscureText: !showPassword,
                    keyboardType: TextInputType.visiblePassword,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.lock, color: Colors.tealAccent),
                      suffixIcon: IconButton(
                        icon: Icon(
                          showPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() => showPassword = !showPassword);
                        },
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.tealAccent),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.tealAccent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () async {
                      if (!mounted) return;
                      try {
                        if (isLogin) {
                          await _auth.login(
                              emailController.text.trim(), passwordController.text.trim());
                        } else {
                          await _auth.signUp(
                              emailController.text.trim(), passwordController.text.trim());
                        }
                        if (!mounted) return;
                        Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (_) => const DashboardPage()));
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString().replaceAll('Exception: ', '')),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: Text(isLogin ? "Login" : "Sign Up"),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () =>
                        setState(() => isLogin = !isLogin),
                    child: Text(
                      isLogin
                          ? "Don't have an account? Sign Up"
                          : "Already have an account? Login",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    icon: const Icon(Icons.login),
                    onPressed: () async {
                      if (!mounted) return;
                      try {
                        await _auth.signInWithGoogle();
                        if (!mounted) return;
                        Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (_) => const DashboardPage()));
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString().replaceAll('Exception: ', '')),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    label: const Text("Sign in with Google"),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.tealAccent),
                      foregroundColor: Colors.tealAccent,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    icon: const Icon(Icons.phone),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PhoneAuthPage()),
                      );
                    },
                    label: const Text("Sign in with Phone"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
