import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/pages/course_pages/discussion_tab.dart';
import 'package:frontend/pages/course_pages/lesson_tab.dart';
import 'package:frontend/pages/course_pages/payment_page.dart';
import 'package:frontend/pages/course_pages/submit_project_tab.dart';
import 'package:frontend/services/functions/EnrollmentService.dart';
import 'package:frontend/services/providers/EnrollmentProvider.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/utils/styles.dart';
import 'package:frontend/utils/toasts.dart';
import 'package:frontend/widgets/my_loading.dart';
import 'package:frontend/widgets/video_player_view.dart';
import 'package:frontend/services/models/course.dart';
import 'package:frontend/services/functions/CourseService.dart';
import 'package:frontend/services/functions/UserService.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class PreviewClass extends StatefulWidget {
  final String courseId;
  final String userId;

  const PreviewClass({super.key, required this.courseId, required this.userId});

  @override
  State<PreviewClass> createState() => _PreviewClassState();
}

class _PreviewClassState extends State<PreviewClass>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final courseService = CourseService();
  final enrollmentService = EnrollmentService();
  final userService = UserService();
  bool isFollowed = false;
  bool isEnrolled = false;
  Course? course;
  String _currentVideoUrl = '';
  int _currentVideoIndex = 0;
  String? _enrollmentId;
  String userId = '';
  late Future<void> _future;

  final GlobalKey<VideoPlayerViewState> _videoPlayerKey =
      GlobalKey<VideoPlayerViewState>();

  @override
  void initState() {
    super.initState();
    userId = userService.getUserId();
    _tabController = TabController(length: 4, vsync: this);
    _future = _initCourseDetailPage();
  }

  Future<void> _fetchCourseDetails() async {
    try {
      await courseService.getCourseById(widget.courseId).then((value) {
        course = value;
        if (course!.lessons.isNotEmpty) {
          _currentVideoUrl =
              course!.lessons.where((lesson) => lesson.index == 0).first.link;
        }
      });
    } catch (e) {
      log("Error fetching course details: $e");
    }
  }

  Future<void> _checkEnrollment() async {
    try {
      final enrollmentStatus = await enrollmentService.checkEnrollment(
          widget.userId, widget.courseId);
      setState(() {
        isEnrolled = enrollmentStatus['isEnrolled'];
        _enrollmentId = enrollmentStatus['enrollmentId'];
      });
    } catch (e) {
      log("Error checking enrollment: $e");
    }
  }

  Future<void> _checkIfFollowed() async {
    try {
      bool followed =
          await userService.checkIfUserFollows(userId, widget.userId);
      setState(() {
        isFollowed = followed;
      });
    } catch (e) {
      log("Error checking follow status: $e");
    }
  }

  Future<void> _initCourseDetailPage() async {
    await _fetchCourseDetails();
    await _checkEnrollment();
    await _checkIfFollowed();
  }

  Future<void> _saveLesson(String lessonId) async {
    if (_enrollmentId == null) {
      showErrorToast(context, 'You have to purchase this course first');
      return;
    }

    try {
      await enrollmentService.addLessonToEnrollment(_enrollmentId!, lessonId);
      showSuccessToast(context, 'Lesson saved successfully!');
    } catch (e) {
      showErrorToast(context, 'Failed to save lesson');
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _onLessonTap(String videoUrl, int index) {
    setState(() {
      _currentVideoUrl = videoUrl;
      _currentVideoIndex = index;
    });
    _videoPlayerKey.currentState?.goToVideo(videoUrl);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: MyLoading(
                width: 30,
                height: 30,
                color: AppColors.deepBlue,
              ),
            ),
          );
        }
        return Scaffold(
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
          ),
          body: SafeArea(
            child: Column(
              children: [
                VideoPlayerView(
                  key: _videoPlayerKey,
                  url: _currentVideoUrl,
                  dataSourceType: DataSourceType.network,
                  currentTime: 0,
                  onVideoEnd: () => {},
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
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      LessonTab(
                        isPreviewing: true,
                        isFollowed: isFollowed,
                        instructorId: course!.instructorId,
                        userId: userId,
                        course: course!,
                        enrollmentId: '',
                        currentVideoIndex: _currentVideoIndex,
                        isEnrolled: isEnrolled,
                        onLessonTap: _onLessonTap,
                        onSaveLesson: _saveLesson,
                      ),
                      SubmitProject(
                        course: course!,
                        isPreviewing: true,
                      ),
                      Discussion(
                        isPreviewing: true,
                        courseId: course!.id,
                        instructorId: course!.instructorId,
                        isEnrolled: isEnrolled,
                      ),
                      const Center(
                        child: Text("Notes"),
                      ),
                    ],
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
