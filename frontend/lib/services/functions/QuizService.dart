import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/services/functions/AuthService.dart';
import 'package:frontend/utils/constants.dart';
import 'package:http/http.dart' as http;

class QuizService {
  static String baseUrl = AppConstants.QUIZZES_API;
  String? idToken = AuthService.idToken;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final CollectionReference quizzes =
      FirebaseFirestore.instance.collection('quizzes');

  Stream<QuerySnapshot> getQuizzesStreamByCourse(String courseId) {
    final quizzesStream =
        quizzes.where('courseId', isEqualTo: courseId).snapshots();
    return quizzesStream;
  }

  Stream<QuerySnapshot> getQuestionsStreamByQuiz(String quizId) {
    return quizzes
        .doc(quizId)
        .collection('questions')
        .orderBy('index')
        .snapshots();
  }

  Future<String?> createQuiz(Map<String, dynamic> quizData) async {
    log(baseUrl);
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
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
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
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
    final response = await http.delete(
      Uri.parse('$baseUrl/$quizId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete quiz');
    }
  }

  Future<void> updateQuiz(String quizId, var data) async {
    final url = Uri.parse('$baseUrl/$quizId');
    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode(data),
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

  Future<void> addQuestionsToQuiz(String quizId, var questionData) async {
    final url = Uri.parse('$baseUrl/$quizId/questions');
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(questionData),
      );
      if (response.statusCode == 201) {
        log("Questions added to quiz");
      } else {
        throw Exception('Failed to add questions to quiz');
      }
    } catch (e) {
      throw Exception('Failed to add questions to quiz');
    }
  }

  Future<Map<String, dynamic>> getQuestionById(
      String quizId, String questionId) async {
    final url = Uri.parse('$baseUrl/$quizId/questions/$questionId');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to retreive question detail');
      }
    } catch (e) {
      throw Exception('Failed to retreive question detail');
    }
  }

  Future<void> updateQuestion(
      String quizId, String questionId, var data) async {
    final url = Uri.parse('$baseUrl/$quizId/questions/$questionId');
    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode(data),
      );
      if (response.statusCode == 204) {
        log("Question updated $questionId");
      } else {
        throw Exception('Failed to update question detail');
      }
    } catch (e) {
      throw Exception('Failed to update question detail');
    }
  }

  Future<void> deleteQuestion(String quizId, String questionId) async {
    final url = Uri.parse('$baseUrl/$quizId/questions/$questionId');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );
      if (response.statusCode == 205) {
        log("Question deletedd $questionId");
      } else {
        throw Exception('Failed to delete question');
      }
    } catch (e) {
      throw Exception('Failed to delete question');
    }
  }

  Future<List<dynamic>> getQuestionByQuizzId(String quizId) async {
    final url = Uri.parse('$baseUrl/$quizId/questions');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to retreive question detail');
      }
    } catch (e) {
      throw Exception('Failed to retreive question detail + $e');
    }
  }
}
