import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final AuthService _auth = AuthService();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: !showPassword,
              decoration: InputDecoration(
                labelText: "Password",
                suffixIcon: IconButton(
                  icon: Icon(
                      showPassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() => showPassword = !showPassword);
                  },
                ),
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
                onPressed: () async {
                  await _auth.signUp(
                      emailController.text.trim(), passwordController.text.trim());
                  if (mounted) {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => const LoginPage()));
                  }
                },
                child: const Text("Sign Up"))
          ],
        ),
      ),
    );
  }
}
