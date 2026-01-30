import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'shop_catalog_repository.dart';
import 'shop_models.dart';

class LocalShopCatalogRepository implements ShopCatalogRepository {
  static const _key = 'shop_catalog_v1';

  @override
  Future<List<ShopItem>> loadCatalog() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);

    if (raw == null) {
      final defaults = _defaultItems();
      await saveCatalog(defaults);
      return defaults;
    }

    final List list = jsonDecode(raw);
    return list.map((e) => ShopItem.fromJson(e)).toList();
  }

  @override
  Future<void> saveCatalog(List<ShopItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_key, json);
  }

  @override
  Future<void> resetToDefault() async {
    await saveCatalog(_defaultItems());
  }

  List<ShopItem> _defaultItems() {
    return const [
      ShopItem(
        id: 'tard',
        name: 'Tard',
        price: 0,
        assetPath: 'assets/characters/tard/previewTard1.png',
        enabled: true,
      ),
      ShopItem(
        id: 'cole',
        name: 'Cole',
        price: 200,
        assetPath: 'assets/characters/cole/previewCole1.png',
        enabled: true,
      ),
      ShopItem(
        id: 'mort',
        name: 'Mort',
        price: 500,
        assetPath: 'assets/characters/mort/previewMort1.png',
        enabled: true,
      ),
      ShopItem(
        id: 'mono',
        name: 'Mono',
        price: 350,
        assetPath: 'assets/characters/mono/previewMono1.png',
        enabled: true,
      ),
      ShopItem(
        id: 'kuro',
        name: 'Kuro',
        price: 1000,
        assetPath: 'assets/characters/kuro/previewKuro1.png',
        enabled: true,
      ),
    ];
  }
}
