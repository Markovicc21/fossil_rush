class ScoreState {
  final int bestScore;
  final int lastScore;
  final int gamesPlayed;

  const ScoreState({
    required this.bestScore,
    required this.lastScore,
    required this.gamesPlayed,
  });

  ScoreState copyWith({int? bestScore, int? lastScore, int? gamesPlayed}) {
    return ScoreState(
      bestScore: bestScore ?? this.bestScore,
      lastScore: lastScore ?? this.lastScore,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
    );
  }

  Map<String, dynamic> toJson() => {
    'bestScore': bestScore,
    'lastScore': lastScore,
    'gamesPlayed': gamesPlayed,
  };

  factory ScoreState.fromJson(Map<String, dynamic> json) {
    return ScoreState(
      bestScore: (json['bestScore'] ?? 0) as int,
      lastScore: (json['lastScore'] ?? 0) as int,
      gamesPlayed: (json['gamesPlayed'] ?? 0) as int,
    );
  }

  static const empty = ScoreState(bestScore: 0, lastScore: 0, gamesPlayed: 0);
}
