import 'shop_models.dart';

abstract class ShopRepository {
  Future<ShopState> load(String username);

  Future<ShopState> buy(
    String username, {
    required String itemId,
    required int price,
  });

  Future<ShopState> equip(String username, {required String itemId});
}
