import 'package:cloud_firestore/cloud_firestore.dart';

import 'shop_catalog_repository.dart';
import 'shop_models.dart';

class FirebaseShopCatalogRepository implements ShopCatalogRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('shop_catalog');

  @override
  Future<List<ShopItem>> loadCatalog() async {
    final snap = await _col.orderBy(FieldPath.documentId).get();
    if (snap.docs.isEmpty) {
      // If catalog is empty, return defaults (do not write here).
      return _defaultItems();
    }

    return snap.docs.map((d) {
      final data = d.data();
      return ShopItem.fromJson({
        'id': d.id,
        'name': data['name'],
        'price': data['price'],
        'assetPath': data['assetPath'],
        'enabled': data['enabled'],
      });
    }).toList();
  }

  @override
  Future<void> saveCatalog(List<ShopItem> items) async {
    final snap = await _col.get();
    final existingIds = snap.docs.map((d) => d.id).toSet();
    final nextIds = items.map((e) => e.id).toSet();

    final batch = _db.batch();

    // delete removed
    for (final id in existingIds.difference(nextIds)) {
      batch.delete(_col.doc(id));
    }

    // upsert current
    for (final it in items) {
      batch.set(_col.doc(it.id), it.toJson());
    }

    await batch.commit();
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
