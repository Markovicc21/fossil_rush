import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/score_state.dart';
import 'score_repository.dart';

class LocalScoreRepository implements ScoreRepository {
  static const _prefix = 'score_';

  String _key(String username) => '$_prefix$username';

  @override
  Future<ScoreState> getScore(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(userId));

    if (raw == null) {
      return ScoreState.empty;
    }

    return ScoreState.fromJson(jsonDecode(raw));
  }

  @override
  Future<ScoreState> submitScore(
    String userId,
    int score, {
    String? username,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getScore(userId);

    final updated = current.copyWith(
      lastScore: score,
      gamesPlayed: current.gamesPlayed + 1,
      bestScore: score > current.bestScore ? score : current.bestScore,
    );

    await prefs.setString(_key(userId), jsonEncode(updated.toJson()));
    return updated;
  }

  @override
  Future<void> reset(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(userId));
  }

  @override
  Future<List<ScoreEntry>> getTop({int limit = 50}) async {
    return const [];
  }
}
