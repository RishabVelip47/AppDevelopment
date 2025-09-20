import 'package:flutter/material.dart';

void main() {
  runApp(const RegistrationApp());
}

class RegistrationApp extends StatelessWidget {
  const RegistrationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registration Form',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const RegistrationForm(),
    );
  }
}

class RegistrationForm extends StatefulWidget {
  const RegistrationForm({super.key});

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String gender = "Male";
  String country = "India";

  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideIn;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800));

    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideIn =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: FadeTransition(
            opacity: _fadeIn,
            child: SlideTransition(
              position: _slideIn,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text(
                      "Registration Form",
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    // Name
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: "Full Name", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),

                    // Email
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: "Email", border: OutlineInputBorder()),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    // Phone
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: "Phone Number",
                          border: OutlineInputBorder()),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),

                    // Password
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: "Password", border: OutlineInputBorder()),
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),

                    // Confirm Password
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: "Confirm Password",
                          border: OutlineInputBorder()),
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),

                    // Gender radio buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text("Gender: "),
                        Radio<String>(
                          value: "Male",
                          groupValue: gender,
                          onChanged: (value) =>
                              setState(() => gender = value!),
                        ),
                        const Text("Male"),
                        Radio<String>(
                          value: "Female",
                          groupValue: gender,
                          onChanged: (value) =>
                              setState(() => gender = value!),
                        ),
                        const Text("Female"),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: country,
                      decoration: const InputDecoration(
                          labelText: "Country", border: OutlineInputBorder()),
                      items: ["India", "USA", "UK", "Japan", "Canada"]
                          .map((c) => DropdownMenuItem(
                              value: c, child: Text(c)))
                          .toList(),
                      onChanged: (value) => setState(() => country = value!),
                    ),
                    const SizedBox(height: 20),

                    // Submit Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50)),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Form Submitted")),
                          );
                        }
                      },
                      child: const Text("Sign Up"),
                    ),
                    const SizedBox(height: 16),

                    // Footer text
                    GestureDetector(
                      onTap: () {},
                      child: const Text.rich(
                        TextSpan(
                          text: "Already have an account? ",
                          children: [
                            TextSpan(
                              text: "Log In",
                              style: TextStyle(color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
