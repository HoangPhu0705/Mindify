import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:frontend/auth/main_page.dart';
import 'package:frontend/utils/colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    final titleFontSize = screenSize.width * 0.1;
    return FlutterSplashScreen.scale(      
      backgroundColor: AppColors.ghostWhite,
      onInit: () {
        debugPrint("On Init");
      },
      onEnd: () {
        debugPrint("On End");
      },
      childWidget: Center(
        child: Text(
          "Mindify",
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: titleFontSize,
              ),
        ),
      ),
      onAnimationEnd: () => debugPrint("On Fade In End"),
      nextScreen: const MainPage(),
      duration: const Duration(milliseconds: 1500),
      animationDuration: const Duration(milliseconds: 1000),
    );
  }
}