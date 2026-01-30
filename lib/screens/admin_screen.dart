import 'package:flutter/material.dart';
import 'package:fossil_rush/services/shop/shop_models.dart';
import 'package:fossil_rush/services/shop/shop_service.dart';
import 'package:fossil_rush/widgets/back_button.dart';
import 'package:fossil_rush/widgets/retro_panel.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});
  static const routeName = '/admin';

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  bool _loading = true;
  List<ShopItem> _items = const [];

  @override
  void initState() {
    super.initState();
    _loadCatalog(); // 🔥 podsetnik: učitavanje kataloga odmah pri ulasku u admin
  }

  Future<void> _loadCatalog() async {
    setState(() => _loading = true);

    try {
      final items = await ShopService.catalogRepo.loadCatalog();
      if (!mounted) return; // izbegni setState ako je ekran zatvoren
      setState(() => _items = items);
    } catch (_) {
      if (!mounted) return;
      setState(() => _items = const []);
    }

    // 🔥 podsetnik: BEZ return u finally (warning), samo ovako na kraju
    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _saveCatalog(List<ShopItem> next) async {
    setState(() => _items = next); // UI odmah osveži pre snimanja
    await ShopService.catalogRepo.saveCatalog(next);
  }

  void _handleBack() {
    final nav = Navigator.of(context);

    // 🔥 podsetnik: web refresh / direktan ulaz u /admin -> nema gde da popuje (blank)
    if (nav.canPop()) {
      nav.pop();
    } else {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  //=====================HEADER==========================
  Widget _header() {
    return Row(
      children: [
        RetroPanel(
          fill: const Color(0xFF8B5A3C),
          padding: const EdgeInsets.all(8),
          child: SizedBox(
            width: 18,
            height: 18,
            child: Center(
              child: AppBackButton(
                asset: 'assets/images/ARROW_BACK.png',
                width: 18,
                height: 18,
                onPressed: _handleBack,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'ADMIN',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              color: Color(0xFFF5F5F5),
              height: 1.0,
              shadows: [Shadow(offset: Offset(2, 2), color: Color(0xFF2A1A12))],
            ),
          ),
        ),
        const SizedBox(width: 52),
      ],
    );
  }

  //=====================RETRO DIALOG HELPERS ===============================
  Future<T?> _showRetroDialog<T>({
    required Widget Function(BuildContext ctx) builder,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (ctx) {
        final size = MediaQuery.of(ctx).size;

        return Center(
          // 🔥 podsetnik: Center + ConstrainedBox rešava fullscreen dialog na WEB-u
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 360,
              maxHeight: size.height * 0.6,
            ),
            child: Material(color: Colors.transparent, child: builder(ctx)),
          ),
        );
      },
    );
  }

  Widget _retroDialogShell({
    required String title,
    required Widget body,
    required List<Widget> actions,
  }) {
    return RetroPanel(
      fill: const Color(0xFFF1E9F1),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min, // da se panel skuplja po sadržaju
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              color: Color(0xFF2A1A12),
              height: 1.0,
              shadows: [Shadow(offset: Offset(2, 2), color: Color(0xFFB8A7B8))],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 2,
            color: const Color(0xFF2A1A12).withOpacity(0.35),
          ),
          const SizedBox(height: 12),

          // Flexible + scroll da ne razvuče dialog
          Flexible(child: SingleChildScrollView(child: body)),

          const SizedBox(height: 12),
          Container(
            height: 2,
            color: const Color(0xFF2A1A12).withOpacity(0.20),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: actions,
          ),
        ],
      ),
    );
  }

  Widget _retroField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF2A1A12),
            height: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        RetroPanel(
          fill: const Color(0xFFFFFFFF),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF2A1A12),
              height: 1.0,
            ),
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  Widget _retroActionButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6A58B6),
            height: 1.0,
            shadows: [Shadow(offset: Offset(1, 1), color: Color(0xFFB8A7B8))],
          ),
        ),
      ),
    );
  }

  //=======================RETRO TOGGLE ==========================
  Widget _retroToggle({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    const double w = 56;
    const double h = 26;

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: RetroPanel(
        fill: value ? const Color(0xFF5B57D6) : const Color(0xFF6B6B6B),
        padding: const EdgeInsets.all(3),
        child: SizedBox(
          width: w,
          height: h,
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  color: const Color(0xFF2A1A12).withOpacity(0.18),
                ),
              ),
              AnimatedAlign(
                duration: const Duration(milliseconds: 120),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                curve: Curves.linear,
                child: RetroPanel(
                  fill: const Color(0xFFF1E9F1),
                  padding: const EdgeInsets.all(2),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: Container(
                      color: const Color(0xFF2A1A12).withOpacity(0.10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //====================================ACTIONS==================================
  Future<void> _toggleEnabled(String id, bool enabled) async {
    final next = _items
        .map((e) => e.id == id ? e.copyWith(enabled: enabled) : e)
        .toList();
    await _saveCatalog(next);
  }

  //========================DELETE==================================================
  Future<void> _deleteItem(String id) async {
    // 🔥 podsetnik: OBAVEZNO _showRetroDialog (ne showDialog) da ne bude fullscreen na web
    final ok = await _showRetroDialog<bool>(
      builder: (ctx) {
        return _retroDialogShell(
          title: 'Delete item?',
          body: const Text(
            'This will delete item\nfrom the catalog.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF2A1A12),
              height: 1.2,
            ),
          ),
          actions: [
            _retroActionButton(
              text: 'Cancel',
              onPressed: () => Navigator.pop(ctx, false),
            ),
            _retroActionButton(
              text: 'Delete',
              onPressed: () => Navigator.pop(ctx, true),
            ),
          ],
        );
      },
    );

    if (ok != true) return;

    final next = _items.where((e) => e.id != id).toList();
    await _saveCatalog(next);
  }

  //=========================EDIT===============================================
  Future<void> _editItem(ShopItem item) async {
    final nameCtrl = TextEditingController(text: item.name);
    final priceCtrl = TextEditingController(text: item.price.toString());

    final updated = await _showRetroDialog<ShopItem>(
      builder: (ctx) {
        return _retroDialogShell(
          title: 'Edit item',
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _retroField(label: 'Name', controller: nameCtrl),
              const SizedBox(height: 12),
              _retroField(
                label: 'Price',
                controller: priceCtrl,
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            _retroActionButton(
              text: 'Cancel',
              onPressed: () => Navigator.pop(ctx),
            ),
            _retroActionButton(
              text: 'Save',
              onPressed: () {
                final name = nameCtrl.text.trim();
                final price = int.tryParse(priceCtrl.text.trim()) ?? item.price;

                if (name.isEmpty) {
                  Navigator.pop(ctx);
                  return;
                }

                Navigator.pop(ctx, item.copyWith(name: name, price: price));
              },
            ),
          ],
        );
      },
    );

    if (updated == null) return;

    final next = _items.map((e) => e.id == item.id ? updated : e).toList();
    await _saveCatalog(next);
  }

  //===========================RESET=============================================
  Future<void> _resetCatalog() async {
    // 🔥 podsetnik: OBAVEZNO _showRetroDialog (ne showDialog) da ne bude fullscreen na web
    final ok = await _showRetroDialog<bool>(
      builder: (ctx) {
        return _retroDialogShell(
          title: 'Reset catalog?',
          body: const Text(
            'Returns default items\n(your 5 dinos)',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF2A1A12),
              height: 1.2,
            ),
          ),
          actions: [
            _retroActionButton(
              text: 'Cancel',
              onPressed: () => Navigator.pop(ctx, false),
            ),
            _retroActionButton(
              text: 'Reset',
              onPressed: () => Navigator.pop(ctx, true),
            ),
          ],
        );
      },
    );

    if (ok != true) return;

    setState(() => _loading = true);
    await ShopService.catalogRepo.resetToDefault();
    await _loadCatalog();
  }

  //================================UI BUILD EKRANA ====================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/jurassic.jpg', fit: BoxFit.cover),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        _header(),
                        const SizedBox(height: 10),
                        Expanded(
                          child: RetroPanel(
                            fill: const Color(0xFF8B5A3C),
                            padding: const EdgeInsets.all(12),
                            child: _items.isEmpty
                                ? const Center(
                                    child: Text(
                                      'Catalog is empty',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFFFFE7C2),
                                        height: 1.0,
                                      ),
                                    ),
                                  )
                                : ListView.separated(
                                    itemCount: _items.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 10),
                                    itemBuilder: (context, i) {
                                      final it = _items[i];
                                      return _adminRow(it);
                                    },
                                  ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _adminButton(
                                text: 'RESET CATALOG',
                                color: const Color(0xFFF2A23A),
                                onPressed: _resetCatalog,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  //===========================ADMIN IZGLED PRODUKTA KOJI SU U SHOPU =======================
  Widget _adminRow(ShopItem it) {
    return RetroPanel(
      fill: const Color(0xFFA56A43),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🔥 podsetnik: 2-redni layout da NIKAD ne bude RenderFlex overflow udesno
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 72, // malo manje da stane na mobilnom
                height: 56,
                child: Image.asset(
                  it.assetPath,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.none,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Text(
                      'NO IMG',
                      style: TextStyle(color: Colors.red, fontSize: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      it.name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFFFFE7C2),
                        height: 1.0,
                        shadows: [
                          Shadow(
                            offset: Offset(2, 2),
                            color: Color(0xFF2A1A12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'ID: ${it.id}\nPRICE: ${it.price}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFFFE7C2),
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              SizedBox(
                width: 86, // uži blok za dugmad
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _miniButton(
                      text: 'EDIT',
                      color: const Color(0xFF55B6FF),
                      onPressed: () => _editItem(it),
                    ),
                    const SizedBox(height: 8),
                    _miniButton(
                      text: 'DEL',
                      color: const Color(0xFFE85B5B),
                      onPressed: () => _deleteItem(it.id),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              const Text(
                'ENABLED',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFFFFE7C2),
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 8),
              _retroToggle(
                value: it.enabled,
                onChanged: (v) => _toggleEnabled(it.id, v),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //==================================EDIT/DEL DUGME LOGIKA==========================
  Widget _miniButton({
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: RetroPanel(
        fill: color,
        // 🔥 podsetnik: manji padding da stane u fiksnu širinu
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Center(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.clip,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF2A1A12),
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }

  //=================================SKRIVENO ADMIN DUGME IZA LOGOA===========================
  Widget _adminButton({
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: SizedBox(
        height: 48, // 🔥 podsetnik: pixel font = fiksna visina dugmeta
        child: RetroPanel(
          fill: color,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Center(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF2A1A12),
                height: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
