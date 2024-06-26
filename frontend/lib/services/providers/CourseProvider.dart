import 'package:flutter/material.dart';

class CourseProvider with ChangeNotifier {
  // List<Course> _courses = [];
  // Course? _selectedCourse;

  // List<Course> get courses => _courses;
  // Course? get selectedCourse => _selectedCourse;
  Set<String> _savedCourses = {};

  Set<String> get savedCourses => _savedCourses;

  void setSavedCourses(Set<String> courses) {
    _savedCourses = courses;
    notifyListeners();
  }

  void saveCourse(String courseId) {
    _savedCourses.add(courseId);
    notifyListeners();
  }

  void unsaveCourse(String courseId) {
    _savedCourses.remove(courseId);
    notifyListeners();
  }

  bool isCourseSaved(String courseId) {
    return _savedCourses.contains(courseId);
  }

}
