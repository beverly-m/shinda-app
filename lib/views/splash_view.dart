import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shinda_app/main.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      duration: 3500,
      splash: LottieBuilder.asset('assets/Lottie/shopping_animation.json'),
      splashTransition: SplashTransition.fadeTransition,
      nextScreen: const InitApp(),
      splashIconSize: 200.0,
      backgroundColor: Colors.white,
    );
  }
}
