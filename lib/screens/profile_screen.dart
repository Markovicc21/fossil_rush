import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/back_button.dart';
import '../widgets/retro_panel.dart';

//  PROFILE SCREEN (glavni ekran profila)
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  static const routeName = '/profile';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.repo.session(),
      builder: (context, snap) {
        // LOADING STATE
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ERROR STATE
        if (snap.hasError) {
          return Scaffold(
            body: Center(
              child: Text(
                'Session error: ${snap.error}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        //  NO SESSION / NO USERNAME STATE
        if (!snap.hasData || snap.data?.username == null) {
          return const Scaffold(
            body: Center(
              child: Text('No session', style: TextStyle(color: Colors.white)),
            ),
          );
        }

        // OK: session postoji -> uzimam username
        final username = snap.data!.username.toLowerCase();

        //  2) Placeholder vrednosti za statistiku (za sada 0)
        //  Kasnije ovde ide pravi data iz baze/local storage

        const bestScore = 0;
        const gamesPlayed = 0;
        const dinosCaught = 0;

        //  3) Glavni UI ekrana:
        //  - Stack: pozadina slika + UI preko nje

        return Scaffold(
          body: Stack(
            children: [
              // POZADINA PREKO CELOG EKRANA
              Positioned.fill(
                child: Image.asset(
                  'assets/images/jurassic.jpg',
                  fit: BoxFit.cover,
                ),
              ),

              // UI
              SafeArea(
                // LayoutBuilder -> računam responsive širine panela
                child: LayoutBuilder(
                  builder: (context, c) {
                    // ----------------------------------------------
                    //  headerW: širina gornjeg panela (avatar + username)
                    //  cardW: širina stats/achievements panela
                    //  clamp() da ne postane preveliko ili premalo
                    // ----------------------------------------------
                    final headerW = (c.maxWidth * 0.92)
                        .clamp(320.0, 440.0)
                        .toDouble();

                    final cardW = (c.maxWidth * 0.82)
                        .clamp(280.0, 420.0)
                        .toDouble();

                    //  Centriram sadržaj i ograničavam max širinu
                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),

                          //  GLAVNA KOLONA EKRANA
                          //  1) top bar (EXIT + PROFILE)
                          //  2) ostatak ekrana -> 3 panela
                          child: Column(
                            children: [
                              //  TOP BAR
                              _topBar(context),
                              const SizedBox(height: 10),

                              // OSTATK EKRANA (3 PANELA)
                              Expanded(
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Column(
                                    children: [
                                      //  PANEL 1: HEADER (avatar + username)
                                      Align(
                                        alignment: Alignment.topCenter,
                                        child: _panel(
                                          width: headerW,
                                          minHeight: 200,
                                          padding: const EdgeInsets.fromLTRB(
                                            18, // LEFT
                                            20, // TOP
                                            18, // RIGHT
                                            20, // BOTTOM
                                          ),

                                          // Sadržaj header panela
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Center(
                                                child: SizedBox(
                                                  width: 104,
                                                  height: 104,
                                                  child: RetroPanel(
                                                    fill: const Color(
                                                      0xFFD6B48A,
                                                    ),
                                                    padding:
                                                        const EdgeInsets.all(
                                                          12,
                                                        ),
                                                    shadowOffset: 2,
                                                    child: const Center(
                                                      child: Icon(
                                                        Icons.person,
                                                        size: 54,
                                                        color: Color(
                                                          0xFF2A1A12,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              const SizedBox(height: 14),

                                              // Username iz session-a
                                              Center(
                                                child: Text(
                                                  username,
                                                  style: const TextStyle(
                                                    fontSize: 30,
                                                    color: Color(0xFFFFE7C2),
                                                    shadows: [
                                                      Shadow(
                                                        offset: Offset(2, 2),
                                                        color: Color(
                                                          0xFF2A1A12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 26),

                                      //  PANEL 2: STATS (3 reda)
                                      Align(
                                        alignment: Alignment.topCenter,
                                        child: _panel(
                                          width: cardW,
                                          minHeight: 220,
                                          padding: const EdgeInsets.fromLTRB(
                                            18, // LEFT
                                            16, // TOP
                                            18, // RIGHT
                                            18, // BOTTOM
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Naslov sekcije
                                              const _SectionTitle(
                                                'STATS',
                                                fontSize: 20,
                                              ),

                                              const SizedBox(height: 14),

                                              // Red 1
                                              _statRowBig(
                                                icon: Icons.emoji_events,
                                                label: 'BEST SCORE',
                                                value: '$bestScore',
                                              ),

                                              const SizedBox(height: 16),

                                              // Red 2
                                              _statRowBig(
                                                icon: Icons.videogame_asset,
                                                label: 'GAMES PLAYED',
                                                value: '$gamesPlayed',
                                              ),

                                              const SizedBox(height: 16),

                                              // Red 3
                                              _statRowBig(
                                                icon: Icons.pets,
                                                label: 'DINOS CAUGHT',
                                                value: '$dinosCaught',
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 18),

                                      //  PANEL 3: ACHIEVEMENTS
                                      Align(
                                        alignment: Alignment.topCenter,
                                        child: _panel(
                                          width: cardW,
                                          padding: const EdgeInsets.fromLTRB(
                                            16, // LEFT
                                            12, // TOP
                                            16, // RIGHT
                                            12, // BOTTOM
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Naslov sekcije
                                              const _SectionTitle(
                                                'ACHIEVEMENTS',
                                                fontSize: 16,
                                              ),

                                              const SizedBox(height: 10),

                                              // Achievement kutije
                                              Row(
                                                children: const [
                                                  Expanded(
                                                    child: _AchBox(
                                                      title: 'PRO',
                                                      icon: Icons.star,
                                                    ),
                                                  ),
                                                  SizedBox(width: 12),
                                                  Expanded(
                                                    child: _AchBox(
                                                      title: 'COLLECTOR',
                                                      icon: Icons.emoji_events,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 10),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  //  TOP BAR (gore): EXIT dugme + naslov
  static Widget _topBar(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 46,
          height: 46,
          child: RetroPanel(
            fill: const Color(0xFF8B5A3C),
            padding: const EdgeInsets.all(6),
            shadowOffset: 2,

            child: Center(
              child: AppBackButton(
                asset: 'assets/images/ARROW_BACK.png',
                width: 18,
                height: 18,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
        ),

        const Expanded(
          child: Center(
            child: Text(
              'PROFILE',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFFFFE7C2),
                shadows: [
                  Shadow(offset: Offset(2, 2), color: Color(0xFF2A1A12)),
                ],
              ),
            ),
          ),
        ),

        // Desno: "balans" da naslov bude centriran
        const SizedBox(width: 40),
      ],
    );
  }

  //  _panel() = moj card helper
  //  - isti stil za header/stats/achievements
  //  - width: širina panela (headerW ili cardW)
  //  - minHeight: minimum visine (ako treba)
  //  - padding: unutrašnji razmak

  static Widget _panel({
    required double width,
    required EdgeInsets padding,
    required Widget child,
    double? minHeight,
  }) {
    return SizedBox(
      width: width,
      child: ConstrainedBox(
        constraints: minHeight != null
            ? BoxConstraints(minHeight: minHeight)
            : const BoxConstraints(),
        child: RetroPanel(
          fill: const Color(0xFF8B5A3C),
          padding: padding,
          child: child,
        ),
      ),
    );
  }

  //  _statRowBig() = jedan red statistike:
  //  [ikonica u boxu]  LABEL (levo)        VALUE (desno)

  static Widget _statRowBig({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        // Ikonica u maloj kutiji
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFD6B48A),
            border: Border.all(color: const Color(0xFF2A1A12), width: 2),
          ),
          child: Icon(icon, size: 26, color: const Color(0xFF2A1A12)),
        ),

        const SizedBox(width: 14),

        // Label
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFFFFE7C2),
              shadows: [Shadow(offset: Offset(1, 1), color: Color(0xFF2A1A12))],
            ),
          ),
        ),

        // Value
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFFFFE7C2),
            shadows: [Shadow(offset: Offset(1, 1), color: Color(0xFF2A1A12))],
          ),
        ),
      ],
    );
  }
}

//  _SectionTitle = mali widget samo za naslov sekcije
//  (STATS, ACHIEVEMENTS)
class _SectionTitle extends StatelessWidget {
  final String text;
  final double fontSize;

  const _SectionTitle(this.text, {this.fontSize = 14});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        color: const Color(0xFFFFE7C2),
        shadows: const [Shadow(offset: Offset(2, 2), color: Color(0xFF2A1A12))],
      ),
    );
  }
}

//  _AchBox = jedna achievement kutija (ikonica + tekst)
class _AchBox extends StatelessWidget {
  final String title;
  final IconData icon;

  const _AchBox({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: RetroPanel(
        fill: const Color(0xFFD6B48A),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        shadowOffset: 2,

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: const Color(0xFF2A1A12)),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF2A1A12),
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
