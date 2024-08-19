import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/services/functions/AuthService.dart';
import 'package:frontend/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProjectService {
  String? idToken = AuthService.idToken;

  //projects streambuilder
  Stream<QuerySnapshot> getProjectStream(String courseId) {
    try {
      final stream = FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .collection('projects')
          .snapshots();
      return stream;
    } catch (error) {
      throw Exception('Failed to stream projects: $error');
    }
  }

  Future<bool> hasSubmittedProject(String courseId, String userId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .collection('projects')
        .where('userId', isEqualTo: userId)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> addProjectComment(
      String courseId, String projectId, var commentData) async {
    try {
      await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .collection('projects')
          .doc(projectId)
          .collection('comments')
          .add(commentData);
    } catch (error) {
      throw Exception('Failed to add project comment: $error');
    }
  }

  Stream<QuerySnapshot> getProjectCommentStream(
      String courseId, String projectId) {
    try {
      final stream = FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .collection('projects')
          .doc(projectId)
          .collection('comments')
          .orderBy("timestamp")
          .snapshots();
      return stream;
    } catch (error) {
      throw Exception('Failed to stream projects comment: $error');
    }
  }

  Future<void> getProject(String courseId, String projectId) async {
    try {
      final response = await http.get(
        Uri.parse("${AppConstants.PROJECT_API}/$courseId/$projectId"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to get project: ${response.body}');
      }
      return jsonDecode(response.body);
    } catch (error) {
      throw Exception('Failed to get project: $error');
    }
  }

  Future<void> submitProject(
      String courseId, Map<String, dynamic> projectData) async {
    try {
      final response = await http.post(
        Uri.parse("${AppConstants.PROJECT_API}/$courseId"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'courseId': courseId,
          'grade': -1,
          ...projectData,
        }),
      );
      if (response.statusCode != 201) {
        throw Exception('Failed to submit project: ${response.body}');
      }
    } catch (error) {
      throw Exception('Failed to submit project: $error');
    }
  }

  Future<DocumentSnapshot?> getProjectId(String courseId, String userId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .collection('projects')
        .where('userId', isEqualTo: userId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      log("wiwi");
      return querySnapshot.docs.first;
    }
    return null;
  }

  Future<void> removeProject(String courseId, String projectId) async {
    try {
      final response = await http.delete(
        Uri.parse("${AppConstants.PROJECT_API}/$courseId/$projectId"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to remove project: ${response.body}');
      }
    } catch (error) {
      throw Exception('Failed to remove project: $error');
    }
  }
}
