import '../../models/score_state.dart';

abstract class ScoreRepository {
  Future<ScoreState> getScore(String userId);
  Future<ScoreState> submitScore(
    String userId,
    int score, {
    String? username,
    int timePlayedSec = 0,
  });
  Future<void> reset(String userId);
  Future<List<ScoreEntry>> getTop({int limit = 50});
}
