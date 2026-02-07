import 'package:flutter/material.dart';
import '../game/dino_run.dart';
import '../widgets/retro_panel.dart';

class PauseMenuOverlay extends StatelessWidget {
  final DinoRun game;
  const PauseMenuOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 240),
        child: RetroPanel(
          fill: const Color(0xFFA56A43),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'PAUSED',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFFFFE7C2),
                  height: 1.0,
                  shadows: [
                    Shadow(offset: Offset(2, 2), color: Color(0xFF2A1A12)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 2,
                color: const Color(0xFFFFE7C2).withOpacity(0.35),
              ),
              const SizedBox(height: 12),
              _RetroAction(
                label: 'RESUME',
                color: const Color(0xFF6BD36A),
                onTap: () {
                  game.resumeGame();
                  game.overlays.remove('PauseMenu');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RetroAction extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _RetroAction({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_RetroAction> createState() => _RetroActionState();
}

class _RetroActionState extends State<_RetroAction> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final dy = _pressed ? 2.0 : 0.0;
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: Transform.translate(
        offset: Offset(0, dy),
        child: RetroPanel(
          fill: const Color(0xFF7A4B2E),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          shadowOffset: 2,
          child: Text(
            widget.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: widget.color,
              height: 1.0,
              shadows: const [
                Shadow(offset: Offset(1, 1), color: Color(0xFF2A1A12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
