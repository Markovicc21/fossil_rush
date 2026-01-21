import 'package:flutter/material.dart';

import 'main_menu_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const routeName = '/splash';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<double> _fadeOut;

  bool _didPrecache = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4700),
    );

    _fadeIn = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.64, curve: Curves.easeIn),
    );

    _fadeOut = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.79, 1.0, curve: Curves.easeOut),
    );

    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Navigator.of(
          context,
        ).pushReplacement(_fadeRoute(const MainMenuScreen(isLoggedin: false)));
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didPrecache) {
      _didPrecache = true;
      precacheImage(const AssetImage('assets/images/logo.png'), context);
      precacheImage(const AssetImage('assets/images/jurassic.png'), context);
    }
  }

  Route _fadeRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 450),
      pageBuilder: (_, animation, __) => page,
      transitionsBuilder: (_, animation, __, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(opacity: curved, child: child);
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            final opacity = _fadeIn.value * (1.0 - _fadeOut.value);
            return Opacity(
              opacity: opacity,
              child: Image.asset(
                'assets/images/logo.png',
                width: 300,
                height: 300,
              ),
            );
          },
        ),
      ),
    );
  }
}
