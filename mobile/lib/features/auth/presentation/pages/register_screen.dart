import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Register Screen Placeholder'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.goNamed('login'),
              child: const Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }
}
