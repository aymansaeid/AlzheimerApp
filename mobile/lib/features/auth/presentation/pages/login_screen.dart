import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Login Screen Placeholder'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.goNamed('patient_dashboard'),
              child: const Text('Go to Patient Dashboard'),
            ),
            ElevatedButton(
              onPressed: () => context.goNamed('caregiver_dashboard'),
              child: const Text('Go to Caregiver Dashboard'),
            ),
            ElevatedButton(
              onPressed: () => context.goNamed('register'),
              child: const Text('Go to Register'),
            ),
          ],
        ),
      ),
    );
  }
}
