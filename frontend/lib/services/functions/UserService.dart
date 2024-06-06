import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  //Chi nen su dung service nay khi da login
  User get user => FirebaseAuth.instance.currentUser!;

  String getUsername() {
    return user.displayName ?? "Mindify Member";
  }

  Future<void> updateUsername(String newDisplayName) async {
    await user.updateDisplayName(newDisplayName);
  }

  //Change password with validating the old password
  Future<String> changePassword(
      String currentPassword, String newPassword) async {
    final cred = EmailAuthProvider.credential(
        email: user.email!, password: currentPassword);
    try {
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);
      return "";
    } catch (err) {
      print("Lỗi $err");
      return "Wrong current password";
    }
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
  }
}
