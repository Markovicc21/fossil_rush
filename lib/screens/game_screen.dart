import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../game/dino_run.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  static const routeName = '/game';

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: GameWidget<DinoRun>(game: DinoRun()));
  }
}
