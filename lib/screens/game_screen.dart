import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart'; // SystemChrome / SystemUiMode
import '../game/dino_run.dart';
import '../overlays/hud_overlay.dart';
import '../overlays/game_over_overlay.dart';
import '../overlays/pause_overlay.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.isLoggedIn});
  static const routeName = '/game';
  final bool isLoggedIn;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // VAZNO:
  // Edge-to-edge kao Flutter UI:
  // ImmersiveSticky sakrije system bars tokom igre.
  //
  // NAPOMENA:
  // setEnabledSystemUIOverlays vise ne postoji u novim Flutter verzijama,
  // zato MORAMO setEnabledSystemUIMode.
  @override
  void initState() {
    super.initState();

    // FULLSCREEN (status + nav bar OFF)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // (opciono) zakljucaj portrait ako hoces da bude bas kao menu
    // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    // Vrati system UI kad izadjes iz igre
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // (opciono) vrati sve orijentacije ako si zakljucao gore
    // SystemChrome.setPreferredOrientations(DeviceOrientation.values);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // VAZNO:
      // Ovo forsira da GameWidget popuni CEO ekran (od ivice do ivice)
      body: SizedBox.expand(
        child: GameWidget<DinoRun>(
          game: DinoRun(startedLoggedIn: widget.isLoggedIn),
          overlayBuilderMap: {
            'Hud': (ctx, game) => HudOverlay(game: game),
            'GameOver': (ctx, game) =>
                GameOverOverlay(game: game, startedLoggedIn: widget.isLoggedIn),
            'PauseMenu': (ctx, game) => PauseMenuOverlay(game: game),
          },
          initialActiveOverlays: const ['Hud'],
        ),
      ),
    );
  }
}
