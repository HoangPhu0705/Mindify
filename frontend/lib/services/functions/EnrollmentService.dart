import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/services/functions/AuthService.dart';
import 'package:frontend/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/services/models/enrollment.dart';

class EnrollmentService {
  // final String baseUrl = AppConstants.baseUrl;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? idToken = AuthService.idToken;

  final CollectionReference enrollments =
      FirebaseFirestore.instance.collection('enrollments');

  Stream<QuerySnapshot> getEnrollmentStreamByUser(String userId) {
    final enrollmentsStream =
        enrollments.where('userId', isEqualTo: userId).snapshots();
    return enrollmentsStream;
  }

  Stream<QuerySnapshot> getEnrollmentStreamByCourse(String courseId) {
    final enrollmentsStream =
        enrollments.where('courseId', isEqualTo: courseId).snapshots();
    return enrollmentsStream;
  }

  Future<void> createEnrollment(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(AppConstants.ENROLLMENT_API),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create enrollment');
    }
  }

  Future<Map<String, dynamic>> checkEnrollment(
      String userId, String courseId) async {
    // final idToken =
    final response = await http.get(
      Uri.parse(
          "${AppConstants.ENROLLMENT_API}/checkEnrollment?userId=$userId&courseId=$courseId"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
    );

    if (response.statusCode == 200) {
      log("body enroll ${response.body}");
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to check enrollment');
    }
  }

  Future<List<String>> getUserEnrollments(String userId) async {
    final response = await http.get(
      Uri.parse(
          "${AppConstants.ENROLLMENT_API}/userEnrollments?userId=$userId"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<String> courseIds = [];
      for (var enrollment in data) {
        courseIds.add(enrollment['courseId']);
      }
      return courseIds;
    } else {
      throw Exception('Failed to get user enrollments');
    }
  }

  Future<void> addLessonToEnrollment(
      String enrollmentId, String lessonId) async {
    final response = await http.post(
      Uri.parse("${AppConstants.ENROLLMENT_API}/addLessonToEnrollment"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: json.encode({'enrollmentId': enrollmentId, 'lessonId': lessonId}),
    );

    if (response.statusCode != 200) {
      print('Response body: ${response.body}');
      throw Exception('Failed to save lesson');
    }
  }

  Future<List<Map<String, dynamic>>> getDownloadedLessons(String userId) async {
    final response = await http.get(
      Uri.parse(
          "${AppConstants.ENROLLMENT_API}/downloadedLessons?userId=$userId"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get downloaded lessons');
    }
  }

  Future<void> addProgressToEnrollment(
      String enrollmentId, String lessonId) async {
    final url =
        Uri.parse('${AppConstants.ENROLLMENT_API}/$enrollmentId/progress');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({'lessonId': lessonId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add progress to enrollment: ${response.body}');
    }
  }

  Future<List<String>> getProgressOfEnrollment(String enrollmentId) async {
    final url =
        Uri.parse('${AppConstants.ENROLLMENT_API}/$enrollmentId/progress');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> progressData = jsonDecode(response.body);
      log(progressData.toString());
      return progressData.map((item) => item as String).toList();
    } else {
      throw Exception('Failed to get progress of enrollment: ${response.body}');
    }
  }

  Future<Map<String, dynamic>?> getStudentsOfCourse(String courseId) async {
    final url = Uri.parse('${AppConstants.ENROLLMENT_API}/$courseId/students');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );
      log(response.toString());

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success']) {
          final Map<String, dynamic> result = {};
          final List<dynamic> students = responseData['data']['students'];
          final int studentNum = responseData['data']['studentNum'];
          final int lessonNum = responseData['data']['lessonNum'];

          result['studentNum'] = studentNum;
          result['lessonNum'] = lessonNum;
          result['students'] = students;
          return result;
        } else {
          log('Failed to get students: ${responseData['message']}');
          return null;
        }
      } else {
        log('Failed to load students. Status code: ${response.statusCode}');
        return null;
      }
    } catch (error) {
      log('Error occurred: $error');
      return null;
    }
  }

  // Future<Map<String, dynamic>> getStudentsOfMonth(String userId) async {
  //   final response = await http.get(Uri.parse('${AppConstants.ENROLLMENT_API}/studentsOfMonth/$userId'));

  //   if (response.statusCode == 200) {
  //     final Map<String, dynamic> data = json.decode(response.body);
  //     return data;
  //   } else {
  //     throw Exception('Failed to load data');
  //   }
  // }

  Future<Map<String, dynamic>?> getDashboardData(String userId, int month, int year) async {
    final url = Uri.parse('${AppConstants.ENROLLMENT_API}/dashboard/$userId?month=$month&year=$year');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success']) {
          final Map<String, dynamic> data = responseData['data'];
          return data;
        } else {
          log('Failed to get dashboard data: ${responseData['message']}');
          return null;
        }
      } else {
        log('Failed to load dashboard data. Status code: ${response.statusCode}');
        return null;
      }
    } catch (error) {
      log('Error occurred: $error');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getNumStudentsAndRevenue(String userId) async {
    final url = Uri.parse('${AppConstants.ENROLLMENT_API}/stats/$userId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success']) {
          final data = responseData['data'];
          return data;
        } else {
          log('Failed to get dashboard data: ${responseData['message']}');
          return null;
        }
      } else {
        throw Exception('Failed to load course stats');
      }
    } catch (e) {
      throw Exception('Error fetching course stats: $e');
    }
  }
}
