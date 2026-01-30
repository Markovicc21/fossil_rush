class ShopState {
  final int coins;
  final Set<String> owned;
  final String activeId;

  const ShopState({
    required this.coins,
    required this.owned,
    required this.activeId,
  });

  ShopState copyWith({int? coins, Set<String>? owned, String? activeId}) {
    return ShopState(
      coins: coins ?? this.coins,
      owned: owned ?? this.owned,
      activeId: activeId ?? this.activeId,
    );
  }
}
