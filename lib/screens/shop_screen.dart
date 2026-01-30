import 'package:flutter/material.dart';
import 'package:fossil_rush/widgets/back_button.dart';
import 'package:fossil_rush/widgets/retro_panel.dart';

// ======================== SHOP SCREEN ========================
// Ovde je ceo UI i logika shop-a:
// coins
// owned
// activeId
// toast poruke

// NOVO:
// - state se učitava i pamti po nalogu (SharedPreferences)
// - username uzimamo iz AuthService.repo.session()
// - buy/equip ide kroz ShopService.repo (LocalShopRepository)
// - katalog (lista dinosa) ide kroz ShopService.catalogRepo (LocalShopCatalogRepository)

import 'package:fossil_rush/services/auth/auth_service.dart';
import 'package:fossil_rush/services/shop/shop_service.dart';
import 'package:fossil_rush/services/shop/shop_models.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});
  static const routeName = '/shop';

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  // --------- USER / LOADING STATE ----------
  // username iz session-a (po njemu se čuva shop state)
  String? _username;

  // dok učitavamo shop state iz SharedPreferences
  bool _loading = true;

  // --------- GAME STATE (SADA NIJE HARDCODED) ----------
  // Trenutni broj coin-a (učitan po nalogu)
  int coins = 0;

  // Set kupljenih dinosa (učitan po nalogu)
  Set<String> owned = <String>{};

  // Trenutno aktivan dino (učitan po nalogu)
  String activeId = 'tard';

  // --------- TOAST STATE ----------
  // Tekst za toast (kad je null -> ne prikazuje se)
  String? _toastText;

  // Samo da “natera” novi key i restartuje animaciju toast-a
  int _toastTick = 0;

  // --------- SHOP CATALOG (NOVO) ----------
  // Svi itemi iz kataloga (admin menja ovo)
  List<ShopItem> _catalogAll = const [];

  // Prikazuj samo enabled iteme u shop listi
  List<ShopItem> get _itemsVisible =>
      _catalogAll.where((e) => e.enabled).toList();

  @override
  void initState() {
    super.initState();

    // NOVO: kad se ekran otvori -> uzmi session i učitaj shop state + katalog
    _initShopForUser();
  }

  // ---------------- INIT (load state po nalogu) ----------------
  Future<void> _initShopForUser() async {
    setState(() => _loading = true);

    // uzmi ulogovanog user-a iz AuthService
    final session = await AuthService.repo.session();
    if (!mounted) return;

    // ako nema session-a -> user nije ulogovan -> vrati nazad
    if (session == null) {
      setState(() => _loading = false);
      Navigator.of(context).pop();
      return;
    }

    final u = session.username.trim();

    // učitaj shop state iz ShopService.repo (LocalShopRepository)
    final ShopState s = await ShopService.repo.load(u);
    if (!mounted) return;

    // NOVO: učitaj katalog (lista itema) iz ShopService.catalogRepo
    final catalog = await ShopService.catalogRepo.loadCatalog();
    if (!mounted) return;

    // upiši u UI state
    setState(() {
      _username = u;
      coins = s.coins;
      owned = {...s.owned};
      activeId = s.activeId;
      _catalogAll = catalog;
      _loading = false;
    });
  }

  // ---------------- NAVIGACIJA ----------------
  // Back dugme -> vraća se na prethodni screen (pushNamed -> pop)
  void _handleBack() {
    Navigator.of(context).pop();
  }

  // ---------------- TOAST HELPER ----------------
  // Prikažem poruku i sklonim
  void _showToast(String text) {
    setState(() {
      _toastText = text;
      _toastTick++; // bitno: key se menja -> animacija krene iz početka
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _toastText = null);
    });
  }

  // ---------------- SHOP LOGIKA (BUY / EQUIP) ----------------
  // Ako nije kupljen -> kupi (ako ima coins)
  // Ako je kupljen -> equip
  void _onBuyOrEquip(ShopItem item) async {
    // NOVO: mora da postoji username (ulogovan user)
    if (_username == null) return;

    // dok učitavamo state, blokiraj klikove
    if (_loading) return;

    final isOwned = owned.contains(item.id);
    final isActive = activeId == item.id;

    // Ako je već aktivan -> ništa ne radi
    if (isActive) return;

    final u = _username!.trim();

    // Ako nije kupljen -> pokušaj kupovinu
    if (!isOwned) {
      // provera coins-a na UI state-u (brzo)
      if (coins < item.price) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Not enough coins')));
        return;
      }

      // NOVO: kupovina ide kroz repo -> upiše u SharedPreferences
      final next = await ShopService.repo.buy(
        u,
        itemId: item.id,
        price: item.price,
      );
      if (!mounted) return;

      // prepiši state iz repo rezultata
      setState(() {
        coins = next.coins;
        owned = {...next.owned};
        activeId = next.activeId;
      });

      _showToast('PURCHASED!');
      return;
    }

    // Ako je kupljen -> samo ga aktiviraj
    // NOVO: equip ide kroz repo -> upiše u SharedPreferences
    final next = await ShopService.repo.equip(u, itemId: item.id);
    if (!mounted) return;

    setState(() {
      coins = next.coins;
      owned = {...next.owned};
      activeId = next.activeId;
    });

    _showToast('EQUIPPED!');
  }

  // ======================== HEADER ========================
  // Gornji deo ekrana:
  // levo back dugme u RetroPanel-u
  // sredina naslov "DINO SHOP"
  // desno praznina da naslov ostane centriran
  Widget _header() {
    return Row(
      children: [
        // BACK dugme
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

        // NASLOV
        const Expanded(
          child: Text(
            'DINO SHOP',
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

  // ======================== ACTIVE CARD ========================
  // Kartica koja uvek pokazuje trenutno aktivnog dinosa
  // (čita iz activeId)
  Widget _activeCard() {
    // Nađi trenutno aktivnog u katalogu (i ako je disabled, i dalje ga pokaži)
    final active = _catalogAll.firstWhere(
      (e) => e.id == activeId,
      // safety: ako activeId nije nađen, uzmi prvog enabled ili prvog ikad
      orElse: () {
        final enabled = _catalogAll.where((e) => e.enabled).toList();
        if (enabled.isNotEmpty) return enabled.first;
        return _catalogAll.isNotEmpty
            ? _catalogAll.first
            : const ShopItem(
                id: 'none',
                name: 'None',
                price: 0,
                assetPath: 'assets/characters/tard/previewTard1.png',
                enabled: true,
              );
      },
    );

    // DEBUG: da vidimo koju putanju ovaj ekran stvarno pokušava da učita
    debugPrint('LOADING ACTIVE ASSET: ${active.assetPath}');

    return RetroPanel(
      fill: const Color(0xFF97C86E),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Preview aktivnog dinosa
          SizedBox(
            width: 140,
            height: 110,
            child: Image.asset(
              active.assetPath,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.none,
              errorBuilder: (context, error, stack) {
                debugPrint('ASSET FAIL (ACTIVE): ${active.assetPath}');
                debugPrint('ERROR (ACTIVE): $error');
                return const Center(
                  child: Text(
                    'NO IMG',
                    style: TextStyle(color: Colors.red, fontSize: 10),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),

          // Tekst info
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your dino',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2A1A12),
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Dugme ACTIVE
          SizedBox(
            width: 104,
            child: _pillButton(
              text: 'ACTIVE',
              enabled: false,
              color: const Color(0xFF2EC45A),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  // ======================== SHOP ROW (jedan item) ========================
  // Jedan red dinosa u listi:
  //  slika
  //  ime + cena
  // dugme BUY / EQUIP / ACTIVE
  Widget _shopRow({
    required ShopItem item,
    required bool isOwned,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    // Tekst dugmeta zavisi od stanja
    final String btnText = isActive ? 'ACTIVE' : (isOwned ? 'EQUIP' : 'BUY');
    final bool enabled = !isActive;

    // DEBUG: da vidimo koju putanju lista stvarno pokušava da učita
    debugPrint('LOADING ASSET: ${item.assetPath}');

    return RetroPanel(
      fill: const Color(0xFF8B5A3C),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Preview dinosa
          SizedBox(
            width: 104,
            height: 80,
            child: Image.asset(
              item.assetPath,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.none,
              errorBuilder: (context, error, stack) {
                debugPrint('ASSET FAIL: ${item.assetPath}');
                debugPrint('ERROR: $error');
                return const Center(
                  child: Text(
                    'NO IMG',
                    style: TextStyle(color: Colors.red, fontSize: 10),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),

          // Ime + cena
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFFFFE7C2),
                    height: 1.0,
                    shadows: [
                      Shadow(offset: Offset(2, 2), color: Color(0xFF2A1A12)),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${item.price} COINS',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFFFE7C2),
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // BUY/EQUIP/ACTIVE dugme
          SizedBox(
            width: 104,
            child: _pillButton(
              text: btnText,
              enabled: enabled,
              color: isActive
                  ? const Color(0xFF2EC45A)
                  : (isOwned
                        ? const Color(0xFF55B6FF)
                        : const Color(0xFFF2A23A)),
              onPressed: onTap,
            ),
          ),
        ],
      ),
    );
  }

  // ======================== FOOTER (coins info) ========================
  // Donji panel:
  //  broj coin-a
  //  owned count
  Widget _footerCoins() {
    return RetroPanel(
      fill: const Color(0xFF8B5A3C),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.monetization_on, color: Color(0xFFFFE7C2)),
          const SizedBox(width: 10),

          // COINS tekst
          Text(
            'COINS: $coins',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFFFFE7C2),
              height: 1.0,
              shadows: [Shadow(offset: Offset(2, 2), color: Color(0xFF2A1A12))],
            ),
          ),

          const Spacer(),

          // Owned broj (ukupan katalog je _catalogAll)
          Text(
            'Owned: ${owned.length}/${_catalogAll.length}',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFFFFE7C2),
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  // ======================== BUTTON HELPER ========================
  Widget _pillButton({
    required String text,
    required bool enabled,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return _AnimatedPillButton(
      text: text,
      enabled: enabled,
      color: color,
      onPressed: onPressed,
    );
  }

  //=================== PRIKAZ EKRANA (build) ============================
  // Layout ide ovim redom:
  // 1) Pozadina (jurassic.jpg)
  // 2) SafeArea + padding
  // 3) Column: header -> activeCard -> lista -> footer
  // 4) Toast overlay (ako postoji)
  //
  // NOVO:
  // - dok učitava state -> spinner (da se ne vidi “reset”)
  @override
  Widget build(BuildContext context) {
    final visibleItems = _itemsVisible;

    return Scaffold(
      body: Stack(
        children: [
          // BACKGROUND
          Positioned.fill(
            child: Image.asset('assets/images/jurassic.jpg', fit: BoxFit.cover),
          ),

          // MAIN UI
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        _header(),
                        const SizedBox(height: 10),

                        _activeCard(),
                        const SizedBox(height: 10),

                        // Scroll lista itema (samo enabled)
                        Expanded(
                          child: visibleItems.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No items enabled',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFFFE7C2),
                                      height: 1.0,
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.all(12),
                                  itemCount: visibleItems.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 10),
                                  itemBuilder: (context, index) {
                                    final item = visibleItems[index];
                                    final isOwned = owned.contains(item.id);
                                    final isActive = activeId == item.id;

                                    return _shopRow(
                                      item: item,
                                      isOwned: isOwned,
                                      isActive: isActive,
                                      onTap: () => _onBuyOrEquip(item),
                                    );
                                  },
                                ),
                        ),

                        const SizedBox(height: 10),

                        _footerCoins(),
                      ],
                    ),
            ),
          ),

          // TOAST OVERLAY
          if (_toastText != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 80,
              child: Center(
                child: _FloatingToast(
                  key: ValueKey(_toastTick),
                  text: _toastText!,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
// ========================= KRAJ ShopScreen ============================

// ======================== ANIMATED BUTTON ========================
//  dugme BUY/EQUIP
class _AnimatedPillButton extends StatefulWidget {
  final String text;
  final bool enabled;
  final Color color;
  final VoidCallback onPressed;

  const _AnimatedPillButton({
    required this.text,
    required this.enabled,
    required this.color,
    required this.onPressed,
  });

  @override
  State<_AnimatedPillButton> createState() => _AnimatedPillButtonState();
}

class _AnimatedPillButtonState extends State<_AnimatedPillButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Tap down = dugme “utonulo”
      onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,

      // Tap up = vrati dugme i pozovi onPressed
      onTapUp: widget.enabled
          ? (_) {
              setState(() => _pressed = false);
              widget.onPressed();
            }
          : null,

      // Cancel = vrati dugme nazad
      onTapCancel: widget.enabled
          ? () => setState(() => _pressed = false)
          : null,

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,

        // press efekat (pomeri nadole)
        transform: Matrix4.translationValues(0, _pressed ? 2.5 : 0, 0),

        // BITNO: alignment da tekst bude centriran u dugmetu
        alignment: Alignment.center,

        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.zero, // oštri uglovi
          border: Border.all(color: const Color(0xFF2A1A12), width: 3),

          // Hard shadow + pomeraj kad se pritisne
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2A1A12),
              offset: Offset(0, _pressed ? 1 : 3),
              blurRadius: 0,
            ),
          ],
        ),

        child: Text(
          widget.text,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.clip,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF2A1A12),
            height: 1.0,
          ),
        ),
      ),
    );
  }
}

// ======================== FLOATING TOAST ========================
// poruka koja izleti gore
class _FloatingToast extends StatefulWidget {
  final String text;
  const _FloatingToast({super.key, required this.text});

  @override
  State<_FloatingToast> createState() => _FloatingToastState();
}

class _FloatingToastState extends State<_FloatingToast>
    with SingleTickerProviderStateMixin {
  // Kontroler animacije toast-a
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  )..forward();

  // Fade in
  late final Animation<double> _opacity = CurvedAnimation(
    parent: _c,
    curve: Curves.easeOut,
  );

  // Slide up
  late final Animation<double> _dy = Tween<double>(
    begin: 12,
    end: 0,
  ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutBack));

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.translate(
            offset: Offset(0, _dy.value),
            child: RetroPanel(
              fill: const Color(0xFF2EC45A),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                widget.text,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF2A1A12),
                  height: 1.0,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
