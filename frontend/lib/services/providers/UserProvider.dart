import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String displayName =
      FirebaseAuth.instance.currentUser!.displayName ?? "Mindify Member";

  void setDisplayName(String name) {
    displayName = name;
    notifyListeners();
  }
}
