import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/cache.dart';

// Stanja animacije igraca.
enum PlayerAnim { move, jump, hurt, dead }

class CharacterPlayer extends SpriteAnimationGroupComponent<PlayerAnim>
    with HasGameRef {
  // - ucitava sprite sheet-ove po characterId
  // - kontrolise logiku animacija (jump/hurt/dead)

  CharacterPlayer({
    required this.characterId,
    required this.frameSize,
    this.moveFrames = 6,
    this.jumpFrames = 4,
    this.hurtFrames = 4,
    this.deadFrames = 5,
    this.moveStepTime = 0.09,
    this.jumpStepTime = 0.12,
    this.hurtStepTime = 0.08,
    this.deadStepTime = 0.12,
    this.addHitbox = true,
    this.hitboxSize,
    this.hitboxOffset,
    super.position,
    super.size,
    super.anchor,
  });

  final String characterId;
  final Vector2 frameSize;

  final int moveFrames;
  final int jumpFrames;
  final int hurtFrames;
  final int deadFrames;

  final double moveStepTime;
  final double jumpStepTime;
  final double hurtStepTime;
  final double deadStepTime;

  final bool addHitbox;
  final Vector2? hitboxSize;
  final Vector2? hitboxOffset;

  // Interna stanja za pravila animacija:
  // dead ima prioritet, jump se ne prekida, hurt ne prekida dead/jump.
  bool _isDead = false;
  bool _isJumping = false;
  double _hurtLeft = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Ucitavanje svih animacija iz postojecih fajlova.
    animations = {
      PlayerAnim.move: _buildAnim(
        'characters/$characterId/move.png',
        moveFrames,
        moveStepTime,
        loop: true,
      ),
      PlayerAnim.jump: _buildAnim(
        'characters/$characterId/jump.png',
        jumpFrames,
        jumpStepTime,
        loop: false,
      ),
      PlayerAnim.hurt: _buildAnim(
        'characters/$characterId/hurt.png',
        hurtFrames,
        hurtStepTime,
        loop: false,
      ),
      PlayerAnim.dead: _buildAnim(
        'characters/$characterId/dead.png',
        deadFrames,
        deadStepTime,
        loop: false,
      ),
    };

    current = PlayerAnim.move;
    size = size == Vector2.zero() ? frameSize.clone() : size;

    if (addHitbox) {
      add(
        RectangleHitbox(
          size: hitboxSize ?? frameSize.clone(),
          position: hitboxOffset ?? Vector2.zero(),
        ),
      );
    }
  }

  SpriteAnimation _buildAnim(
    String path,
    int frames,
    double stepTime, {
    required bool loop,
  }) {
    // Animacija iz cache-a (preload preporucen zbog performansi).
    return SpriteAnimation.fromFrameData(
      gameRef.images.fromCache(path),
      SpriteAnimationData.sequenced(
        amount: frames,
        stepTime: stepTime,
        textureSize: frameSize,
        loop: loop,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Dead zakljucava animaciju.
    if (_isDead) return;

    // Hurt traje odredjeno vreme, pa vraca na move (ako nije jump).
    if (_hurtLeft > 0) {
      _hurtLeft -= dt;
      if (_hurtLeft <= 0 && !_isJumping) {
        current = PlayerAnim.move;
      }
    }

    // Jump ide do kraja animacije, tek onda vracamo na move.
    if (_isJumping) {
      if (animationTicker?.done() == true) {
        _isJumping = false;
        if (_hurtLeft <= 0) {
          current = PlayerAnim.move;
        }
      }
    }
  }

  // Move se ne prekida dok smo u jump-u ili dead stanju.
  void playMove() {
    if (_isDead || _isJumping) return;
    current = PlayerAnim.move;
  }

  // Jump ima prioritet nad move; pokrece se iznova.
  void playJump() {
    if (_isDead) return;
    _isJumping = true;
    current = PlayerAnim.jump;
    animationTicker?.reset();
  }

  // Hurt se ignorise ako je dead ili trenutno jump.
  void playHurt({double durationSec = 0.25}) {
    if (_isDead || _isJumping) return;
    _hurtLeft = durationSec;
    current = PlayerAnim.hurt;
    animationTicker?.reset();
  }

  // Dead uvek pobedjuje ostale animacije
  void playDead() {
    if (_isDead) return;
    _isDead = true;
    current = PlayerAnim.dead;
    animationTicker?.reset();
  }

  bool get isDead => _isDead;
  bool get isJumping => _isJumping;

  // Preload sprite sheet-ova da ne "stuca" pri prvom prikazu.
  static Future<void> preloadImages(Images images, String characterId) async {
    await images.loadAll([
      'characters/$characterId/move.png',
      'characters/$characterId/jump.png',
      'characters/$characterId/hurt.png',
      'characters/$characterId/dead.png',
    ]);
  }
}
