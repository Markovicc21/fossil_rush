import 'package:flutter/material.dart';

import '../widgets/app_button.dart';
import 'register_screen.dart';
import 'main_menu_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const routeName = '/login';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const TextField(decoration: InputDecoration(labelText: 'Email')),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 32),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, RegisterScreen.routeName);
              },
              child: const Text("Don't have an account? Register now"),
            ),
            AppButton(
              label: 'Log in',
              onPressed: () {
                Navigator.pushNamed(context, MainMenuScreen.routeName);
              },
            ),
          ],
        ),
      ),
    );
  }
}
