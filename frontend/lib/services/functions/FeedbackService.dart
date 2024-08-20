import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/services/functions/AuthService.dart';
import 'package:frontend/utils/constants.dart';
import 'package:http/http.dart' as http;

class FeedbackService {
  String? idToken = AuthService.idToken;

  final CollectionReference courses =
      FirebaseFirestore.instance.collection('courses');

  Future<Map<String, dynamic>> giveFeedback(
    String courseId,
    var feedback,
  ) async {
    try {
      final url = Uri.parse('${AppConstants.COURSE_API}/$courseId/feedback');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode(feedback),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to submit feedback');
      }
    } catch (error) {
      throw Exception('Error in giveFeedback: $error');
    }
  }

  Stream<QuerySnapshot> getTopFeedBackStream(String courseId) {
    try {
      final feedbacks = courses.doc(courseId).collection('feedbacks');
      return feedbacks
          .orderBy('createdAt', descending: true)
          .limit(5)
          .snapshots();
    } catch (error) {
      throw Exception('Error in getTopFeedBackStream: $error');
    }
  }

  Future<Map<String, dynamic>> getCourseRating(String courseId) async {
    try {
      final url = Uri.parse('${AppConstants.COURSE_API}/$courseId/rating');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch course rating');
      }
    } catch (error) {
      throw Exception('Error in getCourseRating: $error');
    }
  }
}
