import 'package:flutter/material.dart';

class EnrollmentProvider extends ChangeNotifier {
  bool _isEnrolled = false;

  bool get isEnrolled => _isEnrolled;

  void enroll() {
    _isEnrolled = true;
    notifyListeners();
  }

  void reset() {
    _isEnrolled = false;
  }
}
