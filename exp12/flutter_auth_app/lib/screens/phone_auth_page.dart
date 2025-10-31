import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'dashboard_page.dart';

class PhoneAuthPage extends StatefulWidget {
  const PhoneAuthPage({super.key});

  @override
  State<PhoneAuthPage> createState() => _PhoneAuthPageState();
}

class _PhoneAuthPageState extends State<PhoneAuthPage> {
  final AuthService _auth = AuthService();
  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  String? verificationId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Phone Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                  labelText: "Phone Number (+91...)",
                  prefixIcon: Icon(Icons.phone))),
          const SizedBox(height: 10),
          ElevatedButton(
              onPressed: () async {
                await _auth.signInWithPhone(phoneController.text, (verId) {
                  setState(() => verificationId = verId);
                });
              },
              child: const Text("Send OTP")),
          if (verificationId != null) ...[
            const SizedBox(height: 10),
            TextField(
                controller: otpController,
                decoration:
                    const InputDecoration(labelText: "Enter OTP")),
            const SizedBox(height: 10),
            ElevatedButton(
                onPressed: () async {
                  await _auth.verifyOTP(verificationId!, otpController.text);
                  if (mounted) {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const DashboardPage()));
                  }
                },
                child: const Text("Verify & Login")),
          ]
        ]),
      ),
    );
  }
}
