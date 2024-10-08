// ignore_for_file: non_constant_identifier_names

import 'dart:developer';
import 'dart:io';

class AppConstants {
  static String get baseUrl {
    if (Platform.isAndroid) {
      return "http://10.0.2.2:3000/api";
      // return "http://localhost:3000/api"; //test for physical devices
    } else if (Platform.isIOS) {
      return "http://localhost:3000/api";
    } else {
      throw UnsupportedError("Unsupported platform");
    }
    // return "https://mindifyhost.onrender.com/api";
  }

  static const List<String> categories = [
    'Animation',
    'Culinary',
    'Drawing',
    'Film',
    'Graphic Design',
    'Illustration',
    'Photography',
    'Procreate',
    'Watercolor',
    'Web & App Design',
    'Writing',
  ];

  static const List<String> categoryImage = [
    'assets/images/category/animation.jpg',
    'assets/images/category/culinary.jpg',
    'assets/images/category/drawing.jpg',
    'assets/images/category/film.jpg',
    'assets/images/category/graphic_design.jpg',
    'assets/images/category/illustration.jpg',
    'assets/images/category/photography.jpg',
    'assets/images/category/procreate.jpg',
    'assets/images/category/watercolor.jpg',
    'assets/images/category/web_app_design.jpg',
    'assets/images/category/writing.jpg',
  ];



  static String CREATE_INSTRUCTOR_REQUEST = "$baseUrl/users/requestInstructor";
  static String USER_API = "$baseUrl/users";
  static String COURSE_API = "$baseUrl/courses";
  static String ENROLLMENT_API = "$baseUrl/enrollments";
  static String FOLDER_API = "$baseUrl/folders";
  static String TRANSACTION_API = "$baseUrl/transactions";
  static String QUIZZES_API = "$baseUrl/quizzes";
  static String PROJECT_API = "$baseUrl/projects";
  static String PUBLIC_KEY_STRIPE =
      "pk_test_51Pb0VgRpFmvp1gYpQh2OcBekwGa5WM8ZY3Ongr1A7P0O0LZdqJuYAcVI8H6Qzc4otSnxLiEFlleuWgd3CFXE2Jic008mnJLbrJ";
}
