import 'local_shop_repository.dart';
import 'shop_repository.dart';

import 'local_shop_catalog_repository.dart';
import 'shop_catalog_repository.dart';
import 'shop_models.dart';

class ShopService {
  // isto kao kod AuthService/ScoreService: service drži repo unutra
  static final ShopRepository repo = LocalShopRepository();

  // NOVO: katalog repo (admin + shop koriste isto)
  static final ShopCatalogRepository catalogRepo = LocalShopCatalogRepository();

  // ---------- KATALOG HELPERS ----------
  static Future<List<ShopItem>> getCatalog() {
    return catalogRepo.loadCatalog();
  }

  static Future<void> saveCatalog(List<ShopItem> items) {
    return catalogRepo.saveCatalog(items);
  }

  static Future<void> resetCatalog() {
    return catalogRepo.resetToDefault();
  }
}
