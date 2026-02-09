import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/score_state.dart';
import 'score_repository.dart';

class FirebaseScoreRepository implements ScoreRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('scores');

  ScoreState _fromData(Map<String, dynamic>? data) {
    if (data == null) return ScoreState.empty;
    final best = data['bestScore'];
    final last = data['lastScore'];
    final games = data['gamesPlayed'];
    final time = data['timePlayedSec'];

    return ScoreState(
      bestScore: (best is num) ? best.toInt() : 0,
      lastScore: (last is num) ? last.toInt() : 0,
      gamesPlayed: (games is num) ? games.toInt() : 0,
      timePlayedSec: (time is num) ? time.toInt() : 0,
    );
  }

  @override
  Future<ScoreState> getScore(String userId) async {
    final snap = await _col.doc(userId).get();
    if (!snap.exists) return ScoreState.empty;
    return _fromData(snap.data());
  }

  @override
  Future<ScoreState> submitScore(
    String userId,
    int score, {
    String? username,
    int timePlayedSec = 0,
  }) async {
    final ref = _col.doc(userId);

    return _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final current = snap.exists ? _fromData(snap.data()) : ScoreState.empty;

      final updated = current.copyWith(
        lastScore: score,
        gamesPlayed: current.gamesPlayed + 1,
        bestScore: score > current.bestScore ? score : current.bestScore,
        timePlayedSec: current.timePlayedSec + timePlayedSec,
      );

      final data = <String, dynamic>{
        ...updated.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (username != null && username.isNotEmpty) {
        data['username'] = username;
      }

      tx.set(ref, data, SetOptions(merge: true));
      return updated;
    });
  }

  @override
  Future<void> reset(String userId) async {
    await _col.doc(userId).delete();
  }

  @override
  Future<List<ScoreEntry>> getTop({int limit = 50}) async {
    final snap = await _col
        .orderBy('bestScore', descending: true)
        .limit(limit)
        .get();

    return snap.docs.map((d) {
      final data = d.data();
      final best = data['bestScore'];
      final last = data['lastScore'];
      final games = data['gamesPlayed'];
      final username = (data['username'] ?? d.id).toString();
      return ScoreEntry(
        userId: d.id,
        username: username,
        bestScore: (best is num) ? best.toInt() : 0,
        lastScore: (last is num) ? last.toInt() : 0,
        gamesPlayed: (games is num) ? games.toInt() : 0,
      );
    }).toList();
  }
}
