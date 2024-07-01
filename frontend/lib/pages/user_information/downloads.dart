import 'package:flutter/material.dart';
import 'package:frontend/services/functions/EnrollmentService.dart';
import 'package:frontend/services/functions/CourseService.dart';
// import 'package:frontend/services/functions/UserService.dart';
import 'package:frontend/utils/colors.dart';
import 'package:getwidget/getwidget.dart';
import 'package:frontend/services/models/course.dart';

class Downloads extends StatefulWidget {
  final String userId;
  const Downloads({
    required this.userId,
    super.key,
  });

  @override
  State<Downloads> createState() => _DownloadsState();
}

class _DownloadsState extends State<Downloads> {
  final EnrollmentService _enrollmentService = EnrollmentService();
  final CourseService _courseService = CourseService();
  late Future<List<Map<String, dynamic>>> _downloadedLessonsFuture;

  @override
  void initState() {
    super.initState();
    _downloadedLessonsFuture = _fetchDownloadedLessons();
  }

  Future<List<Map<String, dynamic>>> _fetchDownloadedLessons() async {
    List<Map<String, dynamic>> downloadedLessons = await _enrollmentService.getDownloadedLessons(widget.userId);
    List<Map<String, dynamic>> detailedLessons = [];

    for (var download in downloadedLessons) {
      String courseId = download['courseId'];
      List<String> lessonIds = List<String>.from(download['downloadedLessons']);

      for (var lessonId in lessonIds) {
        var lesson = await _fetchLesson(courseId, lessonId);
        var course = await _courseService.getCourseById(courseId);
        detailedLessons.add({
          'lesson': lesson,
          'course': course,
        });
      }
    }

    return detailedLessons;
  }

  Future<Map<String, dynamic>> _fetchLesson(String courseId, String lessonId) async {
    return await _courseService.getLesson(courseId, lessonId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.ghostWhite,
        centerTitle: true,
        title: Text(
          "Downloads",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _downloadedLessonsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No downloaded lessons.'));
          } else {
            var downloadedLessons = snapshot.data!;
            return ListView.separated(
              separatorBuilder: (context, index) {
                return Divider();
              },
              itemCount: downloadedLessons.length,
              itemBuilder: (context, index) {
                var lesson = downloadedLessons[index]['lesson'];
                var course = downloadedLessons[index]['course'] as Course;
                return GFListTile(
                  avatar: Icon(
                    Icons.play_circle_fill,
                    size: 40,
                  ),
                  title: Text(
                    lesson['title'],
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                    ),
                  ),
                  subTitle: Text(
                    'From Class: ${course.title}',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: TextStyle(fontFamily: "Poppins"),
                  ),
                  icon: Icon(
                    Icons.download_for_offline_sharp,
                    size: 32,
                    color: AppColors.deepBlue,
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
