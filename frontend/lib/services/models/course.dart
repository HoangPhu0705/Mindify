import 'package:frontend/services/models/lesson.dart';

class Course {
  String id;
  String title;
  String description;
  String thumbnail;
  String instructorId;
  String instructorName;
  String duration;
  List<Lesson> lessons;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.instructorId,
    required this.instructorName,
    required this.duration,
    required this.lessons,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String,
      title: json['courseName'] as String,
      description: json['description'] as String,
      thumbnail: json['thumbnail'] as String,
      instructorId: json['authorId'] as String,
      instructorName: json['author'] as String,
      duration: json['duration'] as String,
      lessons: (json['lessons'] as List<dynamic>)
          .map((lessonJson) =>
              Lesson.fromJson(lessonJson as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnail': thumbnail,
      'authorId': instructorId,
      'author': instructorName,
      'duration': duration,
      'lessons': lessons.map((lesson) => lesson.toJson()).toList(),
    };
  }
}
