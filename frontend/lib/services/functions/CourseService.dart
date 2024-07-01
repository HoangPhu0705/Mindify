import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/services/models/course.dart';

class CourseService {
  final String baseUrl = "http://10.0.2.2:3000/api";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Course>> fetchCourses() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/courses"));
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
      final response = await http.get(Uri.parse("$baseUrl/courses/random"));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((course) => Course.fromJson(course)).toList();
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
      final response = await http.get(Uri.parse("$baseUrl/courses/$id"));
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
      final response = await http.get(Uri.parse("$baseUrl/courses/newest"));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((course) => Course.fromJson(course)).toList();
      } else {
        throw Exception("Failed to load top 5 courses");
      }
    } catch (e) {
      log("Error: $e");
      throw Exception("Failed to load top 5 courses");
    }
  }

  Future<List<Course>> getTop5Courses() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/courses/top5"));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((course) => Course.fromJson(course)).toList();
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
      log("Successfully");
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

  Future<void> createCourse(var data) async {
    try {
      final url = Uri.parse(AppConstants.COURSE_API);
      final response = await http.post(
        url,
        body: data,
      );
      if (response.statusCode == 201) {
        log("Course created successfully");
      } else {
        throw Exception("Error creating course");
      }
    } catch (e) {
      log("Error: $e");
      throw Exception("Error creating course");
    }
  }

  //lesson
  Future<Map<String, dynamic>> getLesson(String courseId, String lessonId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/courses/$courseId/lessons/$lessonId"),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load lesson');
    }
  }
}
