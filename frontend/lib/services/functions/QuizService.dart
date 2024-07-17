import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/utils/constants.dart';
import 'package:http/http.dart' as http;

class QuizService {
  static String baseUrl = AppConstants.baseUrl;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final CollectionReference quizzes =
      FirebaseFirestore.instance.collection('quizzes');

  Stream<QuerySnapshot> getQuizzesStreamByCourse(String courseId) {
    final quizzesStream =
        quizzes.where('courseId', isEqualTo: courseId).snapshots();
    return quizzesStream;
  }

  Future<String?> createQuiz(Map<String, dynamic> quizData) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(quizData),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['id'];
    } else {
      print('Failed to create quiz. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      return null;
    }
  }

  Future<List<dynamic>> getQuizzesByCourseId(String courseId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$courseId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      log('Failed to fetch quizzes. Status code: ${response.statusCode}');
      log('Response body: ${response.body}');
      return [];
    }
  }

  Future<void> deleteQuiz(String quizId) async {
    final response = await http.delete(Uri.parse('$baseUrl/$quizId'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete quiz');
    }
  }

  Future<void> updateQuiz(String quizId, var data) async {
    final url = Uri.parse('$baseUrl/quizzes/$quizId');
    try {
      final response = await http.patch(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonDecode(data),
      );
      if (response.statusCode == 200) {
        log("Quiz updated");
      } else {
        throw Exception('Failed to update quiz');
      }
    } catch (e) {
      throw Exception('Failed to update quiz');
    }
  }
}
