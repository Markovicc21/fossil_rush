import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/cache.dart';
import 'dart:ui';

// Stanja animacije igraca.
enum PlayerAnim { move, jump, hurt, dead }

class CharacterPlayer extends SpriteAnimationGroupComponent<PlayerAnim> {
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
  }) {
    // Pretpostavka: preloadImages je pozvan pre kreiranja komponente.
    animations = {
      PlayerAnim.move: _buildAnim(
        _assetPath(PlayerAnim.move),
        moveFrames,
        moveStepTime,
        loop: true,
      ),
      PlayerAnim.jump: _buildAnim(
        _assetPath(PlayerAnim.jump),
        jumpFrames,
        jumpStepTime,
        loop: false,
      ),
      PlayerAnim.hurt: _buildAnim(
        _assetPath(PlayerAnim.hurt),
        hurtFrames,
        hurtStepTime,
        loop: false,
      ),
      PlayerAnim.dead: _buildAnim(
        _assetPath(PlayerAnim.dead),
        deadFrames,
        deadStepTime,
        loop: false,
      ),
    };

    current = PlayerAnim.move;
    if (size == Vector2.zero()) {
      size = frameSize.clone();
    }
  }

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

  // Koristimo poseban Images cache sa prefiksom "assets/"
  // da bismo ucitavali fajlove iz assets/characters/...
  static final Images _assetImages = Images(prefix: 'assets/');

  // Interna stanja za pravila animacija:
  // dead ima prioritet, jump se ne prekida, hurt ne prekida dead/jump.
  bool _isDead = false;
  bool _isJumping = false;
  double _hurtLeft = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

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
      _assetImages.fromCache(path),
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

  // Jump animacija je iskljucena (igrac ostaje u move animaciji).
  void playJump() {
    return;
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

  // Reset stanja kad se run restartuje.
  void resetState() {
    _isDead = false;
    _isJumping = false;
    _hurtLeft = 0;
    current = PlayerAnim.move;
    animationTicker?.reset();
  }

  bool get isDead => _isDead;
  bool get isJumping => _isJumping;

  // Pravougaonik tela (umanjen) za realniji sudar.
  // - sirina ~55%
  // - visina ~70%
  // - pomeren ka dnu i centriran po X osi
  Rect get bodyRect {
    final double bodyW = size.x * 0.55;
    final double bodyH = size.y * 0.70;
    final double x = position.x + (size.x - bodyW) / 2;
    final double y = position.y + (size.y - bodyH);
    return Rect.fromLTWH(x, y, bodyW, bodyH);
  }

  // Preload sprite sheet-ova da ne "stuca" pri prvom prikazu.
  static Future<void> preloadImages(String characterId) async {
    final paths = _assetPathsFor(characterId);
    await _assetImages.loadAll(paths);
  }

  String _assetPath(PlayerAnim anim) {
    // Mapira karakter + animaciju na realna imena fajlova u assets/.
    final paths = _assetPathsFor(characterId);
    return paths[anim.index];
  }

  // Centralni spisak putanja za svaki karakter.
  static List<String> _assetPathsFor(String id) {
    switch (id) {
      case 'cole':
        return [
          'characters/cole/moveCole.png',
          'characters/cole/jumpCole.png',
          'characters/cole/hurtCole.png',
          'characters/cole/deadCole.png',
        ];
      case 'kuro':
        return [
          'characters/kuro/moveKuro.png',
          'characters/kuro/jumpKuro.png',
          'characters/kuro/hurtKuro.png',
          'characters/kuro/deadKuro.png',
        ];
      case 'mono':
        return [
          'characters/mono/moveMono.png',
          'characters/mono/jumpMono.png',
          'characters/mono/hurtMono.png',
          'characters/mono/deadMono.png',
        ];
      case 'mort':
        return [
          'characters/mort/moveMort.png',
          'characters/mort/jump.png',
          'characters/mort/hurtMortt.png',
          'characters/mort/dead.png',
        ];
      case 'tard':
        return [
          'characters/tard/moveTardt.png',
          'characters/tard/jump.png',
          'characters/tard/hurtTardt.png',
          'characters/tard/dead.png',
        ];
      default:
        throw ArgumentError('Unknown characterId: $id');
    }
  }
}
