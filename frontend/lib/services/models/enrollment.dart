import 'package:frontend/services/models/lesson.dart';

class Enrollment {
  String id;
  String userId;
  String courseId;
  DateTime enrollmentDay;
  List<Lesson> downloadedLessons;
  Enrollment({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.enrollmentDay,
    required this.downloadedLessons
  });
  factory Enrollment.fromJson(Map<String, dynamic> json) {
    return Enrollment(
      id: json['id'] as String,
      userId: json['userId'] as String,
      courseId: json['courseId'] as String,
      enrollmentDay: json['enrollmentDay'] as DateTime,
      downloadedLessons: (json['downloadedLessons'] as List<dynamic>)
          .map((lessonJson) =>
              Lesson.fromJson(lessonJson as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'courseId': courseId,
      'enrollmentDay': enrollmentDay,
      'downloadedLessons': downloadedLessons.map((lesson) => lesson.toJson()).toList(),
    };
  }
}