// ignore_for_file: prefer_const_constructors

import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/services/functions/CourseService.dart';
import 'package:frontend/services/functions/EnrollmentService.dart';
import 'package:frontend/services/functions/UserService.dart';
import 'package:frontend/services/models/course.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/styles.dart';
import 'package:frontend/widgets/my_course.dart';

class MyCoursePage extends StatefulWidget {
  @override
  _MyCoursesPageState createState() => _MyCoursesPageState();
}

class _MyCoursesPageState extends State<MyCoursePage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final userService = UserService();
  final enrollmentService = EnrollmentService();
  final courseService = CourseService();
  List<String> courseIdEnrolled = [];
  List<Course> enrolledCourses = [];
  bool isLoading = true;
  String userId = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    userId = userService.getUserId();
    _fetchEnrolledCourses();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _fetchEnrolledCourses() async {
    try {
      List<Course> courses = [];
      courseIdEnrolled = await enrollmentService.getUserEnrollments(userId);
      log(courseIdEnrolled.toString());
      for (String courseId in courseIdEnrolled) {
        Course course = await courseService.getCourseById(courseId);
        courses.add(course);
      }
      setState(() {
        enrolledCourses = courses;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching enrolled courses: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.ghostWhite,
        title: Text('My courses', style: AppStyles.largeTitleSearchPage),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Courses'),
            Tab(text: 'My Lists'),
          ],
          labelColor: Colors.black,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorColor: Colors.black,
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            isLoading
                ? Center(child: CircularProgressIndicator())
                : enrolledCourses.isEmpty
                    ? _emptyCourse(context)
                    : ListView.builder(
                        itemCount: enrolledCourses.length,
                        itemBuilder: (context, index) {
                          Course course = enrolledCourses[index];
                          return MyCourseItem(
                            imageUrl: course.thumbnail,
                            title: course.title,
                            author: course.instructorName,
                            duration: course.duration,
                            students: course.students.toString(),
                            moreOnPress: () {},
                          );
                        },
                      ),
            Center(
              child: Text('Lists'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyCourse(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          CupertinoIcons.play_arrow,
          size: 100,
          color: Colors.black,
        ),
        SizedBox(height: 16),
        Text(
          'What are you waiting for?',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        SizedBox(height: 8),
        Text(
          'When you buy your first course, it will show up here.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.lightGrey,
          ),
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            // Handle button press
          },
          style: AppStyles.secondaryButtonStyle,
          child: Text(
            'See recommended courses',
            style: TextStyle(fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );
  }
}
