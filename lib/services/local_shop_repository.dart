import 'package:shared_preferences/shared_preferences.dart';
import 'shop_models.dart';
import 'shop_repository.dart';

class LocalShopRepository implements ShopRepository {
  // defaulti kad user prvi put uđe u shop
  static const int _defaultCoins = 1000;
  static const String _defaultOwned = 'tard'; // prvi free dino
  static const String _defaultActive = 'tard';

  String _kCoins(String u) => 'shop_coins_$u';
  String _kOwned(String u) => 'shop_owned_$u'; // string: "tard,cole"
  String _kActive(String u) => 'shop_active_$u';

  Set<String> _decodeOwned(String raw) {
    if (raw.trim().isEmpty) return <String>{};
    return raw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet();
  }

  String _encodeOwned(Set<String> owned) => owned.join(',');

  Future<ShopState> _ensureInitialized(String u) async {
    final sp = await SharedPreferences.getInstance();

    // ako user nema ništa sačuvano -> upiši default jednom
    if (!sp.containsKey(_kCoins(u)) ||
        !sp.containsKey(_kOwned(u)) ||
        !sp.containsKey(_kActive(u))) {
      await sp.setInt(_kCoins(u), _defaultCoins);
      await sp.setString(_kOwned(u), _defaultOwned);
      await sp.setString(_kActive(u), _defaultActive);
    }

    return load(u);
  }

  @override
  Future<ShopState> load(String username) async {
    final u = username.trim();
    final sp = await SharedPreferences.getInstance();

    if (!sp.containsKey(_kCoins(u)) ||
        !sp.containsKey(_kOwned(u)) ||
        !sp.containsKey(_kActive(u))) {
      return _ensureInitialized(u);
    }

    final coins = sp.getInt(_kCoins(u)) ?? _defaultCoins;
    final ownedRaw = sp.getString(_kOwned(u)) ?? _defaultOwned;
    final activeId = sp.getString(_kActive(u)) ?? _defaultActive;

    return ShopState(
      coins: coins,
      owned: _decodeOwned(ownedRaw),
      activeId: activeId,
    );
  }

  Future<void> _save(String u, ShopState s) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_kCoins(u), s.coins);
    await sp.setString(_kOwned(u), _encodeOwned(s.owned));
    await sp.setString(_kActive(u), s.activeId);
  }

  @override
  Future<ShopState> buy(
    String username, {
    required String itemId,
    required int price,
  }) async {
    final u = username.trim();
    final s = await load(u);

    if (s.owned.contains(itemId)) {
      // već kupljeno -> samo vrati state
      return s;
    }
    if (s.coins < price) {
      // nema dovoljno -> ne menjam state
      return s;
    }

    final next = s.copyWith(
      coins: s.coins - price,
      owned: {...s.owned, itemId},
      activeId: itemId, // posle kupovine auto-equip
    );

    await _save(u, next);
    return next;
  }

  @override
  Future<ShopState> equip(String username, {required String itemId}) async {
    final u = username.trim();
    final s = await load(u);

    if (!s.owned.contains(itemId)) return s; // ne može equip ako nije owned

    final next = s.copyWith(activeId: itemId);
    await _save(u, next);
    return next;
  }
}
