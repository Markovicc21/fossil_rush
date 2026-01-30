import 'package:flutter/material.dart';

class ScreenSlider {
  /// Full slide: novi ekran ulazi s desna, stari izlazi ulevo
  static Route<T> slide<T>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 999),
    Curve curve = Curves.easeOutCubic,
  }) {
    return PageRouteBuilder<T>(
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        // Novi ekran: desno -> centar
        final inAnim = Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: curve));

        // Trenutni ekran (ispod): centar -> levo (dok novi ulazi)
        final outAnim = Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(-1.0, 0.0),
        ).animate(CurvedAnimation(parent: secondaryAnimation, curve: curve));

        return SlideTransition(
          position: outAnim,
          child: SlideTransition(position: inAnim, child: child),
        );
      },
    );
  }

  /// Vertikalni slide ako nekad zatreba
  static Route<T> slideUp<T>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 320),
    Curve curve = Curves.easeOutCubic,
  }) {
    return PageRouteBuilder<T>(
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        final inAnim = Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: curve));

        final outAnim = Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0.0, -1.0),
        ).animate(CurvedAnimation(parent: secondaryAnimation, curve: curve));

        return SlideTransition(
          position: outAnim,
          child: SlideTransition(position: inAnim, child: child),
        );
      },
    );
  }
}
