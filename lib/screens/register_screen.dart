import 'package:flutter/material.dart';
import 'package:fossil_rush/screens/main_menu_screen.dart';
import 'package:fossil_rush/widgets/image_button.dart';
import 'package:fossil_rush/widgets/pixelInput.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  static const routeName = '/register';

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
              child: _registerBox(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _registerBox(BuildContext context) {
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
            'REGISTER',
            style: TextStyle(
              fontSize: 22,
              color: Color(0xFFFFE7C2),
              shadows: [Shadow(offset: Offset(2, 2), color: Color(0xFF2A1A12))],
            ),
          ),

          const SizedBox(height: 16),
          //USERNAME
          pixelInput(hint: 'Create Username'),
          const SizedBox(height: 10),
          //PASSWORD
          pixelInput(hint: 'Create Password', obscure: true),
          const SizedBox(height: 10),
          //CONFIRM PASSWORD
          pixelInput(hint: 'Confirm Password', obscure: true),

          const SizedBox(height: 10),

          imageButton(
            asset: 'assets/images/REGISTER.png',
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
