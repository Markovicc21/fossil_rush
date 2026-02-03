import 'package:flutter/material.dart';
import '../game/dino_run.dart';
import '../screens/main_menu_screen.dart';
import '../widgets/retro_panel.dart';

class GameOverOverlay extends StatelessWidget {
  final DinoRun game;
  final bool startedLoggedIn;
  const GameOverOverlay({
    super.key,
    required this.game,
    required this.startedLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 260),
        child: RetroPanel(
          fill: const Color(0xFFA56A43),
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'GAME OVER',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  color: Color(0xFFFFE7C2),
                  height: 1.0,
                  shadows: [
                    Shadow(offset: Offset(2, 2), color: Color(0xFF2A1A12)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 2,
                color: const Color(0xFFFFE7C2).withOpacity(0.35),
              ),
              const SizedBox(height: 12),
              Text(
                'SCORE: ${game.score}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFFFFE7C2),
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 2,
                color: const Color(0xFFFFE7C2).withOpacity(0.20),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _actionText(
                    label: 'RETRY',
                    color: const Color(0xFF6BD36A),
                    onTap: () {
                      game.restartRun();
                      game.overlays.remove('GameOver');
                    },
                  ),
                  _actionText(
                    label: 'EXIT',
                    color: const Color(0xFFFFE7C2),
                    onTap: () {
                      final route = startedLoggedIn
                          ? MainMenuScreen.loggedRouteName
                          : MainMenuScreen.routeName;

                      Navigator.of(
                        context,
                      ).pushNamedAndRemoveUntil(route, (_) => false);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionText({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: color,
            height: 1.0,
            shadows: const [
              Shadow(offset: Offset(1, 1), color: Color(0xFF2A1A12)),
            ],
          ),
        ),
      ),
    );
  }
}
