import 'package:flame/camera.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import '../services/auth/auth_service.dart';
import '../services/score/score_service.dart';
import '../services/shop/shop_service.dart';
import 'dart:math';
import 'layout/game_layout.dart';
import 'components/character_player.dart';
import 'components/enemy_sprite.dart';

// ===================== POWER UPS =========================
// Tipovi power-upova koje može pokupiti tokom run-a
enum PowerUpType { shield, slowMo, doubleScore }

// PowerUp je za sada samo obojena kockica (RectangleComponent).

class PowerUp extends RectangleComponent {
  // Koji je tip power-upa
  final PowerUpType type;

  PowerUp({
    required this.type,
    required Vector2 position,
    required Vector2 size,
  }) : super(
         position: position,
         size: size,
         // boja zavisi od tipa, da se vizuelno razlikuju
         paint: Paint()..color = _colorFor(type),
       );

  // Helper: boja po tipu
  static Color _colorFor(PowerUpType t) {
    switch (t) {
      case PowerUpType.shield:
        return const Color(0xFF3AA0FF); // plava
      case PowerUpType.slowMo:
        return const Color(0xFFFFD24A); // zuta
      case PowerUpType.doubleScore:
        return const Color(0xFFFF4AF2); // roze
    }
  }
}

class DinoRun extends FlameGame with TapCallbacks {
  // ===================== WORLD COMPONENTS =====================
  // VAZNO:
  // Background pravimo kao 2 sprite-a zbog scroll/wrap efekta
  late final SpriteComponent background;
  late final SpriteComponent background2;

  // ground na kojoj igrac stoji
  late final RectangleComponent ground;

  // player je animirani sprite (CharacterPlayer)
  late final CharacterPlayer player;

  // Random generator za spawner i power-up logiku
  final _rng = Random();

  // ===================== OBSTACLE SYSTEM ======================
  // Timer koji kuca cesto, ali pravi spawn samo kad mu dozvolim(_nextSpawnIn)
  late final Timer _spawnTimer;

  // Lista svih neprijatelja trenutno u svetu
  final List<EnemySprite> _obstacles = [];

  // Near-miss tracking: da ne dobije bonus vise puta na istoj prepreci
  final Set<EnemySprite> _nearMissed = {};

  // Cooldown  do sledece dozvoljene prepreke
  // Ovo garantuje razmak, bez nemogucih kombinacija
  double _nextSpawnIn = 0;

  // Osnovna brzina sveta
  double speed = 140; // px/s

  // ===================== SCORE SYSTEM =========================
  // Score po run-u
  int score = 0;

  // Akumulator vremena za score tick
  double _scoreAcc = 0;

  // Da score submit uradi samo jednom (kad zavrsi run)
  bool _submitted = false;

  // ===================== LIVES / DAMAGE =======================
  // Broj zivota igraca
  int lives = 3;

  // Invulnerable state (posle hita)
  bool _invulnerable = false;

  // Koliko jos traje invulnerability
  double _invulnLeft = 0;

  // Koliko traje invulnerability posle normalnog hita
  final double invulnDuration = 0.90;

  // Blink timer (vizuelni feedback dok invulnerable)
  double _blinkAcc = 0;

  // Na koliko sekundi menja opacity (blink)
  final double blinkInterval = 0.08;

  // Hitstop: mali freeze gameplay-a
  double _hitStopLeft = 0;

  // ===================== POWER UP STATE =======================
  // Lista power-up kockica na ekranu (u svetu)
  final List<PowerUp> _powerUps = [];

  // Cooldown da power-up ne spawnuje previse cesto
  double _powerSpawnCooldown = 0;

  // Shield: 1 hit free (ne skida life)
  bool shieldActive = false;

  // SlowMo: koliko jos traje efekat usporenja
  double slowMoLeft = 0;

  // DoubleScore: koliko jos traje x2 score tick
  double doubleScoreLeft = 0;

  // Time scale za gameplay update
  // Ako je slowMo aktivan, sve  se uspori.
  double get timeScale => (slowMoLeft > 0) ? 0.55 : 1.0;

