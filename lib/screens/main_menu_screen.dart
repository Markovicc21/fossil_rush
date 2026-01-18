import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../widgets/app_button.dart';
import 'game_screen.dart';
import 'shop_screen.dart';
import 'profile_screen.dart';
import 'scoreboard_screen.dart';
import 'login_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key, required this.isLoggedin});

  static const routeName = '/main-menu';
  static const loggedRouteName = '/main-menu-logged';

  final bool isLoggedin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoggedin ? _buildLoggedIn(context) : _buildLoggedOut(context),
    );
  }

  Widget _buildLoggedIn(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppButton(
            label: 'Play',
            onPressed: () {
              Navigator.pushNamed(context, GameScreen.routeName);
            },
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Shop',
            onPressed: () {
              Navigator.pushNamed(context, ShopScreen.routeName);
            },
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'ScoreBoard',
            onPressed: () {
              Navigator.pushNamed(context, ScoreboardScreen.routeName);
            },
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Profile',
            onPressed: () {
              Navigator.pushNamed(context, ProfileScreen.routeName);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoggedOut(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset('assets/images/jurassic.jpg', fit: BoxFit.cover),
        ),
        SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/logo.png', width: 200, height: 200),
                const SizedBox(height: 28),

                //PLAY DUGME
                _retroButton(
                  text: 'PLAY',
                  color: const Color(0xFFF2A23A),
                  onPressed: () {
                    Navigator.pushNamed(context, GameScreen.routeName);
                  },
                ),

                //LOGIN DUGME
                _retroButton(
                  text: 'LOGIN',
                  color: const Color(0xFFF2A23A),
                  onPressed: () {
                    Navigator.pushNamed(context, LoginScreen.routeName);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _retroButton({
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 220,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF2A1A12), width: 3),
          boxShadow: const [
            BoxShadow(
              offset: Offset(0, 6),
              blurRadius: 0,
              color: Color(0x662A1A12),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: Color(0xFF2A1A12)),
          ),
        ),
      ),
    );
  }
}
