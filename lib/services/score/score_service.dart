import '../../models/score_state.dart';
import 'firebase_score_repository.dart';
import 'score_repository.dart';

class ScoreService {
  // isto kao kod ShopService: service drži repo unutra
  static final ScoreRepository repo = FirebaseScoreRepository();

  static Future<ScoreState> get(String userId) {
    return repo.getScore(userId);
  }

  static Future<ScoreState> submit(
    String userId,
    int score, {
    String? username,
  }) {
    return repo.submitScore(userId, score, username: username);
  }

  static Future<void> reset(String userId) {
    return repo.reset(userId);
  }

  static Future<List<ScoreEntry>> top({int limit = 50}) {
    return repo.getTop(limit: limit);
  }
}
