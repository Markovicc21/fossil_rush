import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'shop_models.dart';
import 'shop_repository.dart';

class FirebaseShopRepository implements ShopRepository {
  static const int _defaultCoins = 0;
  static const String _defaultActive = 'tard';
  static const Set<String> _defaultOwned = {'tard'};

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _doc(String userId) {
    return _db.collection('users').doc(userId).collection('shop').doc('state');
  }

  Map<String, dynamic> _toMap(ShopState s) => {
    'coins': s.coins,
    'owned': s.owned.toList(),
    'activeId': s.activeId,
  };

  ShopState _fromMap(Map<String, dynamic>? data) {
    final rawCoins = data?['coins'];
    final coins = (rawCoins is num) ? rawCoins.toInt() : _defaultCoins;

    final rawOwned = data?['owned'];
    final owned = (rawOwned is List)
        ? rawOwned.map((e) => e.toString()).toSet()
        : {..._defaultOwned};

    final activeId = (data?['activeId'] ?? _defaultActive).toString();

    return ShopState(coins: coins, owned: owned, activeId: activeId);
  }

  ShopState _defaultState() {
    return ShopState(
      coins: _defaultCoins,
      owned: {..._defaultOwned},
      activeId: _defaultActive,
    );
  }

  @override
  Future<ShopState> load(String userId) async {
    final ref = _doc(userId);
    final snap = await ref.get();
    if (!snap.exists) {
      final s = _defaultState();
      // fire-and-forget initial state to avoid blocking UI on first load
      unawaited(ref.set(_toMap(s)));
      return s;
    }
    return _fromMap(snap.data());
  }

  @override
  Future<ShopState> buy(
    String userId, {
    required String itemId,
    required int price,
  }) async {
    final ref = _doc(userId);

    return _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final current = snap.exists ? _fromMap(snap.data()) : _defaultState();

      if (current.owned.contains(itemId)) {
        return current;
      }
      if (current.coins < price) {
        return current;
      }

      final next = current.copyWith(
        coins: current.coins - price,
        owned: {...current.owned, itemId},
        activeId: itemId,
      );

      tx.set(ref, _toMap(next));
      return next;
    });
  }

  @override
  Future<ShopState> equip(String userId, {required String itemId}) async {
    final ref = _doc(userId);

    return _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final current = snap.exists ? _fromMap(snap.data()) : _defaultState();

      if (!current.owned.contains(itemId)) return current;

      final next = current.copyWith(activeId: itemId);
      tx.set(ref, _toMap(next));
      return next;
    });
  }
}
