import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/services/functions/UserService.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService = UserService();

  String displayName =
      FirebaseAuth.instance.currentUser!.displayName ?? "Mindify Member";

  String photoUrl = FirebaseAuth.instance.currentUser!.photoURL ??
      "https://avatar.iran.liara.run/public/boy";

  void setDisplayName(String name) {
    displayName = name;
    notifyListeners();
  }

  void setPhotoUrl(String url) {
    photoUrl = url;
    notifyListeners();
  }

  // Future<void> resetPassword(String email) async {
  //   try {
  //     await _userService.resetPassword(email);
  //     notifyListeners();
  //   } catch (e) {
  //     print("Error resetting password: $e");
  //     throw e;
  //   }
  // }
}
