import 'package:frontend/services/models/lesson.dart';
import 'package:frontend/services/models/comment.dart';


// class Course {
//   String id;
//   String title;
//   String description;
//   String thumbnail;
//   String instructorId;
//   String instructorName;
//   String duration;
//   bool isPublic;
//   int projectNum;
//   int students;
//   int price;
//   String projectDescription;
//   List<Lesson> lessons;
//   List<String> categories = [];

//   // Constructor
//   Course({
//     required this.id,
//     required this.title,
//     required this.description,
//     required this.thumbnail,
//     required this.instructorId,
//     required this.instructorName,
//     required this.duration,
//     required this.isPublic,
//     required this.projectNum,
//     required this.students,
//     required this.price,
//     required this.projectDescription,
//     required this.lessons,
//     required this.categories,
//   });

//   // Factory
//   factory Course.fromJson(Map<String, dynamic> json) {
//     return Course(
//       id: json['id'] as String,
//       title: json['courseName'] as String,
//       description: json['description'] as String,
//       thumbnail: json['thumbnail'] as String,
//       instructorId: json['authorId'] as String,
//       instructorName: json['author'] as String,
//       duration: json['duration'] as String,
//       isPublic: json['isPublic'] as bool,
//       projectNum: json['projectNum'] as int,
//       students: json['students'] as int,
//       price: json['price'] as int,
//       projectDescription: json['projectDescription'] as String,
//       lessons: (json['lessons'] as List<dynamic>?)
//               ?.map((lessonJson) =>
//                   Lesson.fromJson(lessonJson as Map<String, dynamic>))
//               .toList() ??
//           [],
//       categories: (json['categories'] as List<dynamic>?)
//               ?.map((category) => category as String)
//               .toList() ??
//           [],
//     );
//   }

//   // factory Course.fromJsonWithoutLesson(Map<String, dynamic> json) {
//   //   return Course(
//   //     id: json['id'] as String,
//   //     title: json['courseName'] as String,
//   //     description: json['description'] as String,
//   //     thumbnail: json['thumbnail'] as String,
//   //     instructorId: json['authorId'] as String,
//   //     instructorName: json['author'] as String,
//   //     duration: json['duration'] as String,
//   //     isPublic: json['isPublic'] as bool,
//   //     projectNum: json['projectNum'] as int,
//   //     students: json['students'] as int,
//   //     price: json['price'] as int,
//   //     projectDescription: json['projectDescription'] as String,
//   //     lessons: [],
//   //     categories: (json['categories'] as List<dynamic>?)
//   //             ?.map((category) => category as String)
//   //             .toList() ??
//   //         [],
//   //   );
//   // }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'title': title,
//       'description': description,
//       'thumbnail': thumbnail,
//       'authorId': instructorId,
//       'author': instructorName,
//       'duration': duration,
//       'isPublic': isPublic,
//       'projectNum': projectNum,
//       'students': students,
//       'price': price,
//       'projectDescription': projectDescription,
//       'lessons': lessons.map((lesson) => lesson.toJson()).toList(),
//       'categories': categories,
//     };
//   }
// }

class Course {
  String id;
  String title;
  String description;
  String thumbnail;
  String instructorId;
  String instructorName;
  String duration;
  bool isPublic;
  int projectNum;
  int students;
  int price;
  String projectDescription;
  List<Lesson> lessons;
  List<String> categories = [];
  List<Comment> comments = [];
  int lessonNum;
  // Constructor
  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.instructorId,
    required this.instructorName,
    required this.duration,
    required this.isPublic,
    required this.projectNum,
    required this.students,
    required this.price,
    required this.projectDescription,
    required this.lessons,
    required this.categories,
    required this.comments,
    required this.lessonNum,
  });

  // Factory
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String,
      title: json['courseName'] as String,
      description: json['description'] as String,
      thumbnail: json['thumbnail'] as String,
      instructorId: json['authorId'] as String,
      instructorName: json['author'] as String,
      duration: json['duration'] as String,
      isPublic: json['isPublic'] as bool,
      projectNum: json['projectNum'] as int,
      students: json['students'] as int,
      price: json['price'] as int,
      projectDescription: json['projectDescription'] as String,
      lessons: (json['lessons'] as List<dynamic>?)
              ?.map((lessonJson) =>
                  Lesson.fromJson(lessonJson as Map<String, dynamic>))
              .toList() ??
          [],
      categories: (json['categories'] as List<dynamic>?)
              ?.map((category) => category as String)
              .toList() ??
          [],
      comments: (json['comments'] as List<dynamic>?)
              ?.map((commentJson) =>
                  Comment.fromJson(commentJson as Map<String, dynamic>))
              .toList() ??
          [],
      lessonNum: json['lessonNum']
    );
  }

  factory Course.fromJsonWithoutLesson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String,
      title: json['courseName'] as String,
      description: json['description'] as String,
      thumbnail: json['thumbnail'] as String,
      instructorId: json['authorId'] as String,
      instructorName: json['author'] as String,
      duration: json['duration'] as String,
      isPublic: json['isPublic'] as bool,
      projectNum: json['projectNum'] as int,
      students: json['students'] as int,
      price: json['price'] as int,
      projectDescription: json['projectDescription'] as String,
      lessons: [],
      categories: (json['categories'] as List<dynamic>?)
              ?.map((category) => category as String)
              .toList() ??
          [],
      comments: [],
      lessonNum: json['lessonNum']

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
      'isPublic': isPublic,
      'projectNum': projectNum,
      'students': students,
      'price': price,
      'projectDescription': projectDescription,
      'lessons': lessons.map((lesson) => lesson.toJson()).toList(),
      'categories': categories,
      'comments': comments.map((comment) => comment.toJson()).toList(),
      'lessonNum': lessonNum,
    };
  }
}
