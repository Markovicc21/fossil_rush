import 'package:flutter/material.dart';
import '../widgets/app_button.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  static const routeName = '/register';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const TextField(decoration: InputDecoration(labelText: 'Username')),
            const SizedBox(height: 12),
            const TextField(decoration: InputDecoration(labelText: 'Password')),
            const SizedBox(height: 24),
            AppButton(
              label: 'Create Account',
              onPressed: () {
                Navigator.pushNamed(context, '/main-menu-logged');
              },
            ),
          ],
        ),
      ),
    );
  }
}
