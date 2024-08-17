import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/pages/course_pages/course_detail.dart';
import 'package:frontend/services/functions/CourseService.dart';
import 'package:frontend/services/functions/UserService.dart';
import 'package:frontend/widgets/class_management/teacher_class_item.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/widgets/my_loading.dart';
import 'package:frontend/services/models/course.dart';

class TeachingTabTeacher extends StatefulWidget {
  final String instructorId;
  final String teacherName;

  TeachingTabTeacher(this.instructorId, this.teacherName, {super.key});

  @override
  _TeachingTabTeacherState createState() => _TeachingTabTeacherState();
}

class _TeachingTabTeacherState extends State<TeachingTabTeacher> {
  //Services
  CourseService courseService = CourseService();
  UserService userService = UserService();
  String userId = "";

  late Future<List<Course>> _futureCourses;

  @override
  void initState() {
    super.initState();
    userId = userService.getUserId();
    _futureCourses = _fetchCourses();
  }

  Future<List<Course>> _fetchCourses() async {
    return await courseService.getCoursePublicByUserId(widget.instructorId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Course>>(
      future: _futureCourses,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MyLoading(
            width: 30,
            height: 30,
            color: AppColors.deepBlue,
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text("An error occurred. Please try again later"),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text("No classes found for this instructor."),
          );
        }

        List<Course> courses = snapshot.data!;

        return SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "${widget.teacherName}'s Classes",
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                ),
                AppSpacing.smallVertical,
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.25,
                  child: ListView.builder(
                    itemCount: courses.length,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      Course course = courses[index];

                      return TeacherClassItem(
                        classTitle: course.title,
                        thumbnail: course.thumbnail,
                        isPublic: course.isPublic,
                        onTap: () {
                          // Navigate to course detail page
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                              builder: (context) => CourseDetail(
                                courseId: course.id,
                                userId: userId,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
