import 'package:flutter/material.dart';
import 'package:frontend/pages/splash_screen.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/styles.dart';

class NoInternetPage extends StatelessWidget {
  const NoInternetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 100, color: Colors.red),
            const SizedBox(height: 20),
            const Text('No internet connection',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(
              width: MediaQuery.of(context).size.width *
                  0.8, // Chiếm 80% chiều rộng màn hình
              child: ElevatedButton.icon(
                style: AppStyles.primaryButtonStyle.copyWith(
                  backgroundColor: WidgetStateProperty.all(AppColors.cream),
                ),
                icon: const Icon(
                  Icons.refresh,
                  size: 32,
                ),
                label: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Try again',
                    style: TextStyle(fontSize: 24.0),
                  ),
                ),
                onPressed: () => {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const SplashScreen(),
                    ),
                  )
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
