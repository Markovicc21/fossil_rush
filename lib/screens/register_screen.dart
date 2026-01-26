import 'package:flutter/material.dart';
import 'package:fossil_rush/screens/main_menu_screen.dart';
import 'package:fossil_rush/services/auth_service.dart';
import 'package:fossil_rush/widgets/back_button.dart';
import 'package:fossil_rush/widgets/image_button.dart';
import 'package:fossil_rush/widgets/pixelInput.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  static const routeName = '/register';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _doRegister() async {
    if (_loading) return;
    setState(() => _loading = true);

    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text;
    final confirm = _confirmCtrl.text;

    if (username.isEmpty || password.isEmpty || confirm.isEmpty) {
      setState(() => _loading = false);
      messenger.showSnackBar(const SnackBar(content: Text('Fill all fields!')));
      return;
    }

    final res = await AuthService.repo.register(
      username: username,
      password: password,
      confirmPassword: confirm,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (!res.ok) {
      messenger.showSnackBar(
        SnackBar(content: Text(res.message ?? 'Register failed')),
      );
      return;
    }

    nav.pushNamedAndRemoveUntil(
      MainMenuScreen.loggedRouteName,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          //BACKGROUND
          Positioned.fill(
            child: Image.asset('assets/images/jurassic.jpg', fit: BoxFit.cover),
          ),

          //BACK BUTTON
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                width: 36,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6B48A),
                  border: Border.all(color: const Color(0xFF2A1A12), width: 2),
                ),
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

          //REGISTER BOX
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
          pixelInput(hint: 'Create Username', controller: _usernameCtrl),
          const SizedBox(height: 10),
          //PASSWORD
          pixelInput(
            hint: 'Create Password',
            obscure: true,
            controller: _passwordCtrl,
          ),
          const SizedBox(height: 10),
          //CONFIRM PASSWORD
          pixelInput(
            hint: 'Confirm Password',
            obscure: true,
            controller: _confirmCtrl,
          ),

          const SizedBox(height: 10),

          imageButton(
            asset: 'assets/images/REGISTER.png',
            width: 200,
            height: 80,
            onPressed: _doRegister,
          ),
        ],
      ),
    );
  }
}
