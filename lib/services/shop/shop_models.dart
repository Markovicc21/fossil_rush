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

class ShopItem {
  final String id;
  final String name;
  final int price;
  final String assetPath;
  final bool enabled;

  const ShopItem({
    required this.id,
    required this.name,
    required this.price,
    required this.assetPath,
    this.enabled = true,
  });

  ShopItem copyWith({
    String? id,
    String? name,
    int? price,
    String? assetPath,
    bool? enabled,
  }) {
    return ShopItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      assetPath: assetPath ?? this.assetPath,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'assetPath': assetPath,
    'enabled': enabled,
  };

  factory ShopItem.fromJson(Map<String, dynamic> json) {
    return ShopItem(
      id: (json['id'] ?? '') as String,
      name: (json['name'] ?? '') as String,
      price: (json['price'] ?? 0) as int,
      assetPath: (json['assetPath'] ?? '') as String,
      enabled: (json['enabled'] ?? true) as bool,
    );
  }
}
