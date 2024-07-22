import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/services/functions/CourseService.dart';
import 'package:frontend/services/functions/QuizService.dart';
import 'package:frontend/services/functions/UserService.dart';
import 'package:frontend/services/models/course.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/utils/styles.dart';
import 'package:frontend/widgets/course_card.dart';
import 'package:frontend/widgets/my_course.dart';
import 'package:frontend/widgets/my_loading.dart';

class PublishCourse extends StatefulWidget {
  final String courseId;
  final int lessonNums;
  const PublishCourse({
    super.key,
    required this.courseId,
    required this.lessonNums,
  });

  @override
  State<PublishCourse> createState() => _PublishCourseState();
}

class _PublishCourseState extends State<PublishCourse> {
  CourseService courseService = CourseService();
  UserService userService = UserService();

  late Course myCourse;
  late Future<void> _future;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _future = _initCourseDetailPage();
  }

  Future<void> _initCourseDetailPage() async {
    await _fetchCourseDetails();
  }

  Future<void> _fetchCourseDetails() async {
    try {
      myCourse = await courseService.getCourseById(widget.courseId);
      log(myCourse.toString());
    } catch (e) {
      log("Error getting course $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.ghostWhite,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              offset: const Offset(0, -1),
            ),
          ],
        ),
        height: MediaQuery.of(context).size.height * 0.1,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppSpacing.mediumHorizontal,
            Expanded(
              child: TextButton(
                style: AppStyles.primaryButtonStyle,
                onPressed: () async {},
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Publish Course",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      appBar: AppBar(),
      body: FutureBuilder(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: MyLoading(
                  width: 30,
                  height: 30,
                  color: AppColors.deepBlue,
                ),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text("Error: ${snapshot.error}"),
              );
            }

            return SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CourseCard(
                    thumbnail: "https://i.ibb.co/tZxYspW/default-avatar.png",
                    instructor: myCourse.instructorName,
                    specialization: "Mindify Instructor",
                    courseName: myCourse.title,
                    time: myCourse.duration,
                    numberOfLesson: widget.lessonNums,
                    avatar: Image.network(userService.getPhotoUrl()),
                    onSavePressed: () {},
                    isSaved: false,
                  )
                ],
              ),
            );
          }),
    );
  }
}
