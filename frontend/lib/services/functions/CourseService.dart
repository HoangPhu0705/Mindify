import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend/services/functions/AuthService.dart';
import 'package:frontend/services/functions/UserService.dart';
import 'package:frontend/services/models/comment.dart';
import 'package:frontend/services/models/lesson.dart';
import 'package:frontend/utils/constants.dart';
import 'package:googleapis/chat/v1.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/services/models/course.dart';

class CourseService {
  // final String baseUrl = AppConstants.baseUrl;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final authService = AuthService();
  String idToken = AuthService.idToken!;
  // Future<>
  DocumentSnapshot? lastDocument;
  Future<List<Course>> fetchCourses() async {
    try {
      final response = await http.get(Uri.parse(AppConstants.COURSE_API));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((course) => Course.fromJson(course)).toList();
      } else {
        throw Exception("Failed to load courses");
      }
    } catch (e) {
      log("Error: $e");
      throw Exception("Failed to load courses");
    }
  }

  Stream<QuerySnapshot> getCourseStreamByAuthorId(
      String userId, bool isRequest) {
    return _firestore
        .collection('courses')
        .where("authorId", isEqualTo: userId)
        .where("request", isEqualTo: isRequest)
        .snapshots();
  }

  Future<List<Course>> getRandomCourses() async {
    try {
      final response = await http.get(
        Uri.parse("${AppConstants.COURSE_API}/random"),
        headers: {
          'Authorization': 'Bearer $idToken',
        },
      );
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data
            .map((course) => Course.fromJsonWithoutLesson(course))
            .toList();
      } else {
        throw Exception("Failed to load random courses");
      }
    } catch (e) {
      log("Error: $e");
      throw Exception("Failed to load random courses");
    }
  }

  Future<Course> getCourseById(String id) async {
    try {
      final response = await http.get(
        Uri.parse("${AppConstants.COURSE_API}/$id"),
        headers: {
          'Authorization': 'Bearer $idToken',
        },
      );
      if (response.statusCode == 200) {
        return Course.fromJson(json.decode(response.body));
      } else {
        throw Exception("Failed to load course");
      }
    } catch (e) {
      log("Error: $e");
      throw Exception("Failed to load course");
    }
  }

  Future<List<Course>> getFiveNewestCourses() async {
    try {
      final response = await http.get(
        Uri.parse("${AppConstants.COURSE_API}/newest"),
        headers: {
          'Authorization': 'Bearer $idToken',
        },
      );
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data
            .map((course) => Course.fromJsonWithoutLesson(course))
            .toList();
      } else {
        throw Exception("Failed to load newest 5 courses");
      }
    } catch (e) {
      log("Error: $e");
      throw Exception("Failed to load 5 newest courses");
    }
  }

  Future<List<Course>> getTop5Courses() async {
    try {
      log("Token ne $idToken");
      final response = await http.get(
        Uri.parse("${AppConstants.COURSE_API}/top5"),
        // headers: {
        //   'Authorization': 'Bearer $idToken',
        // },
      );
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data
            .map((course) => Course.fromJsonWithoutLesson(course))
            .toList();
      } else {
        throw Exception("Failed to load top 5 courses");
      }
    } catch (e) {
      log("Error: $e");
      throw Exception("Failed to load top 5 courses");
    }
  }

  Future<String> getInstructorName(String instructorId) async {
    DocumentSnapshot snapshot =
        await _firestore.collection('users').doc(instructorId).get();
    if (snapshot.exists && snapshot.data() != null) {
      final data = snapshot.data() as Map<String, dynamic>;
      return data['displayName'];
    }

    return "Mindify Member";
  }

  Future<List<Course>> getCoursesByIds(List<String> courseIds) async {
    List<Course> courses = [];
    for (String courseId in courseIds) {
      Course course = await getCourseById(courseId);
      courses.add(course);
    }
    return courses;
  }

  Future<String> createCourse(var data) async {
    try {
      final url = Uri.parse(AppConstants.COURSE_API);
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode(data),
      );
      if (response.statusCode == 201) {
        log("Course created successfully: ${response.body}");
        final courseId = response.body.split('"')[3];

        return courseId;
      } else {
        throw Exception("Error creating course");
      }
    } catch (e) {
      log("Error: $e");
      throw Exception("Error creating course");
    }
  }

  //lesson
  Future<Map<String, dynamic>> getLesson(
      String courseId, String lessonId) async {
    final response = await http.get(
        Uri.parse("${AppConstants.COURSE_API}/$courseId/lessons/$lessonId"),
        headers: {
          'Authorization': 'Bearer $idToken',
        });

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load lesson');
    }
  }

  Future<List<Map<String, dynamic>>> searchCoursesAPI(String query,
      {bool isNewSearch = false, String? lastDocument}) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.COURSE_API}/searchCourses'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({'query': query, 'lastDocument': lastDocument}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        List<Map<String, dynamic>> courses = (data['courses'] as List)
            .map((course) => course as Map<String, dynamic>)
            .toList();
        return courses;
      } else {
        throw Exception('Failed to load courses');
      }
    } catch (e) {
      print('Error searching courses: $e');
      return [];
    }
  }

  // search
  Future<List<Map<String, dynamic>>> searchCourses(String query,
      {bool isNewSearch = false}) async {
    try {
      if (isNewSearch) lastDocument = null;

      List<Map<String, dynamic>> courses = await searchCoursesAPI(
        query,
        isNewSearch: isNewSearch,
        lastDocument: lastDocument?.id,
      );

      return courses;
    } catch (e) {
      print('Error searching courses: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> searchCoursesAndUsersAPI(String query,
    {bool isNewSearch = false}) async {
  try {
    // final idToken = await AuthService.idToken;

    final response = await http.post(
      Uri.parse('${AppConstants.COURSE_API}/searchCoursesAndUsers'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({'query': query, 'isNewSearch': isNewSearch}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load courses and users');
    }
  } catch (e) {
    log("Error searching courses and users: $e");
    return {};
  }
}

Future<List<Map<String, dynamic>>> searchCoursesAndUsers(String query,
    {bool isNewSearch = false}) async {
  try {
    final results = await searchCoursesAndUsersAPI(query, isNewSearch: isNewSearch);

    final filteredCourses = List<Map<String, dynamic>>.from(results['courses'] ?? []);
    final users = List<Map<String, dynamic>>.from(results['users'] ?? []);

    final searchResults = [
      ...filteredCourses,
      ...users,
    ];

    log("Filtered Courses and Users: $searchResults");
    return searchResults;
  } catch (e) {
    log("Error searching courses and users: $e");
    return [];
  }
}


  Future<List<Course>> getCourseByUserId(String userId) async {
    final response = await http.get(
      Uri.parse("${AppConstants.COURSE_API}/users/$userId"),
      headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((course) => Course.fromJson(course)).toList();
    } else {
      throw Exception('Failed to load class');
    }
  }

  Future<List<Course>> getCoursePublicByUserId(String userId) async {
    final response = await http.get(
      Uri.parse("${AppConstants.COURSE_API}/users/$userId/public"),
      headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((course) => Course.fromJson(course)).toList();
    } else {
      throw Exception('Failed to load class');
    }
  }

  Future<void> deleteCourse(String courseId) async {
    try {
      final url = Uri.parse("${AppConstants.COURSE_API}/$courseId");
      final response = await http.delete(url, headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },);
      if (response.statusCode == 204) {
        log("Course deleted successfully");
      } else {
        throw Exception("Error deleting course");
      }
    } catch (e) {
      log("Error: $e");
      throw Exception("Error deleting course");
    }
  }

  Future<void> updateCourse(String courseId, var updateData) async {
    try {
      final url = Uri.parse("${AppConstants.COURSE_API}/$courseId");
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode(updateData),
      );
      if (response.statusCode == 204) {
        log("Course updated successfully");
      } else {
        throw Exception("Error updating course");
      }
    } catch (e) {
      log("Error: $e");
      throw Exception("Error updating course");
    }
  }

  Stream<QuerySnapshot> getLessonStreamByCourse(String courseId) {
    return _firestore
        .collection('courses')
        .doc(courseId)
        .collection('lessons')
        .orderBy('index')
        .snapshots();
  }

  Future<void> createLesson(String courseId, var data) async {
    try {
      final url = Uri.parse("${AppConstants.COURSE_API}/$courseId/lessons");
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode(data),
      );
      if (response.statusCode == 201) {
        log("Lesson created successfully: ${response.body}");
      } else {
        throw Exception("Error creating lesson");
      }
    } catch (e) {
      log("Error: $e");
      throw Exception("Error creating lesson");
    }
  }

  Future<void> deleteLesson(String courseId, String lessonId) async {
    try {
      final url =
          Uri.parse("${AppConstants.COURSE_API}/$courseId/lessons/$lessonId");
      final response = await http.delete(url, headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },);
      if (response.statusCode == 204) {
        log("Lesson deleted successfully");
      } else {
        throw Exception("Error deleting lesson");
      }
    } catch (e) {
      log("Error: $e");
      throw Exception("Error deleting lesson");
    }
  }

  Future<void> updateLesson(String courseId, String lessonId, var data) async {
    try {
      final url =
          Uri.parse("${AppConstants.COURSE_API}/$courseId/lessons/$lessonId");
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode(data),
      );
      if (response.statusCode == 204) {
        log("Lesson updated successfully");
      } else {
        throw Exception("Error updating lesson");
      }
    } catch (e) {
      log("Error: $e");
      throw Exception("Error updating lesson");
    }
  }

  Future<void> updateLessonIndex(
      String courseId, String lessonId, int newIndex) async {
    await FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .collection('lessons')
        .doc(lessonId)
        .update({'index': newIndex});
  }

  Future<Map<String, dynamic>> getCategoryCourses(dynamic categories) async {
    try {
      final url = Uri.parse("${AppConstants.COURSE_API}/categories");
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode(categories),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception("Failed to load courses: ${response.reasonPhrase}");
      }
    } catch (e) {
      log("Error: $e");
      throw Exception("Error getting course by categories");
    }
  }

  Future<dynamic> getCombinedDuration(String courseId) async {
    try {
      final url =
          Uri.parse("${AppConstants.COURSE_API}/$courseId/combined-duration");
      final response = await http.get(url, headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to load courses: ${response.reasonPhrase}");
      }
    } catch (e) {
      log("Error: $e");
      throw Exception("Error getting course by categories");
    }
  }

  // Future<Map<String, dynamic>> getLessonById(String courseId, String lessonId){
  //   return ;
  // }

  Future<void> addResourceToCourse(String courseId, var resources) async {
    try {
      final url = Uri.parse("${AppConstants.COURSE_API}/$courseId/resources");
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode(resources),
      );
      if (response.statusCode == 200) {
        log("added resources");
      } else {
        throw Exception("Failed to add resources: ${response.body}");
      }
    } catch (e) {
      log("Error: $e");
      throw Exception("Error adding resources");
    }
  }

  Future<void> deleteResourceFromCourse(
      String courseId, String resourceId) async {
    try {
      final url = Uri.parse(
          "${AppConstants.COURSE_API}/$courseId/resources/$resourceId");
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );
      if (response.statusCode == 200) {
        log("deleted resource");
      } else {
        throw Exception("Failed to delete resource: ${response.body}");
      }
    } catch (e) {
      log("Error: $e");
      throw Exception("Error deleting resource");
    }
  }

  Future<void> updateResourceInCourse(
      String courseId, String resourceId, var updates) async {
    try {
      final url = Uri.parse(
          "${AppConstants.COURSE_API}/$courseId/resources/$resourceId");
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode(updates),
      );
      if (response.statusCode == 200) {
        log("updated resource");
      } else {
        throw Exception("Failed to update resource: ${response.body}");
      }
    } catch (e) {
      log("Error: $e");
      throw Exception("Error updating resource");
    }
  }

  Stream<QuerySnapshot> getResourcesStreamByCourse(String courseId) {
    return _firestore
        .collection('courses')
        .doc(courseId)
        .collection('resources')
        .snapshots();
  }

  Future<void> requestCourse(String courseId) async {
    try {
      final url = Uri.parse("${AppConstants.baseUrl}/courseRequest/$courseId");
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );
      if (response.statusCode == 200) {
        log("request Sent");
      } else {
        throw Exception("Failed to send course request: ${response.body}");
      }
    } catch (e) {
      log("Error: $e");
      throw Exception("Error adding resources");
    }
  }
}
