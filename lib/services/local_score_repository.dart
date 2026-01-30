import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/score_state.dart';
import 'score_repository.dart';

class LocalScoreRepository implements ScoreRepository {
  static const _prefix = 'score_';

  String _key(String username) => '$_prefix$username';

  @override
  Future<ScoreState> getScore(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(username));

    if (raw == null) {
      return ScoreState.empty;
    }

    return ScoreState.fromJson(jsonDecode(raw));
  }

  @override
  Future<ScoreState> submitScore(String username, int score) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getScore(username);

    final updated = current.copyWith(
      lastScore: score,
      gamesPlayed: current.gamesPlayed + 1,
      bestScore: score > current.bestScore ? score : current.bestScore,
    );

    await prefs.setString(_key(username), jsonEncode(updated.toJson()));
    return updated;
  }

  @override
  Future<void> reset(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(username));
  }
}
