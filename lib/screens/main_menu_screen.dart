import 'package:flutter/material.dart';
import 'package:fossil_rush/screens/admin_screen.dart';
import 'package:fossil_rush/widgets/screen_slider.dart';
import 'game_screen.dart';
import 'shop_screen.dart';
import 'profile_screen.dart';
import 'scoreboard_screen.dart';
import 'login_screen.dart';
import 'package:fossil_rush/services/auth/auth_service.dart';
import '../widgets/pixelInput.dart';
import '../widgets/image_button.dart';
import '../widgets/retro_panel.dart';

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
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const GameScreen(isLoggedIn: true),
                      ),
                    );
                  },
                ),

                //SHOP DUGME
                imageButton(
                  asset: 'assets/images/SHOP.png',
                  width: 260,
                  onPressed: () {
                    AuthService.repo.session().then((session) {
                      final userId = session?.userId;
                      if (userId == null || userId.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please login first'),
                          ),
                        );
                        return;
                      }
                      Navigator.of(context).push(
                        ScreenSlider.slide(ShopScreen(userId: userId)),
                      );
                    });
                  },
                ),

                //SCOREBOARD DUGME
                imageButton(
                  asset: 'assets/images/SCORE.png',
                  width: 260,
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).push(ScreenSlider.slide(const ScoreboardScreen()));
                  },
                ),
              ],
            ),
          ),
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
                      Navigator.of(
                        context,
                      ).push(ScreenSlider.slide(const ProfileScreen()));
                    },
                  ),
                  //LOGOUT DUGME
                  imageButton(
                    asset: 'assets/images/EXIT.png',
                    width: 55,
                    height: 50,
                    onPressed: () {
                      Navigator.of(context).push(
                        ScreenSlider.slide(
                          const MainMenuScreen(isLoggedin: false),
                        ),
                      );
                    },
                  ),
                ],
              ),
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
                GestureDetector(
                  onLongPress: () {
                    _showAdminLogin(context);
                  },
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 260,
                    filterQuality: FilterQuality.none,
                  ),
                ),

                const SizedBox(height: 28),

                //PLAY DUGME
                imageButton(
                  asset: 'assets/images/PLAY.png',
                  width: 260,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const GameScreen(isLoggedIn: false),
                      ),
                    );
                  },
                ),

                //LOGIN DUGME
                imageButton(
                  asset: 'assets/images/LOGIN.png',
                  width: 260,
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).push(ScreenSlider.slide(const LoginScreen()));
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showAdminLogin(BuildContext context) async {
    final userController = TextEditingController();
    final passController = TextEditingController();
    String? errorText;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (dialogContext) {
        final size = MediaQuery.of(dialogContext).size;
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 320,
              maxHeight: size.height * 0.6,
            ),
            child: Material(
              color: Colors.transparent,
              child: StatefulBuilder(
                builder: (context, setState) {
                  return RetroPanel(
                    fill: const Color(0xFFF1E9F1),
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'ADMIN LOGIN',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            color: Color(0xFF2A1A12),
                            height: 1.0,
                            shadows: [
                              Shadow(
                                offset: Offset(2, 2),
                                color: Color(0xFFB8A7B8),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 2,
                          color: const Color(0xFF2A1A12).withOpacity(0.35),
                        ),
                        const SizedBox(height: 12),

                        pixelInput(
                          hint: 'Username',
                          controller: userController,
                        ),
                        const SizedBox(height: 10),
                        pixelInput(
                          hint: 'Password',
                          obscure: true,
                          controller: passController,
                        ),

                        if (errorText != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            errorText!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                              height: 1.0,
                            ),
                          ),
                        ],

                        const SizedBox(height: 12),
                        Container(
                          height: 2,
                          color: const Color(0xFF2A1A12).withOpacity(0.20),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _retroActionButton(
                              text: 'Cancel',
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(),
                            ),
                            _retroActionButton(
                              text: 'OK',
                              onPressed: () async {
                                final user = userController.text.trim();
                                final pass = passController.text;

                                if (user != 'admin') {
                                  setState(() {
                                    errorText = 'Pogresan admin login';
                                  });
                                  return;
                                }

                                final res = await AuthService.repo.login(
                                  username: user,
                                  password: pass,
                                );

                                if (!res.ok) {
                                  setState(() {
                                    errorText = res.message ??
                                        'Pogresan admin login';
                                  });
                                  return;
                                }

                                Navigator.of(dialogContext).pop();
                                Navigator.pushNamed(
                                  context,
                                  AdminScreen.routeName,
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
    userController.dispose();
    passController.dispose();
  }

  Widget _retroActionButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6A58B6),
            height: 1.0,
            shadows: [Shadow(offset: Offset(1, 1), color: Color(0xFFB8A7B8))],
          ),
        ),
      ),
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
