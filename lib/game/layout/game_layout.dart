import 'package:flame/components.dart';

class GameLayout {
  final double groundH;

  GameLayout({this.groundH = 30});

  void apply({
    required Vector2 screen,
    required SpriteComponent background,
    required PositionComponent ground,
    required PositionComponent player,
    required Vector2 playerSize,
    required bool onGround,
  }) {
    background
      ..position = Vector2.zero()
      ..size = screen;

    ground
      ..position = Vector2(0, screen.y - groundH)
      ..size = Vector2(screen.x, groundH);

    // player x: 16% širine
    player.position.x = screen.x * 0.16;

    if (onGround) {
      player.position.y = ground.position.y - playerSize.y;
    }
  }
}
