import 'dart:async' as async;

import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame/widgets.dart';
import 'package:flutter/material.dart';
import '../game/dino_run.dart';
import '../widgets/retro_panel.dart';

class HudOverlay extends StatefulWidget {
  final DinoRun game;
  const HudOverlay({super.key, required this.game});

  @override
  State<HudOverlay> createState() => _HudOverlayState();
}

enum _HeartState { full, animating, empty }

class _HudOverlayState extends State<HudOverlay> {
  static const _maxLives = 3;
  static const _heartSize = 30.0;
  static const _scoreFontSize = 28.0;
  static const _scoreColor = Color(0xFFFFE7C2);

  final Images _images = Images(prefix: 'assets/images/');
  final Paint _heartPaint = Paint()
    ..filterQuality = FilterQuality.none
    ..isAntiAlias = false;

  SpriteAnimation? _heartAnim;
  final List<SpriteAnimationTicker?> _heartTickers =
      List<SpriteAnimationTicker?>.filled(_maxLives, null);
  final List<_HeartState> _heartStates = List<_HeartState>.filled(
    _maxLives,
    _HeartState.full,
  );

  int _lastLives = _maxLives;
  int _lastScore = 0;
  async.Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _lastLives = widget.game.lives;
    _lastScore = widget.game.score;
    _initHearts(_lastLives);
    _loadHeartAnim();
    _pollTimer = async.Timer.periodic(
      const Duration(milliseconds: 80),
      (_) => _pollGame(),
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadHeartAnim() async {
    final anim = await SpriteAnimation.load(
      'heart_anim.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.08,
        textureSize: Vector2(16, 16),
        loop: false,
      ),
      images: _images,
    );

    if (!mounted) return;

    setState(() {
      _heartAnim = anim;
      for (var i = 0; i < _maxLives; i++) {
        _heartTickers[i] = anim.createTicker();
      }
      _syncHeartFrames();
    });
  }

  void _initHearts(int lives) {
    for (var i = 0; i < _maxLives; i++) {
      _heartStates[i] = i < lives ? _HeartState.full : _HeartState.empty;
    }
    _syncHeartFrames();
  }

  void _syncHeartFrames() {
    if (_heartAnim == null) return;
    for (var i = 0; i < _maxLives; i++) {
      final ticker = _heartTickers[i];
      if (ticker == null) continue;
      switch (_heartStates[i]) {
        case _HeartState.full:
          ticker.reset();
          break;
        case _HeartState.empty:
          ticker.setToLast();
          break;
        case _HeartState.animating:
          ticker.reset();
          break;
      }
    }
  }

  void _pollGame() {
    if (!mounted) return;

    final lives = widget.game.lives;
    final score = widget.game.score;
    var needsSetState = false;

    if (lives != _lastLives) {
      _applyLivesChange(lives, _lastLives);
      _lastLives = lives;
      needsSetState = true;
    }
    if (score != _lastScore) {
      _lastScore = score;
      needsSetState = true;
    }

    if (needsSetState) {
      setState(() {});
    }
  }

  void _applyLivesChange(int newLives, int oldLives) {
    if (newLives < oldLives) {
      for (var i = oldLives - 1; i >= newLives; i--) {
        if (i < 0 || i >= _maxLives) continue;
        _heartStates[i] = _HeartState.animating;
        _heartTickers[i]?.reset();
      }
      return;
    }

    for (var i = 0; i < _maxLives; i++) {
      if (i < newLives) {
        _heartStates[i] = _HeartState.full;
        _heartTickers[i]?.reset();
      } else {
        _heartStates[i] = _HeartState.empty;
        _heartTickers[i]?.setToLast();
      }
    }
  }

  void _onHeartComplete(int index) {
    if (!mounted) return;
    setState(() {
      _heartStates[index] = _HeartState.empty;
      _heartTickers[index]?.setToLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Positioned(
            top: 8,
            left: 10,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_maxLives, (i) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: _buildHeart(i),
                );
              }),
            ),
          ),
          Positioned(
            top: 6,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '${widget.game.score}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: _scoreFontSize,
                  color: _scoreColor,
                  height: 1.0,
                  shadows: [
                    Shadow(offset: Offset(2, 2), color: Color(0xFF2A1A12)),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 6,
            right: 10,
            child: _HudPauseButton(
              onTap: () {
                widget.game.pauseGame();
                widget.game.overlays.add('PauseMenu');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeart(int index) {
    final anim = _heartAnim;
    final ticker = _heartTickers[index];
    if (anim == null || ticker == null) {
      return const SizedBox(width: _heartSize, height: _heartSize);
    }

    final isPlaying = _heartStates[index] == _HeartState.animating;

    return SizedBox(
      width: _heartSize,
      height: _heartSize,
      child: SpriteAnimationWidget(
        animation: anim,
        animationTicker: ticker,
        playing: isPlaying,
        paint: _heartPaint,
        onComplete: () => _onHeartComplete(index),
      ),
    );
  }
}

class _HudPauseButton extends StatefulWidget {
  final VoidCallback onTap;
  const _HudPauseButton({required this.onTap});

  @override
  State<_HudPauseButton> createState() => _HudPauseButtonState();
}

class _HudPauseButtonState extends State<_HudPauseButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final offset = _pressed ? 2.0 : 0.0;
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: Transform.translate(
        offset: Offset(0, offset),
        child: RetroPanel(
          fill: const Color(0xFFA56A43),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          shadowOffset: 2,
          child: const Text(
            'PAUSE',
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFFFFE7C2),
              height: 1.0,
              shadows: [Shadow(offset: Offset(1, 1), color: Color(0xFF2A1A12))],
            ),
          ),
        ),
      ),
    );
  }
}
