import 'package:flutter/material.dart';
import 'package:frontend/pages/splash_screen.dart';

class NoInternetPage extends StatelessWidget {
  const NoInternetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off, 
              size: 100, 
              color: Colors.red),
            const SizedBox(height: 20),
            const Text(
                'No internet connection',
                style: TextStyle(fontSize: 24, 
                fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const SplashScreen(),
                  ),
                );
              },
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
