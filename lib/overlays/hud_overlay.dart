import 'package:flutter/material.dart';
import '../game/dino_run.dart';

class HudOverlay extends StatelessWidget {
  final DinoRun game;
  const HudOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.55),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Text(
              'SCORE: ${game.score}\n'
              'LIVES: ${game.lives}\n'
              'SH: ${game.shieldActive ? "Y" : "N"}  '
              'SLOW: ${game.slowMoLeft > 0 ? "Y" : "N"}  '
              'X2: ${game.doubleScoreLeft > 0 ? "Y" : "N"}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                height: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
