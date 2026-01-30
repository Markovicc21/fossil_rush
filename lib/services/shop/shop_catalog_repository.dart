import 'shop_models.dart';

abstract class ShopCatalogRepository {
  Future<List<ShopItem>> loadCatalog();
  Future<void> saveCatalog(List<ShopItem> items);
  Future<void> resetToDefault();
}
