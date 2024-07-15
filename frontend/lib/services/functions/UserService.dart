import 'dart:convert';
import 'dart:developer';
import 'package:frontend/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class UserService {
  // Chỉ nên sử dụng service này khi đã login
  User get user => FirebaseAuth.instance.currentUser!;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String baseUrl = AppConstants.baseUrl;

  String getUserId() {
    return user.uid;
  }

  String getUsername() {
    if (user.displayName == null || user.displayName!.isEmpty) {
      return "Mindify Member";
    }
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

  // Change password with validating the old password
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

  // Update profile url
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

  // Get user info
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

  Future<Map<String, dynamic>?> getAvatarAndDisplayName(String uid) async {
    try {
      final url = Uri.parse('${AppConstants.USER_API}/auth/$uid');
      final response =
          await http.get(url, headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return jsonResponse;
      } else {
        log("Error fetching user info");
      }
    } catch (e) {
      log("Error fetching user info: $e");
      return null;
    }
    return null;
  }

  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } catch (e) {
      print("Error: $e");
      throw e;
    }
  }

  Future<void> saveCourseForUser(String userId, String courseId) async {
    final url = Uri.parse('$baseUrl/users/$userId/saveCourse');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'courseId': courseId}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to save course');
    }
  }

  Future<void> unsaveCourseForUser(String userId, String courseId) async {
    final url = Uri.parse('$baseUrl/users/$userId/unsaveCourse');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'courseId': courseId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to unsave course');
    }
  }

  Future<Set<String>> getSavedCourses(String userId) async {
    final url = Uri.parse('$baseUrl/users/$userId/savedCourses');
    final response =
        await http.get(url, headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final List<dynamic> coursesJson = jsonResponse['savedClasses'];
      return coursesJson.map((course) => course.toString()).toSet();
    } else {
      throw Exception('Failed to load saved courses');
    }
  }

  Future<void> sendInstructorRequest(var data) {
    final url = Uri.parse(AppConstants.CREATE_INSTRUCTOR_REQUEST);
    return http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
  }

  //get user data by id
  Future<dynamic> getUserData(String userId) async {
    final url = Uri.parse('${AppConstants.baseUrl}/users/$userId');
    final response =
        await http.get(url, headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get user data');
    }
  }

  Future<void> updateUserRequestStatus(String userId, bool status) async {
    try {
      DocumentReference userRef = _firestore.collection('users').doc(userId);
      DocumentSnapshot userDoc = await userRef.get();
      if (!userDoc.exists) {
        throw Exception('User not found');
      }

      await userRef.update({
        "requestSent": status,
      });
    } catch (e) {
      log("Error $e");
      throw Exception("Failed to update user");
    }
  }

  Future<void> followUser(String userId, String followUserId) async {
    final url = Uri.parse('${AppConstants.baseUrl}/users/$userId/follow');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'followUserId': followUserId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to follow user');
    }
  }

  Future<bool> checkIfUserFollows(String userId, String followUserId) async {
    final url = Uri.parse(
        '${AppConstants.baseUrl}/users/$userId/checkFollow?userId=$followUserId');
    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        log("Check follow response: $jsonResponse");
        return jsonResponse['isFollowing'] as bool;
      } else {
        log("Failed to check follow status: ${response.statusCode}");
        throw Exception('Failed to check follow status');
      }
    } catch (e) {
      log("Error checking follow status: $e");
      throw e;
    }
  }

  Future<List<dynamic>> getWatchedHistories(String userId) async {
    final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/users/$userId/watchedHistories'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load watched histories');
    }
  }

  Future<void> addToWatchedHistories(
      String userId, String lessonId, int time) async {
    final response = await http.patch(
      Uri.parse('${AppConstants.baseUrl}/users/$userId/watchedHistories'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'lessonId': lessonId,
        'time': time,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update watched history');
    }
  }

  Future<void> updateUserFollowedTopics(String userId, var data) async {
    try {
      DocumentReference userRef = _firestore.collection('users').doc(userId);
      DocumentSnapshot userDoc = await userRef.get();
      if (!userDoc.exists) {
        throw Exception('User not found');
      }

      await userRef.update({
        "followedTopic": data,
      });
    } catch (e) {
      log("Error $e");
      throw Exception("Failed to update user");
    }
  }
}
