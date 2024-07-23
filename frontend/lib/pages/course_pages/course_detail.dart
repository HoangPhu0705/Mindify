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

class CourseDetail extends StatefulWidget {
  final String courseId;
  final String userId;

  const CourseDetail({super.key, required this.courseId, required this.userId});

  @override
  State<CourseDetail> createState() => _CourseDetailState();
}

class _CourseDetailState extends State<CourseDetail>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final courseService = CourseService();
  final enrollmentService = EnrollmentService();
  final userService = UserService();
  bool isFollowed = false;
  bool isEnrolled = false;
  late bool isSaved;
  Course? course;
  String _currentVideoUrl = '';
  int _currentVideoIndex = 0;
  int _currentTime = 0;
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
      isSaved = await userService.checkSavedCourse(userId, widget.courseId);
    } catch (e) {
      log("Error fetching course details: $e");
    }
  }

  Future<void> _getWatchingData() async {
    try {
      final data = await userService.getWatchedHistories(userId);
      final courseHistory = data
          .where((course) => course['courseId'] == widget.courseId)
          .toList();
      if (courseHistory.isNotEmpty) {
        final time = courseHistory[0]["time"];
        final lessonIndex = courseHistory[0]["index"];
        final url = courseHistory[0]["lessonUrl"];
        setState(() {
          _currentVideoIndex = lessonIndex;
          _currentVideoUrl = url;
          _currentTime = time;
        });
      }
    } catch (e) {
      log("$e");
      throw Exception(e);
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
          await userService.checkIfUserFollows(userId, course!.instructorId);
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
    await _getWatchingData();
  }

  Future<void> _saveLesson(String lessonId) async {
    if (_enrollmentId == null) {
      showErrorToast(context, 'You have to purchase this course first');
      return;
    }

    try {
      await enrollmentService.addLessonToEnrollment(_enrollmentId!, lessonId);
      if (mounted) {
        showSuccessToast(context, 'Lesson saved successfully!');
      }
    } catch (e) {
      if (mounted) {
        showErrorToast(context, 'Failed to save lesson');
      }
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    // _videoPlayerKey.currentState!.dispose();
    super.dispose();
  }

  Future<void> _saveWatchedTime(int time) async {
    try {
      await userService.addToWatchedHistories(widget.userId, widget.courseId,
          course!.lessons[_currentVideoIndex].id, time);
    } catch (e) {
      log("Error saving watched time: $e");
    }
  }

  Future<void> _toggleSaveCourse() async {
    try {
      if (isSaved) {
        await userService.unsaveCourseForUser(userId, widget.courseId);
      } else {
        await userService.saveCourseForUser(userId, widget.courseId);
      }
      setState(() {
        isSaved = !isSaved;
      });
    } catch (e) {
      log("Error toggling save course: $e");
      showErrorToast(context, 'Failed to update save status');
    }
  }

  Future<void> followUser() async {
    try {
      await userService.followUser(userId, course!.instructorId);
      setState(() {
        isFollowed = !isFollowed;
      });
    } catch (e) {
      if (mounted) {
        showSuccessToast(context, 'Failed to follow user');
      }
      log(e.toString());
    }
  }

  void _onLessonTap(String videoUrl, int index) async {
    setState(() {
      _currentVideoUrl = videoUrl;
      _currentVideoIndex = index;
    });

    _videoPlayerKey.currentState?.goToVideo(videoUrl);
  }

  void _navigateToPaymentScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          userId: widget.userId,
          courseId: widget.courseId,
          price: course!.price,
          course: course!,
        ),
      ),
    );
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
          bottomSheet: isEnrolled
              ? const SizedBox.shrink()
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
                      Text(
                        "${course!.price.toString()}đ",
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      AppSpacing.mediumHorizontal,
                      Expanded(
                        child: TextButton(
                          style: AppStyles.primaryButtonStyle,
                          onPressed: _navigateToPaymentScreen,
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
              onPressed: () async {
                int time = _videoPlayerKey.currentState!.getCurrentTime();
                await _saveWatchedTime(time);
                if (mounted) {
                  Navigator.pop(context);
                }
              },
            ),
            actions: [
              IconButton(
                onPressed: _toggleSaveCourse,
                icon: Icon(
                  isSaved
                      ? CupertinoIcons.bookmark_solid
                      : CupertinoIcons.bookmark,
                  // color: isSaved ? Colors.white : Colors.black,
                ),
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
                  key: _videoPlayerKey,
                  url: _currentVideoUrl,
                  dataSourceType: DataSourceType.network,
                  currentTime: _currentTime,
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
                        isFollowed: isFollowed,
                        instructorId: course!.instructorId,
                        userId: userId,
                        course: course!,
                        currentVideoIndex: _currentVideoIndex,
                        isEnrolled: isEnrolled,
                        onLessonTap: _onLessonTap,
                        onSaveLesson: _saveLesson,
                        isPreviewing: false,
                      ),
                      SubmitProject(
                        course: course!,
                        isPreviewing: false,
                      ),
                      Discussion(
                        isPreviewing: false,
                        courseId: course!.id,
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