  // ===================== PHYSICS ==============================
  // Gravitacija (px/s^2)
  final double gravity = 900;

  // Pocetna brzina skoka (negativno = gore)
  final double jumpVelocity = -380;

  // Trenutna vertikalna brzina igraca
  double vy = 0;

  // Da li igrac stoji na zemlji
  bool onGround = false;

  // Coyote time: dozvoli skok malo posle silaska sa zemlje
  double _coyote = 0;
  final double coyoteMax = 0.08;

  // Jump buffer: ako tapnes pre sletanja, cuva tap pa skoci cim moze
  double _jumpBuffer = 0;
  final double bufferMax = 0.10;

  // Variable jump (hold):
  // ako drzis tap, duze ostajes "lakse gravitacije" dok ides gore => visi skok
  bool _jumpHeld = false;
  double _holdTime = 0;
  final double maxHoldTime = 0.16;
  final double holdGravityFactor = 0.45;

  // ===================== GAME STATE ===========================
  // dead = game over stanje (prestaje spawn/move/score)
  bool dead = false;

  // ===================== CAMERA SHAKE ==================.
  final Random _shakeRng = Random();

  // Osnovna (mirna) pozicija kamere
  Vector2 _cameraBase = Vector2.zero();

  // Koliko jos traje shake
  double _shakeLeft = 0;

  // Ukupno trajanje shake-a (koristi se za decay)
  double _shakeDuration = 0;

  // Intenzitet shake-a u pikselima (virtual resolution px)
  double _shakeIntensity = 0;

  // ===================== FULLSCREEN / LAYOUT HELPERS ==================
  // VAZNO:
  // Flame ume da pozove onGameResize PRE onLoad().
  // Ako tada pipnes late field (background/ground/player) -> LateInitializationError.
  bool _worldReady = false;

  // VAZNO:
  // Ne koristimo vise hardcoded "150" za ground level!
  // Uvek uzimamo realni top ground-a (ground.position.y), jer layout skalira ekran.
  double get _groundTopY => ground.position.y;

  // ===================== BACKGROUND SCROLL =====================
  // Brzina scroll-a pozadine (manja od speed da dobije parallax osećaj)
  // Ako zelis brze/sporije, menjaj ovaj faktor.
  double get _bgSpeed => speed * 0.35;

  // Pokreni shake (juice efekat)
  void _startShake({double intensity = 2.0, double duration = 0.12}) {
    _shakeIntensity = intensity;
    _shakeDuration = duration;
    _shakeLeft = duration;
  }

  // Update shake-a (poziva se svaki frame)
  void _updateShake(double dt) {
    // Ako nema shake-a, vrati kameru na bazu
    if (_shakeLeft <= 0) {
      camera.viewfinder.position.setFrom(_cameraBase);
      return;
    }

    // Oduzmi dt
    _shakeLeft -= dt;
    if (_shakeLeft < 0) _shakeLeft = 0;

    // t = 1 na pocetku, 0 na kraju
    final t = (_shakeDuration <= 0) ? 0.0 : (_shakeLeft / _shakeDuration);

    // amplitude opada kako t ide ka 0
    final amp = _shakeIntensity * t;

    // random offset u opsegu [-amp, +amp]
    final dx = (_shakeRng.nextDouble() * 2 - 1) * amp;
    final dy = (_shakeRng.nextDouble() * 2 - 1) * amp;

    // pomeri kameru oko baze
    camera.viewfinder.position.setFrom(_cameraBase + Vector2(dx, dy));
  }

  @override
  Color backgroundColor() => const Color(0xFF0B0B0B);

  // ===================== SCORE SUBMIT =========================
  // Upisuje score u scoreboard (samo jednom po run-u)
  Future<void> _submitScoreOnce() async {
    if (_submitted) return;
    _submitted = true;

    // uzmi session -> username
    final session = await AuthService.repo.session();
    final username = session?.username;

    // ako nema user-a, preskoci submit
    if (username == null || username.isEmpty) return;

    await ScoreService.submit(username, score);
  }

