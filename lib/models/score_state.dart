class ScoreState {
  final int bestScore;
  final int lastScore;
  final int gamesPlayed;
  final int timePlayedSec;

  const ScoreState({
    required this.bestScore,
    required this.lastScore,
    required this.gamesPlayed,
    required this.timePlayedSec,
  });

  ScoreState copyWith({
    int? bestScore,
    int? lastScore,
    int? gamesPlayed,
    int? timePlayedSec,
  }) {
    return ScoreState(
      bestScore: bestScore ?? this.bestScore,
      lastScore: lastScore ?? this.lastScore,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      timePlayedSec: timePlayedSec ?? this.timePlayedSec,
    );
  }

  Map<String, dynamic> toJson() => {
    'bestScore': bestScore,
    'lastScore': lastScore,
    'gamesPlayed': gamesPlayed,
    'timePlayedSec': timePlayedSec,
  };

  factory ScoreState.fromJson(Map<String, dynamic> json) {
    return ScoreState(
      bestScore: (json['bestScore'] ?? 0) as int,
      lastScore: (json['lastScore'] ?? 0) as int,
      gamesPlayed: (json['gamesPlayed'] ?? 0) as int,
      timePlayedSec: (json['timePlayedSec'] ?? 0) as int,
    );
  }

  static const empty = ScoreState(
    bestScore: 0,
    lastScore: 0,
    gamesPlayed: 0,
    timePlayedSec: 0,
  );
}

class ScoreEntry {
  final String userId;
  final String username;
  final int bestScore;
  final int lastScore;
  final int gamesPlayed;

  const ScoreEntry({
    required this.userId,
    required this.username,
    required this.bestScore,
    required this.lastScore,
    required this.gamesPlayed,
  });
}
