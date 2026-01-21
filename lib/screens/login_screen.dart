import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'main_menu_screen.dart';
import '../widgets/image_button.dart';
import '../widgets/pixelInput.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const routeName = '/login';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/jurassic.jpg', fit: BoxFit.cover),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _loginBox(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _loginBox(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF8B5A3C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF8B5A3C), width: 3),
        boxShadow: const [
          BoxShadow(offset: Offset(4, 4), color: Color(0xFF2A1A12)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          //NASLOV
          const Text(
            'LOGIN',
            style: TextStyle(
              fontSize: 22,
              color: Color(0xFFFFE7C2),
              shadows: [Shadow(offset: Offset(2, 2), color: Color(0xFF2A1A12))],
            ),
          ),
          const SizedBox(height: 16),

          //USERNAME
          pixelInput(hint: 'Enter Username'),
          const SizedBox(height: 10),
          //PASSWORD
          pixelInput(hint: 'Enter Password', obscure: true),

          const SizedBox(height: 15),

          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, RegisterScreen.routeName);
            },
            child: const Text(
              'Register now!',
              style: TextStyle(color: Color(0xFF4E2A14), fontSize: 12),
            ),
          ),

          const SizedBox(height: 1),
          //LOGIN DUGME
          imageButton(
            asset: 'assets/images/LOG_IN.png',
            width: 200,
            height: 80,
            onPressed: () {
              Navigator.pushNamed(context, MainMenuScreen.loggedRouteName);
            },
          ),
        ],
      ),
    );
  }
}