  // ===================== GAME LOAD ============================
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Retro virtual rezolucija (fixed viewport)
    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewport = FixedResolutionViewport(resolution: Vector2(360, 180));

    // sacuvaj baznu poziciju kamere (za shake)
    _cameraBase = camera.viewfinder.position.clone();

    // BACKGROUND (2 sprite-a za scroll/wrap)
    final bgSprite = await loadSprite('jurassic.jpg');

    background = SpriteComponent()
      ..sprite = bgSprite
      ..position = Vector2(0, 0)
      ..size = Vector2(360, 180)
      ..priority = -100; // da bude iza svega

    background2 = SpriteComponent()
      ..sprite = bgSprite
      ..position =
          Vector2(360, 0) // odmah desno od prvog
      ..size = Vector2(360, 180)
      ..priority = -100;

    add(background);
    add(background2);

    // GROUND (platforma)
    ground = RectangleComponent(
      position: Vector2(0, 150),
      size: Vector2(360, 30),
      paint: Paint()..color = const Color(0xFF2B2B2B),
    );
    add(ground);

    // Enemy sprite sheet preload (da ne stuca pri prvom spawnu)
    await EnemySprite.preloadImages('doux');
    await EnemySprite.preloadImages('kira');
    await EnemySprite.preloadImages('olaf');
    await EnemySprite.preloadImages('vita');

    // PLAYER (aktivni dino iz shop-a, default = tard)
    String activeId = 'tard';
    final session = await AuthService.repo.session();
    final username = session?.username;
    if (username != null && username.isNotEmpty) {
      try {
        final state = await ShopService.repo.load(username);
        activeId = state.activeId;
      } catch (_) {
        activeId = 'tard';
      }
    }

    await CharacterPlayer.preloadImages(activeId);
    player = CharacterPlayer(
      characterId: activeId,
      frameSize: Vector2(24, 24),
      position: Vector2(60, 110),
      size: Vector2(54, 54),
    );
    add(player);

    // VAZNO:
    // Tek sad je svet stvarno spreman (late polja inicijalizovana).
    _worldReady = true;

    // Postavi sve u start stanje
    _resetRunState(fullReset: true);

    // Timer kuca na 0.25s, ali stvarni spawn radi cooldown logika
    _spawnTimer = Timer(0.25, repeat: true, onTick: _spawnObstacle)..start();

