import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer';
import 'dart:async';

class AuthService {
  static String? idToken;

  static Future<String> initializeIdToken(User user) async {
    idToken = await user.getIdToken();
    log("Initial idToken: $idToken");
    // Refresh idToken periodically
    // Timer.periodic(Duration(minutes: 50), (timer) async {
    //   idToken = await user.getIdToken(true);
    //   log("Refreshed idToken: $idToken");
    // });
    return idToken!;
  }
}
