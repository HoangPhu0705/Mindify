import 'package:flutter/material.dart';
import 'package:frontend/models/course.dart';
import 'package:frontend/services/functions/CourseService.dart';


class CourseProvider with ChangeNotifier {
  final CourseService courseService;
  List<Course> _courses = [];
  Course? _selectedCourse;

  List<Course> get courses => _courses;
  Course? get selectedCourse => _selectedCourse;

  CourseProvider(this.courseService);

  Future<void> fetchCourses() async {
    _courses = await courseService.fetchCourses();
    notifyListeners();
  }

  Future<void> getCourseById(String id) async {
    _selectedCourse = await courseService.getCourseById(id);
    notifyListeners();
  }

  
}
