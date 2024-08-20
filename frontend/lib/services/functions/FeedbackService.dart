import 'dart:convert';
import 'package:frontend/services/functions/AuthService.dart';
import 'package:frontend/utils/constants.dart';
import 'package:http/http.dart' as http;

class FeedbackService {
  String? idToken = AuthService.idToken;

  Future<Map<String, dynamic>> giveFeedback(
      String courseId, String userId, Map<String, dynamic> feedback) async {
    try {
      final url = Uri.parse('${AppConstants.COURSE_API}/$courseId/feedback');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'userId': userId,
          'feedback': feedback,
        }),
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
