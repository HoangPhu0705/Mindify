import 'package:frontend/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Projectservice {
  Future<void> submitProject(String courseId) async {
    try {
      final response = await http.post(
        Uri.parse(AppConstants.PROJECT_API),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'courseId': courseId}),
      );
      if (response.statusCode != 201) {
        throw Exception('Failed to submit project: ${response.body}');
      }
    } catch (error) {
      throw Exception('Failed to submit project: $error');
    }
  }
}
