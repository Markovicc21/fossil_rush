import 'shop_repository.dart';
import 'local_shop_repository.dart';

class ShopService {
  ShopService._();
  static final ShopRepository repo = LocalShopRepository();

  // kasnije: static final ShopRepository repo = ApiShopRepository();
}
