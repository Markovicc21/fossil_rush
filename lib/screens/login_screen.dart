import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';
import 'main_menu_screen.dart';
import '../widgets/image_button.dart';
import '../widgets/pixelInput.dart';
import '../widgets/back_button.dart';
import '../widgets/screen_slider.dart';
import '../widgets/retro_panel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/jurassic.jpg', fit: BoxFit.cover),
          ),

          //BACK BUTTON
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: 46,
                height: 46,
                child: RetroPanel(
                  fill: const Color(0xFF8B5A3C),
                  padding: const EdgeInsets.all(6),
                  shadowOffset: 2,

                  child: Center(
                    child: AppBackButton(
                      asset: 'assets/images/ARROW_BACK.png',
                      width: 18,
                      height: 18,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
              ),
            ),
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
          pixelInput(hint: 'Enter Username', controller: _usernameCtrl),
          const SizedBox(height: 10),
          //PASSWORD
          pixelInput(
            hint: 'Enter Password',
            obscure: true,
            controller: _passwordCtrl,
          ),

          const SizedBox(height: 15),

          TextButton(
            onPressed: () {
              Navigator.of(
                context,
              ).push(ScreenSlider.slide(const RegisterScreen()));
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
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);

              final username = _usernameCtrl.text.trim();
              final password = _passwordCtrl.text;

              if (username.isEmpty || password.isEmpty) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Invalid username or password!'),
                  ),
                );
                return;
              }

              final res = await AuthService.repo.login(
                username: username,
                password: password,
              );

              if (!mounted) return;

              if (!res.ok) {
                messenger.showSnackBar(
                  SnackBar(content: Text(res.message ?? 'Login failed')),
                );
                return;
              }

              Navigator.of(context).push(
                ScreenSlider.slide(const MainMenuScreen(isLoggedin: true)),
              );
            },
          ),
        ],
      ),
    );
  }
}
