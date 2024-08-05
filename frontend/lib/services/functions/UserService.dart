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

  //search users
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    final url = Uri.parse('${AppConstants.USER_API}/searchUsers?query=$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> users = json.decode(response.body);
      return users.map((user) => user as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to search users');
    }
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
        log(jsonResponse.toString());
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

  Future<void> sendVerificationEmail(String uid) async {
    final response = await http.post(
      Uri.parse('${AppConstants.USER_API}/send-verification-email'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'uid': uid}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send verification email');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } catch (e) {
      log("Error: $e");
      rethrow;
    }
  }

  // save course

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

  Future<bool> checkSavedCourse(String userId, String courseId) async {
    final url =
        Uri.parse('$baseUrl/users/$userId/checkSavedCourse?courseId=$courseId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['isSaved'];
    } else {
      throw Exception('Failed to check saved course: ${response.body}');
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
  Future<Map<String, dynamic>> getUserData(String userId) async {
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
    try {
      final url = Uri.parse('${AppConstants.baseUrl}/users/$userId/follow');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'followUserId': followUserId}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to follow user');
      }
    } catch (e) {
      log("Error $e");
      throw Exception("Failed to follow user");
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

  Future<void> unfollowUser(String userId, String followUserId) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}/users/$userId/unfollow');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'unfollowUserId': followUserId}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to unfollow user');
      }
    } catch (e) {
      log("Error $e");
      throw Exception("Failed to unfollow user");
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
      String userId, String courseId, String lessonId, int time) async {
    final response = await http.patch(
      Uri.parse('${AppConstants.baseUrl}/users/$userId/watchedHistories'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'lessonId': lessonId,
        'courseId': courseId,
        'time': time,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update watched history');
    }
  }

  Future<int?> getWatchedTime(
      String userId, String courseId, String lessonId) async {
    try {
      final uri = Uri.parse(
              '${AppConstants.baseUrl}/users/$userId/watchedHistories/time')
          .replace(queryParameters: {
        'courseId': courseId,
        'lessonId': lessonId,
      });

      log('Requesting URL: $uri');

      final response = await http.get(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        log('Response data: ${data['time']}');
        return data['time'];
      } else {
        log('Failed to get watched time. Status code: ${response.statusCode}');
        log('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      log('Error in getWatchedTime: $e');
      return null;
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

  // get avt and displayname to display on discussion tab
  Future<Map<String, dynamic>> getUserNameAndAvatar(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/users/auth/$userId'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load user details');
    }
  }
}
