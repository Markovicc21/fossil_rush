import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'shop_screen.dart';
import 'profile_screen.dart';
import 'scoreboard_screen.dart';
import 'login_screen.dart';
import '../widgets/image_button.dart';

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
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset('assets/images/jurassic.jpg', fit: BoxFit.cover),
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 10, right: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  //PROFILE DUGME
                  imageButton(
                    asset: 'assets/images/PROFILE.png',
                    width: 110,
                    height: 50,
                    onPressed: () {
                      Navigator.pushNamed(context, ProfileScreen.routeName);
                    },
                  ),
                  //LOGOUT DUGME
                  imageButton(
                    asset: 'assets/images/EXIT.png',
                    width: 55,
                    height: 50,
                    onPressed: () {
                      Navigator.pushNamed(context, MainMenuScreen.routeName);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/logo.png', width: 300, height: 300),
                const SizedBox(height: 28),

                //PLAY DUGME
                imageButton(
                  asset: 'assets/images/PLAY.png',
                  width: 260,
                  onPressed: () {
                    Navigator.pushNamed(context, GameScreen.routeName);
                  },
                ),

                //SHOP DUGME
                imageButton(
                  asset: 'assets/images/SHOP.png',
                  width: 260,
                  onPressed: () {
                    Navigator.pushNamed(context, ShopScreen.routeName);
                  },
                ),

                //SCOREBOARD DUGME
                imageButton(
                  asset: 'assets/images/SCORE.png',
                  width: 260,
                  onPressed: () {
                    Navigator.pushNamed(context, ScoreboardScreen.routeName);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
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
                Image.asset('assets/images/logo.png', width: 300, height: 300),

                const SizedBox(height: 28),

                //PLAY DUGME
                imageButton(
                  asset: 'assets/images/PLAY.png',
                  width: 260,
                  onPressed: () {
                    Navigator.pushNamed(context, GameScreen.routeName);
                  },
                ),

                //LOGIN DUGME
                imageButton(
                  asset: 'assets/images/LOGIN.png',
                  width: 260,
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

  /*
  Widget _retroButton({
    required String text,
    required Color color,
    required VoidCallback onPressed,
    Color borderColor = const Color(0xFF2A1A12),
    Color textColor = const Color(0xFF2A1A12),
    double width = 220,
    double verticalPadding = 14,
    double fontSize = 12,
  }) {
    bool isPressed = false;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: StatefulBuilder(
        builder: (context, setState) {
          void setPressed(bool v) => setState(() => isPressed = v);

          return GestureDetector(
            onTap: onPressed,
            onTapDown: (_) => setPressed(true),
            onTapUp: (_) => setPressed(false),
            onTapCancel: () => setPressed(false),

            child: AnimatedContainer(
              duration: const Duration(milliseconds: 90),
              curve: Curves.easeOut,
              transform: Matrix4.translationValues(0, isPressed ? 3 : 0, 0),
              width: width,
              padding: EdgeInsets.symmetric(vertical: verticalPadding),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.zero,
                border: Border.all(color: borderColor, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(1),
                    offset: Offset(0, isPressed ? 1 : 4),
                    blurRadius: 0,
                  ),
                ],
              ),

              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: fontSize,
                    color: textColor,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    height: 1.0,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
*/
}
