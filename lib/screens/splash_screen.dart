import 'package:flutter/material.dart';
import '../widgets/app_button.dart';
import 'login_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  static const routeName = '/splash';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo.png', width: 300, height: 300),
              const SizedBox(height: 16),

              const SizedBox(height: 12),

              const SizedBox(height: 24),
              AppButton(
                label: 'Continue',
                onPressed: () {
                  Navigator.pushReplacementNamed(
                    context,
                    LoginScreen.routeName,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
