import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:frontend/auth/main_page.dart';
import 'package:frontend/pages/no_internet/no_internet_page.dart';
import 'package:frontend/utils/colors.dart';
import 'dart:developer';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
  }

  // Future<void> _checkInternetConnection() async {
  //   log("Checking internet connection...");
  //   var connectivityResult = await Connectivity().checkConnectivity();
  //   if (connectivityResult == ConnectivityResult.none) {
  //     log("No internet connection detected.");
  //     _navigateToNoInternetPage();
  //   } else {
  //     log("Internet connection available.");
  //     _proceedToMainPage();
  //   }
  // }
  Future<void> _checkInternetConnection() async {
  log("Checking internet connection...");
  List<ConnectivityResult> connectivityResults = await Connectivity().checkConnectivity();
  log("Connectivity Results: $connectivityResults");

  if (connectivityResults.contains(ConnectivityResult.none)) {
    log("No internet connection detected.");
    _navigateToNoInternetPage();
  } else {
    log("Internet connection available.");
    _proceedToMainPage();
  }
}





  void _navigateToNoInternetPage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const NoInternetPage()),
      );
    });
  }

  void _proceedToMainPage() {
    Future.delayed(Duration(milliseconds: 1500), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainPage()),
      );
    });
  }

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
      duration: const Duration(milliseconds: 1500),
      animationDuration: const Duration(milliseconds: 1000),
    );
  }
}
