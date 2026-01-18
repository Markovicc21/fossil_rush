import 'package:flutter/material.dart';

import '../widgets/app_button.dart';
import 'game_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key, required this.isLoggedin});

  static const routeName = '/main-menu';

  final bool isLoggedin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Main Menu')),
      body: Padding(
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
            if (isLoggedin) ...[
              AppButton(
                label: 'Shop',
                onPressed: () {
                  //kasnije
                },
              ),

              const SizedBox(height: 16),
              AppButton(
                label: 'ScoreBoard',
                onPressed: () {
                  //kasnije
                },
              ),

              const SizedBox(height: 16),
              AppButton(
                label: 'Profile',
                onPressed: () {
                  //kasnije
                },
              ),
            ] else ...[
              const Text(
                'Log in to use game assets',
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
