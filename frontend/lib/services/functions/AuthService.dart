import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer';
import 'dart:async';

class AuthService {
  static String? idToken;

  static Future<void> initializeIdToken(User user) async {
    idToken = await user.getIdToken();
    log("Initial idToken: $idToken");
    // Refresh idToken periodically
    Timer.periodic(Duration(minutes: 1), (timer) async {
      idToken = await user.getIdToken(true);
      log("Refreshed idToken moi: $idToken");
    });
  }
}
