import 'shop_models.dart';

abstract class ShopRepository {
  Future<ShopState> load(String userId);

  Future<ShopState> buy(
    String userId, {
    required String itemId,
    required int price,
  });

  Future<ShopState> equip(String userId, {required String itemId});

  Future<ShopState> addCoins(String userId, {required int amount});
}
