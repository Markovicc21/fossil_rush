import 'package:flutter/material.dart';

import '../services/score/score_service.dart';
import '../widgets/retro_panel.dart';

class RankEntry {
  final String username;
  final int bestScore;

  const RankEntry({required this.username, required this.bestScore});
}

class ScoreboardScreen extends StatefulWidget {
  const ScoreboardScreen({super.key});
  static const routeName = '/scoreboard';

  @override
  State<ScoreboardScreen> createState() => _ScoreboardScreenState();
}

class _ScoreboardScreenState extends State<ScoreboardScreen> {
  bool _loading = true;
  List<RankEntry> _entries = const [];

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    try {
      await _loadRankings();
    } catch (_) {
      _entries = const [];
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _loadRankings() async {
    final top = await ScoreService.top(limit: 50);
    _entries = top
        .where((e) => e.gamesPlayed > 0)
        .map((e) => RankEntry(username: e.username, bestScore: e.bestScore))
        .toList();
  }

  Widget _pixelBackButton() {
    return RetroPanel(
      fill: const Color(0xFFA56A43),
      padding: const EdgeInsets.all(6),
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Image.asset(
          'assets/images/ARROW_BACK.png',
          width: 28,
          height: 28,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/jurassic.jpg', fit: BoxFit.cover),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _pixelBackButton(),
                      ),

                      const Text(
                        'RANKS',
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          height: 1.0,
                          shadows: [
                            Shadow(
                              offset: Offset(2, 2),
                              blurRadius: 0,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 6, 14, 14),
                    child: RetroPanel(
                      fill: const Color(0xFF8B5A3C),
                      padding: const EdgeInsets.all(14),
                      child: _loading
                          ? _loadingState()
                          : (_entries.isEmpty ? _emptyState() : _rankList()),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _loadingState() {
    return const Center(
      child: Text(
        'Loading...',
        style: TextStyle(fontSize: 12, color: Color(0xFFFFE7C2)),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: RetroPanel(
        fill: const Color(0xFFA56A43),
        padding: const EdgeInsets.all(18),
        child: const Text(
          "There's no score. \nPlay a game",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, height: 1.7, color: Color(0xFFFFE7C2)),
        ),
      ),
    );
  }

  Widget _rankList() {
    return ListView.separated(
      itemCount: _entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final e = _entries[index];
        return _rankRow(
          rank: index + 1,
          username: e.username,
          score: e.bestScore,
        );
      },
    );
  }

  Widget _rankRow({
    required int rank,
    required String username,
    required int score,
  }) {
    return RetroPanel(
      fill: const Color(0xFFA56A43),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Row(
        children: [
          SizedBox(
            width: 26,
            child: Text(
              '$rank',
              style: const TextStyle(fontSize: 11, color: Color(0xFFFFE7C2)),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.military_tech, size: 16, color: Color(0xFFFFE7C2)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              username,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Color(0xFFFFE7C2)),
            ),
          ),

          const SizedBox(width: 10),
          RetroPanel(
            fill: const Color(0xFF8B5A3C),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            child: Text(
              '$score',
              style: const TextStyle(fontSize: 11, color: Color(0xFFFFE7C2)),
            ),
          ),
        ],
      ),
    );
  }
}
