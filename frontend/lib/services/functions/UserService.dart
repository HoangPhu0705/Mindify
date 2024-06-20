import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class UserService {
  //Chi nen su dung service nay khi da login
  User get user => FirebaseAuth.instance.currentUser!;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String getUserId() {
    return user.uid!;
  }

  String getUsername() {
    return user.displayName ?? "Mindify Member";
  }

  String getPhotoUrl() {
    return user.photoURL ?? "";
  }

  Future<void> updateUsername(String newDisplayName) async {
    await user.updateDisplayName(newDisplayName);
  }

  Future<void> updateAvatar(String newPhotoUrl) async {
    await user.updatePhotoURL(newPhotoUrl);
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

  //update profile url

  Future<Uint8List?> getProfileImage(String userId) async {
    final storageRef = FirebaseStorage.instance.ref();
    final imageRef = storageRef.child('avatars/user_$userId');
    try {
      final imageBytes = await imageRef.getData();
      return imageBytes;
    } catch (err) {
      log("Error: $err");
      return null;
    }
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  // get user info
  Future<Map<String, dynamic>?> getUserInfoById(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching user info: $e");
      return null;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } catch (e) {
      print("Error: $e");
      throw e;
    }
  }
}
