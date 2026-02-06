import 'package:flame/components.dart';
import 'dart:ui';

// Tile-ovani ground bez rastezanja sprite-a.
class GroundTile extends PositionComponent {
  GroundTile({
    required this.sprite,
    required this.tileSize,
    this.scrollX = 0,
    super.position,
    super.size,
    super.priority,
    super.anchor,
  });

  final Sprite sprite;
  final Vector2 tileSize;
  double scrollX;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (tileSize.x <= 0 || tileSize.y <= 0) return;

    final startX = -((scrollX % tileSize.x).floorToDouble());
    final tilesX = ((size.x - startX) / tileSize.x).ceil() + 1;
    final tilesY = (size.y / tileSize.y).ceil() + 1;

    for (int y = 0; y < tilesY; y++) {
      for (int x = 0; x < tilesX; x++) {
        final dx = startX + (x * tileSize.x);
        final dy = y * tileSize.y;
        sprite.render(
          canvas,
          position: Vector2(dx, dy),
          size: tileSize,
        );
      }
    }
  }
}
