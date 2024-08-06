import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer';
import 'dart:async';

class AuthService {
  static String? idToken;

  static Future<void> initializeIdToken(User user) async {
    idToken = await user.getIdToken();
    log("Initial idToken: $idToken");
  }
}
