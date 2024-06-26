import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/pages/course_pages/discussion_tab.dart';
import 'package:frontend/pages/course_pages/lesson_tab.dart';
import 'package:frontend/pages/course_pages/submit_project_tab.dart';
import 'package:frontend/services/functions/EnrollmentService.dart';
import 'package:frontend/services/providers/EnrollmentProvider.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/utils/styles.dart';
import 'package:frontend/widgets/my_loading.dart';
import 'package:frontend/widgets/video_player_view.dart';
import 'package:frontend/services/models/course.dart';
import 'package:frontend/services/functions/CourseService.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class CourseDetail extends StatefulWidget {
  final String courseId;
  final String userId;

  const CourseDetail({super.key, required this.courseId, required this.userId});

  @override
  State<CourseDetail> createState() => _CourseDetailState();
}

class _CourseDetailState extends State<CourseDetail> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final courseService = CourseService();
  final enrollmentService = EnrollmentService();
  bool isFollowed = false;
  bool isEnrolled = false;
  Course? course;
  late Future<void> _futureCourseDetail;
  String _currentVideoUrl = '';
  String? _enrollmentId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _futureCourseDetail = _fetchCourseDetails();
    _checkEnrollment();
  }

  Future<void> _fetchCourseDetails() async {
    try {
      final fetchedCourse = await courseService.getCourseById(widget.courseId);
      setState(() {
        course = fetchedCourse;
        if (course!.lessons.isNotEmpty) {
          _currentVideoUrl = course!.lessons.first.link;
        }
      });
    } catch (e) {
      log("Error fetching course details: $e");
    }
  }

  Future<void> _checkEnrollment() async {
    try {
      final enrollmentStatus = await enrollmentService.checkEnrollment(widget.userId, widget.courseId);
      setState(() {
        isEnrolled = enrollmentStatus['isEnrolled'];
        _enrollmentId = enrollmentStatus['enrollmentId'];
      });
    } catch (e) {
      log("Error checking enrollment: $e");
    }
  }

  Future<void> _enrollInCourse() async {
    try {
      final enrollmentData = {
        'userId': widget.userId,
        'courseId': widget.courseId,
      };

      await enrollmentService.createEnrollment(enrollmentData);
      setState(() {
        isEnrolled = true;
      });

      Provider.of<EnrollmentProvider>(context, listen: false).enroll();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enrollment successful!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to enroll: $e')),
      );
    }
  }

  Future<void> _saveLesson(String lessonId) async {
  if (_enrollmentId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Enrollment ID is null. Cannot save lesson.')),
    );
    return;
  }

  try {
    await enrollmentService.addLessonToEnrollment(_enrollmentId!, lessonId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Lesson saved successfully!')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to save lesson: $e')),
    );
  }
}


  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> followUser() async {
    setState(() {
      isFollowed = !isFollowed;
    });
  }

  void _onLessonTap(String videoUrl) {
    setState(() {
      _currentVideoUrl = videoUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: isEnrolled
          ? null
          : Container(
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
                  FutureBuilder(
                    future: _futureCourseDetail,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox.shrink();
                      }
                      return Text(
                        "${course!.price.toString()}đ",
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                      );
                    },
                  ),
                  AppSpacing.mediumHorizontal,
                  Expanded(
                    child: TextButton(
                      style: AppStyles.primaryButtonStyle,
                      onPressed: _enrollInCourse,
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Purchase",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
      appBar: AppBar(
        surfaceTintColor: AppColors.ghostWhite,
        leading: IconButton(
          icon: const Icon(
            CupertinoIcons.xmark,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(CupertinoIcons.bookmark),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(CupertinoIcons.share),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            VideoPlayerView(
              url: _currentVideoUrl,
              dataSourceType: DataSourceType.network,
            ),
            TabBar(
              tabAlignment: TabAlignment.center,
              isScrollable: true,
              controller: _tabController,
              splashFactory: NoSplash.splashFactory,
              tabs: const [
                Tab(text: 'Lessons'),
                Tab(text: 'Projects'),
                Tab(text: 'Discussions'),
                Tab(text: 'Notes'),
              ],
              labelStyle: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              unselectedLabelColor: Colors.black,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorColor: Colors.black,
              indicatorWeight: 3,
            ),
            Expanded(
              child: FutureBuilder(
                future: _futureCourseDetail,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const MyLoading(
                      width: 30,
                      height: 30,
                      color: AppColors.deepBlue,
                    );
                  }
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      LessonTab(
                          isFollowed: isFollowed,
                          followUser: followUser,
                          course: course!,
                          isEnrolled: isEnrolled,
                          onLessonTap: _onLessonTap,
                          onSaveLesson: _saveLesson,
                        ),
                      SubmitProject(
                        course: course!,
                      ),
                      Discussion(),
                      Center(
                        child: Text("Notes"),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
