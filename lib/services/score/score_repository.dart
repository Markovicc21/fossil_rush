import '../../models/score_state.dart';

abstract class ScoreRepository {
  Future<ScoreState> getScore(String username);
  Future<ScoreState> submitScore(String username, int score);
  Future<void> reset(String username);
}
