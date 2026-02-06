import 'package:flame/components.dart';
import 'package:flame/cache.dart';
import 'package:flame/collisions.dart';
import 'dart:ui';

// Stanje animacije neprijatelja.
enum EnemyAnim { idle }

class EnemySprite extends SpriteAnimationGroupComponent<EnemyAnim> {
  // Reusable komponenta za neprijatelje:
  // - ucitava sprite sheet po enemyId
  // - koristi jedan idle anim sheet
  EnemySprite({
    required this.enemyId,
    this.frameSize,
    this.idleFrames,
    this.idleStepTime = 0.10,
    this.groundY,
    this.hitboxScale,
    this.hitboxOffset,
    super.position,
    super.size,
    super.anchor = Anchor.bottomLeft,
  }) {
    final spec = _specFor(enemyId);

    final fs = frameSize ?? spec.frameSize;
    final idleCount = idleFrames ?? spec.idleFrames;
    final hbScale = hitboxScale ?? Vector2(0.75, 0.75);
    final hbOffset = hitboxOffset ?? Vector2.zero();

    animations = {
      EnemyAnim.idle: _buildAnim(
        spec.idlePath,
        idleCount,
        idleStepTime,
        fs,
        loop: true,
      ),
    };

    current = EnemyAnim.idle;
    if (size == Vector2.zero()) {
      size = fs.clone();
    }

    if (groundY != null) {
      // Ako prosledimo ground liniju, samo zakaci dno.
      position = Vector2(position.x, groundY!);
      anchor = Anchor.bottomLeft;
    }

    // Hitbox manji od sprite-a, da izbegnemo "ghost hit".
    add(
      RectangleHitbox(
        size: Vector2(size.x * hbScale.x, size.y * hbScale.y),
        position: Vector2(
          hbOffset.x,
          (size.y * (1 - hbScale.y)) + hbOffset.y,
        ),
        anchor: Anchor.topLeft,
      ),
    );
  }

  final String enemyId;
  final Vector2? frameSize;
  final int? idleFrames;
  final double idleStepTime;
  final double? groundY;
  final Vector2? hitboxScale;
  final Vector2? hitboxOffset;

  // Images cache sa prefiksom "assets/" (kao kod CharacterPlayer).
  static final Images _assetImages = Images(prefix: 'assets/');

  SpriteAnimation _buildAnim(
    String path,
    int frames,
    double stepTime,
    Vector2 frameSize, {
    required bool loop,
  }) {
    return SpriteAnimation.fromFrameData(
      _assetImages.fromCache(path),
      SpriteAnimationData.sequenced(
        amount: frames,
        stepTime: stepTime,
        textureSize: frameSize,
        loop: loop,
      ),
    );
  }

  // Preload sprite sheet-ova da ne "stuca" pri prvom prikazu.
  static Future<void> preloadImages(String enemyId) async {
    final spec = _specFor(enemyId);
    final paths = <String>[spec.idlePath];
    await _assetImages.loadAll(paths);
  }

  // Pravougaonik koji se koristi za koliziju u DinoRun (u svetu).
  Rect get bodyRect {
    final rect = toRect();
    final hbScale = hitboxScale ?? Vector2(0.75, 0.75);
    final hbOffset = hitboxOffset ?? Vector2.zero();

    final double w = rect.width * hbScale.x;
    final double h = rect.height * hbScale.y;
    final double x = rect.left + (rect.width - w) / 2 + hbOffset.x;
    final double y = rect.top + (rect.height - h) + hbOffset.y;

    return Rect.fromLTWH(x, y, w, h);
  }

  // Spec po enemyId (nazivi fajlova i default frame info).
  static _EnemySpec _specFor(String id) {
    switch (id) {
      case 'doux':
        return _EnemySpec(
          idlePath: 'enemies/doux.png',
          frameSize: Vector2(24, 24),
          idleFrames: 3,
        );
      case 'kira':
        return _EnemySpec(
          idlePath: 'enemies/kira.png',
          frameSize: Vector2(24, 24),
          idleFrames: 3,
        );
      case 'olaf':
        return _EnemySpec(
          idlePath: 'enemies/olaf.png',
          frameSize: Vector2(24, 24),
          idleFrames: 3,
        );
      case 'vita':
        return _EnemySpec(
          idlePath: 'enemies/Vita.png',
          frameSize: Vector2(24, 24),
          idleFrames: 3,
        );
      case 'crack':
        return _EnemySpec(
          idlePath: 'enemies/crack.png',
          frameSize: Vector2(24, 24),
          idleFrames: 4,
        );
      case 'crackK':
        return _EnemySpec(
          idlePath: 'enemies/crackK.png',
          frameSize: Vector2(24, 24),
          idleFrames: 4,
        );
      default:
        throw ArgumentError('Unknown enemyId: $id');
    }
  }
}

class _EnemySpec {
  const _EnemySpec({
    required this.idlePath,
    required this.frameSize,
    required this.idleFrames,
  });

  final String idlePath;
  final Vector2 frameSize;
  final int idleFrames;
}
