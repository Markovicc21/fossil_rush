import 'package:flutter/material.dart';
import 'package:fossil_rush/screens/main_menu_screen.dart';
import 'package:fossil_rush/screens/register_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/game_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dino Quest',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),

      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (_) => const SplashScreen(),
        LoginScreen.routeName: (_) => const LoginScreen(),
        RegisterScreen.routeName: (_) => const RegisterScreen(),
        MainMenuScreen.routeName: (_) =>
            const MainMenuScreen(isLoggedin: false),
        '/main-menu-logged': (_) => const MainMenuScreen(isLoggedin: true),
        GameScreen.routeName: (_) => const GameScreen(),
      },
    );
  }
}