    // Ako se resize desio pre onLoad, sada forsiraj layout jednom
    onGameResize(size);
  }

  // ===================== RESET HELPERS =========================
  // fullReset: ako je true -> reset i zivote (3) i sve ostalo
  void _resetRunState({required bool fullReset}) {
    dead = false;
    _submitted = false;

    score = 0;
    _scoreAcc = 0;

    if (fullReset) lives = 3;

    // reset player pozicije i stanja animacije
    player.position = Vector2(60, 110);
    player.resetState();
    vy = 0;
    onGround = true;

    // reset jump helpera
    _coyote = 0;
    _jumpBuffer = 0;
    _jumpHeld = false;
    _holdTime = 0;

    // reset spawner logike
    _nearMissed.clear();
    _nextSpawnIn = 0;

    // reset invulnerability / blink
    _invulnerable = false;
    _invulnLeft = 0;
    _blinkAcc = 0;
    player.opacity = 1.0;

    // reset hitstop
    _hitStopLeft = 0;

    // reset power-upova i efekata
    shieldActive = false;
    slowMoLeft = 0;
    doubleScoreLeft = 0;
    _powerSpawnCooldown = 1.5;

    // ukloni sve prepreke iz sveta
    for (final o in _obstacles) {
      o.removeFromParent();
    }
    _obstacles.clear();

    // ukloni sve power-upove iz sveta
    for (final p in _powerUps) {
      p.removeFromParent();
    }
    _powerUps.clear();

    // reset camera shake
    _shakeLeft = 0;
    camera.viewfinder.position.setFrom(_cameraBase);
  }

  // ===================== DIFFICULTY DIRECTOR ==================
  // Ovim kontrolise kako se tezina menja kroz score.
  // Early: samo low
  // Mid: low+high
  // Late: ubaci retko flying i malo cesci double low

  double _lowWeight() {
    if (score < 15) return 1.00;
    if (score < 40) return 0.70;
    return 0.60;
  }

  double _highWeight() {
    if (score < 15) return 0.00;
    if (score < 40) return 0.30;
    return 0.33;
  }

  // flying je ultra retko i tek posle 40
  double _flyingWeight() {
    if (score < 40) return 0.00;
    return 0.07;
  }

  // double obstacle (samo low+low) sansa
  double _doubleChance() {
    if (score < 15) return 0.00;
    if (score < 40) return 0.06;
    return 0.10;
  }

  // sansa da preskoci spawn da ubaci prazninu
  double _skipChance() {
    if (score < 15) return 0.18;
    if (score < 40) return 0.14;
    return 0.10;
  }

  // gapFactor kontrolise minimalni razmak kroz speed
  // early: veci razmak, late: gusce
  double _gapFactor() {
    if (score < 15) return 0.90;
    if (score < 40) return 0.78;
    return 0.72;
  }

  // ===================== SPAWN OBSTACLE =======================

  // - koristi _nextSpawnIn da ne napravi nemoguce situacije
  // - double samo low+low
  void _spawnObstacle() {
    if (!_worldReady) return;
    if (dead) return;
    if (_nextSpawnIn > 0) return;

    // kontrolisana praznin
    if (_rng.nextDouble() < _skipChance()) {
      _nextSpawnIn = 0.30;
      return;
    }

    // Dva ground enemy + dva flying enemy
    const groundIds = ['doux', 'olaf'];
    const flyingIds = ['kira', 'vita'];
    final bool isFlying = _rng.nextBool();
    final String enemyId = isFlying
        ? flyingIds[_rng.nextInt(flyingIds.length)]
        : groundIds[_rng.nextInt(groundIds.length)];

    // VAZNO: sve vezano za REAL ground top
    final groundTop = _groundTopY;

    // doux/kira/olaf/vita: 72x24 -> 3 frame-a po 24x24
    const double baseW = 24;
    const double baseH = 24;
    const double scale = 1.6;

    final double w = baseW * scale;
    final double h = baseH * scale;

    // Ground enemy: Y resava EnemySprite preko groundY
    final double y = isFlying ? (groundTop - h - 18) : 0;

    // helper za spawn jednog neprijatelja
    void spawnOne(double xOffset) {
      final o = EnemySprite(
        enemyId: enemyId,
        position: Vector2(360 + xOffset, y),
        size: Vector2(w, h),
        groundY: isFlying ? null : groundTop,
        hitboxScale: Vector2(0.75, 0.75),
        hitboxOffset: Vector2.zero(),
        anchor: isFlying ? Anchor.bottomLeft : Anchor.bottomLeft,
      );
      o.priority = 5;
      add(o);
      _obstacles.add(o);
    }

    // Minimalni razmak u pikselima:
    // raste sa speed i faktorom faze (early vece)
    final double minGapPx = max(95.0, speed * _gapFactor());
    final double minGapSec = minGapPx / speed;

    // Double dozvoljen samo za low prepreku i nikad sa flying
    final bool allowDouble = false;
    final bool doDouble = false;

    if (!doDouble) {
      // Single spawn
      spawnOne(0);

      // sledeci spawn posle
      _nextSpawnIn = minGapSec * (0.75 + _rng.nextDouble() * 0.35);
      return;
    }

    // Double spawn: dve low prepreke sa razmakom koji skaluje sa speed
    final double secondOffset = minGapPx * 0.78;
    spawnOne(0);
    spawnOne(secondOffset);

    // posle double-a obavezno duza pauza
    _nextSpawnIn = minGapSec * 1.40;
  }

  // ===================== POWER UP SPAWN =======================
  // Ponekad spawnuje power-up kockicu.
  // - max 1 na ekranu
  // - cooldown da ne spamuje
  void _trySpawnPowerUp() {
    if (!_worldReady) return;
    if (dead) return;
    if (_powerSpawnCooldown > 0) return;

    // sansa po tick-u (mala)
    if (_rng.nextDouble() > 0.08) return;

    // max 1 na ekranu
    if (_powerUps.isNotEmpty) {
      _powerSpawnCooldown = 2.0;
      return;
    }

    // random izbor tipa (shield je redji)
    final double r = _rng.nextDouble();
    PowerUpType type;
    if (r < 0.45) {
      type = PowerUpType.slowMo;
    } else if (r < 0.85) {
      type = PowerUpType.doubleScore;
    } else {
      type = PowerUpType.shield;
    }

    // pozicija iznad zemlje (pokupivo i tokom trcanja / skoka)
    const w = 12.0;
    const h = 12.0;

    // VAZNO: isto vezano za ground top
    final y = _groundTopY - 30 - h;

    final p = PowerUp(
      type: type,
      position: Vector2(360, y),
      size: Vector2(w, h),
    );

    add(p);
    _powerUps.add(p);

    // cooldown nakon spawna
    _powerSpawnCooldown = 6.0 + _rng.nextDouble() * 5.0;
  }

  // Kad pokupi power-up, aktiviraj efekat
  void _applyPowerUp(PowerUpType type) {
    switch (type) {
      case PowerUpType.shield:
        shieldActive = true;
        break;
      case PowerUpType.slowMo:
        slowMoLeft = 3.0;
        break;
      case PowerUpType.doubleScore:
        doubleScoreLeft = 4.0;
        break;
    }

    // mali camera juice na pickup
    _startShake(intensity: 1.8, duration: 0.10);
  }

  // ===================== DAMAGE / HURT =========================

  // - ako ima shield - pojede hit, nema skidanja life
  // - inace skida life, daje invuln blink, hitstop, shake
  // - kad lives padne na 0 - dead + submit score + overlay
  void _takeHit() {
    if (_invulnerable || dead) return;

    // Shield cancels ONE hit
    if (shieldActive) {
      shieldActive = false;

      _hitStopLeft = 0.04;

      _invulnerable = true;
      _invulnLeft = 0.55; // krace invuln posle shield hita
      _blinkAcc = 0;

      _startShake(intensity: 1.6, duration: 0.10);
      return;
    }

    // Bez shield-a skidaj zivot
    lives -= 1;
    player.playHurt();

    _hitStopLeft = 0.06;

    _invulnerable = true;
    _invulnLeft = invulnDuration;
    _blinkAcc = 0;

    // mali knockback levo
    player.position.x = max(20, player.position.x - 6);

    _startShake(intensity: 2.6, duration: 0.14);

    // Game over kad nema zivota
    if (lives <= 0) {
      dead = true;

      _startShake(intensity: 3.8, duration: 0.22);
      player.playDead();

      _submitScoreOnce();
      overlays.add('GameOver');
      debugPrint('GAME OVER score=$score');
    }
  }

  // ===================== UPDATE LOOP ==========================
  @override
  void update(double dt) {
    super.update(dt);

    // Ako svet nije spreman, ne diraj nista gameplay-related
    if (!_worldReady) return;

    // 1) Camera shake uvek (unscaled dt)
    _updateShake(dt);

    // 2) Power-up trajanja (unscaled dt)
    if (slowMoLeft > 0) slowMoLeft -= dt;
    if (doubleScoreLeft > 0) doubleScoreLeft -= dt;

    // 3) Invuln blink uvek (unscaled dt)
    _updateInvulnBlink(dt);

    // 4) Hitstop: gameplay stop, ali fizika/clamp i dalje radi
    if (_hitStopLeft > 0) {
      _hitStopLeft -= dt;
      if (_hitStopLeft < 0) _hitStopLeft = 0;

      _updatePhysics(dt);
      return;
    }

    // 5) Fizika uvek (igrac skace/ pada)
    _updatePhysics(dt);

    // Ako je game over, zamrzni ostatak gameplay-a
    if (dead) return;

    // 6) Scaled dt za sve  (spawn/move/score) zbog slowMo
    final double gdt = dt * timeScale;

    // ===================== BACKGROUND SCROLL =====================
    // Pomeri oba background sprite-a ulevo, pa wrap kad izadju
    background.position.x -= _bgSpeed * gdt;
    background2.position.x -= _bgSpeed * gdt;

    // wrap logika: kad jedan potpuno izadje levo, prebaci ga desno od drugog
    final w = background.size.x;

    if (background.position.x <= -w) {
      background.position.x = background2.position.x + w;
    }
    if (background2.position.x <= -w) {
      background2.position.x = background.position.x + w;
    }
    // =============================================================

    // 7) Cooldown-i (scaled)
    if (_nextSpawnIn > 0) _nextSpawnIn -= gdt;
    if (_powerSpawnCooldown > 0) _powerSpawnCooldown -= gdt;

    // 8) Timer tick (scaled) - zove _spawnObstacle ako treba
    _spawnTimer.update(gdt);

    // 9) Probaj spawn power-up (scaled)
    _trySpawnPowerUp();

    // 10) Pomeri prepreke ulevo (scaled)
    for (final o in List<EnemySprite>.from(_obstacles)) {
      o.position.x -= speed * gdt;

      // cleanup kad izadje levo
      if (o.position.x + o.size.x < 0) {
        o.removeFromParent();
        _obstacles.remove(o);
        _nearMissed.remove(o);
      }
    }

    // 11) Pomeri power-upove ulevo (scaled)
    for (final p in List<PowerUp>.from(_powerUps)) {
      p.position.x -= speed * gdt;

      // cleanup kad izadje levo
      if (p.position.x + p.size.x < 0) {
        p.removeFromParent();
        _powerUps.remove(p);
      }
    }

    // 12) Collision (prepreke + near miss bonus)
    final playerRect = player.bodyRect;

    for (final o in List<EnemySprite>.from(_obstacles)) {
      // sudar-  take hit
      if (playerRect.overlaps(o.bodyRect)) {
        _takeHit();
        break;
      }

      // near miss: prolaz bas blizu prepreke daje mali bonus
      final dx = (o.position.x - (player.position.x + player.size.x)).abs();
      final sameLane = (player.position.y - o.position.y).abs() < 8;

      if (!_nearMissed.contains(o) && dx < 6 && sameLane) {
        score += 2;
        _nearMissed.add(o);
      }
    }

    // 13) Collision sa power-upovima
    for (final p in List<PowerUp>.from(_powerUps)) {
      if (playerRect.overlaps(p.toRect())) {
        _applyPowerUp(p.type);
        p.removeFromParent();
        _powerUps.remove(p);
        break;
      }
    }

    // 14) Score tick (scaled) + double score efekat
    _scoreAcc += gdt;
    if (_scoreAcc >= 0.4) {
      score += (doubleScoreLeft > 0) ? 2 : 1;
      _scoreAcc = 0;
    }

    // 15) Difficulty: speed raste sa score
    speed = 140 + score * 0.6;
    if (speed > 360) speed = 360;
  }

  // ===================== PHYSICS UPDATE =======================
  // Sve sto se tice skoka, gravitacije, clamp-a na ground.
  void _updatePhysics(double dt) {
    // coyote time update
    if (onGround) {
      _coyote = 0;
    } else {
      _coyote += dt;
    }

    // jump buffer update
    if (_jumpBuffer > 0) _jumpBuffer -= dt;

    // ako ima buffered tap i jos smo u coyote prozoru - jump
    if (!dead && _jumpBuffer > 0 && (_coyote <= coyoteMax)) {
      vy = jumpVelocity;
      onGround = false;
      _jumpBuffer = 0;
      player.playJump();

      // start hold window
      _holdTime = 0;
    }

    // variable jump: dok drzi tap i ide gore,  visi skok
    double g = gravity;
    if (_jumpHeld && vy < 0 && _holdTime < maxHoldTime) {
      g = gravity * holdGravityFactor;
      _holdTime += dt;
    }

    // primeni gravitaciju i pomeraj
    vy += g * dt;
    player.position.y += vy * dt;

    // clamp na ground
    final double floorY = ground.position.y - player.size.y;
    if (player.position.y >= floorY) {
      player.position.y = floorY;
      vy = 0;
      onGround = true;
      _holdTime = 0;
    } else {
      onGround = false;
    }
  }

  // ===================== INVULN BLINK =========================
  // Dok je invulnerable:
  // - smenjuj opacity (blink)
  // - kad istekne, vrati opacity na 1.0
  void _updateInvulnBlink(double dt) {
    if (!_invulnerable) return;

    _invulnLeft -= dt;
    if (_invulnLeft <= 0) {
      _invulnerable = false;
      _invulnLeft = 0;
      player.opacity = 1.0;
      return;
    }

    _blinkAcc += dt;
    if (_blinkAcc >= blinkInterval) {
      _blinkAcc = 0;
      player.opacity = (player.opacity < 1.0) ? 1.0 : 0.25;
    }
  }

  // ===================== INPUT ================================
  @override
  void onTapDown(TapDownEvent event) {
    // Ako je dead, tap ne radi nista (restart je samo preko RETRY dugmeta)
    if (dead) return;

    // drzi tap  enable hold
    _jumpHeld = true;

    // jump buffer: ako nije na zemlji, sacuva tap pa skoci cim moze
    _jumpBuffer = bufferMax;
  }

  @override
  void onTapUp(TapUpEvent event) {
    // pustio tap prekini hold
    _jumpHeld = false;

    // cut jump: ako pusti dok ide gore, skrati skok
    if (vy < 0) {
      vy *= 0.55;
    }
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    // cancel tap  isto kao tap up
    _jumpHeld = false;
    if (vy < 0) {
      vy *= 0.55;
    }
  }

  // ===================== DEBUG RENDER =========================
  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final debug = TextPainter(
      text: TextSpan(
        text:
            'SCORE:$score  LIVES:$lives  SH:${shieldActive ? "Y" : "N"}  SLOW:${slowMoLeft > 0 ? "Y" : "N"}  X2:${doubleScoreLeft > 0 ? "Y" : "N"}',
        style: const TextStyle(fontSize: 10, color: Colors.white),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    debug.paint(canvas, const Offset(6, 6));

    // Debug hitbox (ukljuci po potrebi)
    if (_debugHitboxes) {
      final p = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFF00FF88);
      canvas.drawRect(player.bodyRect, p);

      final e = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFFFF4444);
      for (final o in _obstacles) {
        canvas.drawRect(o.bodyRect, e);
      }
    }
  }

  void restartRun() {
    // restart bez menjanja UI-a (UI samo sklanja overlay)
    _resetRunState(fullReset: true);
    _spawnTimer.start();
  }

  void pauseGame() {
    pauseEngine();
  }

  void resumeGame() {
    resumeEngine();
  }

  final GameLayout _layout = GameLayout(groundH: 30);
  Vector2 _screen = Vector2.zero();
  final bool _debugHitboxes = false;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _screen = size;

    // VAZNO:
    // onGameResize moze doci pre onLoad -> ne diraj late polja dok svet nije spreman
    if (!_worldReady) return;

    _layout.apply(
      screen: size,
      background: background,
      ground: ground,
      player: player,
      playerSize: player.size,
      onGround: onGround,
    );

    // VAZNO:
    // Drugi background mora da ostane zalepljen desno od prvog i posle resize-a
    background2.size = background.size.clone();
    background2.position = Vector2(
      background.position.x + background.size.x,
      background.position.y,
    );

    _cameraBase = camera.viewfinder.position.clone();
  }
}
