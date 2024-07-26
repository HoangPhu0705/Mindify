import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Projectservice {
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

  Future<void> submitProject(
      String courseId, Map<String, dynamic> projectData) async {
    try {
      final response = await http.post(
        Uri.parse("${AppConstants.PROJECT_API}/$courseId"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'courseId': courseId,
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
}
