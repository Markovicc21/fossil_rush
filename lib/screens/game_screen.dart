import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../game/dino_run.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  static const routeName = '/game';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget<DinoRun>(
        game: DinoRun(),
        overlayBuilderMap: {'ExitButton': (ctx, game) => _ExitButtonOverlay()},
        initialActiveOverlays: const ['ExitButton'],
      ),
    );
  }
}

class _ExitButtonOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Text(
                'EXIT',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  height: 1.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
