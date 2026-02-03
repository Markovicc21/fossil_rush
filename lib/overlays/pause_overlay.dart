import 'package:flutter/material.dart';
import '../game/dino_run.dart';

class PauseMenuOverlay extends StatelessWidget {
  final DinoRun game;
  const PauseMenuOverlay({super.key, required this.game});

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
              'PAUSED',
              style: TextStyle(fontSize: 16, color: Colors.white, height: 1.0),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () {
                game.resumeGame();
                game.overlays.remove('PauseMenu');
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
                  'RESUME',
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
