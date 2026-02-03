import 'package:flutter/material.dart';
import '../game/dino_run.dart';

class GameOverOverlay extends StatelessWidget {
  final DinoRun game;
  const GameOverOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.70),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'GAME OVER',
              style: TextStyle(fontSize: 16, color: Colors.white, height: 1.0),
            ),
            const SizedBox(height: 10),
            Text(
              'SCORE: ${game.score}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () {
                game.restartRun();
                game.overlays.remove('GameOver');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Text(
                  'RETRY',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    height: 1.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
