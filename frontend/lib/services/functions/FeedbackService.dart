import 'dart:convert';
import 'dart:developer';
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

  Future<double> getCourseRating(String courseId) async {
    try {
      log("hehe");
      final url = Uri.parse('${AppConstants.COURSE_API}/$courseId/rating');
      log('${AppConstants.COURSE_API}/$courseId/rating');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        log(responseData.toString());
        if (responseData['success']) {
          final rating = responseData['data'];
          log(rating.toString());
          return rating;
        } else {

          return 0.0;
        }
      } else {
        throw Exception('Failed to fetch course rating');
        
      }
    } catch (error) {
      throw Exception('Error in getCourseRating: $error');
    }
  }
}
