import '../models/score_state.dart';
import 'local_score_repository.dart';
import 'score_repository.dart';

class ScoreService {
  // isto kao kod ShopService: service drži repo unutra
  static final ScoreRepository repo = LocalScoreRepository();

  static Future<ScoreState> get(String username) {
    return repo.getScore(username);
  }

  static Future<ScoreState> submit(String username, int score) {
    return repo.submitScore(username, score);
  }

  static Future<void> reset(String username) {
    return repo.reset(username);
  }
}
