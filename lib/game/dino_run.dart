import '../services/auth/auth_service.dart';
import '../services/score/score_service.dart';
import 'package:flame/camera.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

class DinoRun extends FlameGame with TapCallbacks {
  late final RectangleComponent ground;
  late final RectangleComponent player;

  //prati score po igri
  int score = 0;
  double _scoreAcc = 0;
  bool _submitted = false;

  //FIZIKA
  final double gravity = 900; // px/s^2
  final double jumpVelocity = -380; // px/s
  double vy = 0; //vertical velocity
  bool onGround = false;

  @override
  Color backgroundColor() => const Color(0xFF0B0B0B);

  final double worldSpeed = 120; //px/s
  late final RectangleComponent obstacle;
  bool dead = false;

  //upisivanje scora u scoeboard
  Future<void> _submitScoreOnce() async {
    if (_submitted) return;
    _submitted = true;

    final session = await AuthService.repo.session();
    final username = session?.username;
    if (username == null || username.isEmpty) return;

    await ScoreService.submit(username, score);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    //FIXED "VIRUTAL" REZOLUCIJA ZA RETRO FEEL
    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewport = FixedResolutionViewport(resolution: Vector2(360, 180));

    //GROUND
    ground = RectangleComponent(
      position: Vector2(0, 150),
      size: Vector2(360, 30),
      paint: Paint()..color = const Color(0xFF2B2B2B),
    );
    add(ground);

    //PLAYER SAD KOCKA KASNIJE SPRITE IZ SHOPA
    player = RectangleComponent(
      position: Vector2(60, 110),
      size: Vector2(18, 18),
      paint: Paint()..color = const Color(0xFF00FF88),
    );
    add(player);

    //OBSTACLE ZA PLAYERA
    obstacle = RectangleComponent(
      position: Vector2(360, 132), //desno van ekrana
      size: Vector2(14, 18),
      paint: Paint()..color = const Color(0xFFFF4444),
    );
    add(obstacle);
    //START STATE
    onGround = true;
    vy = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);

    //gravitacija
    vy += gravity * dt;

    //pomeri igraca po Y
    player.position.y += vy * dt;

    //collision sa groundom (simple clamp)
    final double floorY = ground.position.y - player.size.y;

    if (player.position.y >= floorY) {
      player.position.y = floorY;
      vy = 0;
      onGround = true;
    } else {
      onGround = false;
    }

    if (dead) return;
    ;
    //pomeri obstacle ulevo
    obstacle.position.x -= worldSpeed * dt;

    //reset obstacle kad izadje levo(ponovi)
    if (obstacle.position.x < -obstacle.size.x) {
      obstacle.position.x = 360 + 40; // malo razmaka
    }

    //collision (AABB)
    final p = player.toRect();
    final o = obstacle.toRect();
    if (p.overlaps(o)) {
      dead = true;
      _submitScoreOnce();
      debugPrint('GAME OVER');
    }

    //SCORE
    if (!dead) {
      _scoreAcc += dt;
      if (_scoreAcc >= 0.2) {
        score += 1;
        _scoreAcc = 0;
      }
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (dead) {
      dead = false;
      _submitted = false;
      //reset pozicija
      player.position = Vector2(60, 110);
      vy = 0;
      onGround = true;

      //reset obstacle
      obstacle.position = Vector2(360, 132);

      //reset score
      score = 0;
      _scoreAcc = 0;
      return;
    }
    //jump samo ako je na zemlji
    if (onGround) {
      vy = jumpVelocity;
      onGround = false;
    }
    debugPrint('TAP DOWN');
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    //mali debug text brisem kasnije
    final stateText = TextPainter(
      text: TextSpan(
        text: onGround ? 'ON GROUND' : 'JUMPING',
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    stateText.paint(canvas, const Offset(10, 10));

    final scoreText = TextPainter(
      text: TextSpan(
        text: 'SCORE: $score',
        style: const TextStyle(fontSize: 10, color: Colors.white),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    scoreText.paint(canvas, Offset(10, 24));
  }
}
