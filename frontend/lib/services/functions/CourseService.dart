import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend/services/models/comment.dart';
import 'package:frontend/services/models/lesson.dart';
import 'package:frontend/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/services/models/course.dart';

class CourseService {
  // final String baseUrl = AppConstants.baseUrl;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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

  Future<List<Course>> getRandomCourses() async {
    try {
      final response =
          await http.get(Uri.parse("${AppConstants.COURSE_API}/random"));
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
      final response =
          await http.get(Uri.parse("${AppConstants.COURSE_API}/$id"));
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
      final response =
          await http.get(Uri.parse("${AppConstants.COURSE_API}/newest"));
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
      final response =
          await http.get(Uri.parse("${AppConstants.COURSE_API}/top5"));
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
        headers: {'Content-Type': 'application/json'},
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
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load lesson');
    }
  }

  // search
  Future<List<Map<String, dynamic>>> searchCourses(String query,
      {bool isNewSearch = false}) async {
    try {
      if (isNewSearch) lastDocument = null;

      Query queryRef = _firestore
          .collection('courses')
          .where('isPublic', isEqualTo: true)
          .limit(30);

      if (lastDocument != null) {
        queryRef = queryRef.startAfterDocument(lastDocument!);
      }

      final QuerySnapshot snapshot = await queryRef.get();
      if (snapshot.docs.isNotEmpty) {
        lastDocument = snapshot.docs.last;
      }

      log("Snapshot: ${snapshot.docs.length} documents found");

      final courses = snapshot.docs.map((doc) {
        var courseData = doc.data() as Map<String, dynamic>;
        courseData['id'] = doc.id;
        return courseData;
      }).toList();

      final filteredCourses = courses.where((course) {
        final courseName = course['courseName']?.toString().toLowerCase() ?? '';
        final authorName = course['author']?.toString().toLowerCase() ?? '';
        final lowerCaseQuery = query.toLowerCase();
        return courseName.contains(lowerCaseQuery) ||
            authorName.contains(lowerCaseQuery);
      }).toList();

      log("Filtered Courses: $filteredCourses");
      return filteredCourses;
    } catch (e) {
      log("Error searching courses: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> searchCoursesAndUsers(String query,
      {bool isNewSearch = false}) async {
    try {
      if (isNewSearch) lastDocument = null;

      // Search courses
      Query coursesQuery = _firestore.collection('courses').limit(10);
      if (lastDocument != null) {
        coursesQuery = coursesQuery.startAfterDocument(lastDocument!);
      }

      final QuerySnapshot coursesSnapshot = await coursesQuery.get();
      if (coursesSnapshot.docs.isNotEmpty) {
        lastDocument = coursesSnapshot.docs.last;
      }

      final courses = coursesSnapshot.docs.map((doc) {
        var courseData = doc.data() as Map<String, dynamic>;
        courseData['id'] = doc.id;
        return courseData;
      }).toList();

      final filteredCourses = courses.where((course) {
        final courseName = course['courseName']?.toString().toLowerCase() ?? '';
        final lowerCaseQuery = query.toLowerCase();
        return courseName.contains(lowerCaseQuery);
      }).toList();

      // Search users
      final usersSnapshot = await _firestore
          .collection('users')
          .where('displayName', isGreaterThanOrEqualTo: query)
          .where('displayName', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      final users = usersSnapshot.docs.map((doc) {
        var userData = doc.data() as Map<String, dynamic>;
        userData['id'] = doc.id;
        return userData;
      }).toList();

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
      final response = await http.delete(url);
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
        headers: {'Content-Type': 'application/json'},
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
        headers: {'Content-Type': 'application/json'},
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
      final response = await http.delete(url);
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
        headers: {'Content-Type': 'application/json'},
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
        headers: {'Content-Type': 'application/json'},
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
}
