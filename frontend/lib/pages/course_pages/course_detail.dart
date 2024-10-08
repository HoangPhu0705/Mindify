import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_pannable_rating_bar/flutter_pannable_rating_bar.dart';
import 'package:frontend/pages/course_pages/discussion_tab.dart';
import 'package:frontend/pages/course_pages/lesson_tab.dart';
import 'package:frontend/pages/course_pages/note_tab.dart';
import 'package:frontend/pages/course_pages/payment_page.dart';
import 'package:frontend/pages/course_pages/submit_project_tab.dart';
import 'package:frontend/services/functions/EnrollmentService.dart';
import 'package:frontend/services/functions/FeedbackService.dart';
import 'package:frontend/services/functions/ReportService.dart';
import 'package:frontend/services/providers/CourseProvider.dart';
import 'package:frontend/services/providers/EnrollmentProvider.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/utils/styles.dart';
import 'package:frontend/utils/toasts.dart';
import 'package:frontend/widgets/my_loading.dart';
import 'package:frontend/widgets/report_dialog.dart';
import 'package:frontend/widgets/video_player_view.dart';
import 'package:frontend/services/models/course.dart';
import 'package:frontend/services/functions/CourseService.dart';
import 'package:frontend/services/functions/UserService.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;

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
  ReportService reportService = ReportService();
  final feedbackService = FeedbackService();
  double? ratingAverage;

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

  Future<void> _getRatingAverage() async {
    log("haha");
    final rating = await feedbackService.getCourseRating(widget.courseId);
    log("rating ne" + rating.toString());
    log(ratingAverage.toString());
    setState(() {
      ratingAverage = rating;
    });
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
      final enrollmentStatus =
          await enrollmentService.checkEnrollment(userId, widget.courseId);
      // log(enrollmentStatus['isEnrolled'].toString());
      setState(() {
        isEnrolled = enrollmentStatus['isEnrolled'];
        _enrollmentId = enrollmentStatus['enrollmentId'];
      });
    } catch (e) {
      log("Error checking enrollment dmmm: $e");
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
    await _getRatingAverage();
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
    // _showRatingDialog();
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
        Provider.of<CourseProvider>(context, listen: false)
            .unsaveCourse(widget.courseId);
      } else {
        await userService.saveCourseForUser(userId, widget.courseId);
        Provider.of<CourseProvider>(context, listen: false)
            .saveCourse(widget.courseId);
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

  Future<void> _addProgressToEnrollment() async {
    try {
      final lessonId = course!.lessons[_currentVideoIndex].id;
      if (_enrollmentId != null) {
        await enrollmentService.addProgressToEnrollment(
            _enrollmentId!, lessonId);
        log("Progress added to enrollment");
      } else {
        log("No enrollment found");
      }
    } catch (e) {
      log("Error adding progress to enrollment: $e");
    }
  }

  void _handleVideoEnd(String videoUrl) async {
    if (!isEnrolled) return; 

    await _addProgressToEnrollment();
    
    bool isLooping = _videoPlayerKey.currentState!.islooping();

    if (isLooping) {
      log("Video is looping, staying on the same video.");
      return;
    }

    if (_currentVideoIndex < course!.lessons.length - 1) {
      final nextVideoUrl = course!.lessons[_currentVideoIndex + 1].link;
      setState(() {
        _currentVideoUrl = nextVideoUrl;
        _currentVideoIndex++;
      });
      await _videoPlayerKey.currentState?.goToVideo(nextVideoUrl);
    }
  }

  Future<void> _onLessonTap(
    String videoUrl,
    int index,
  ) async {
    setState(() {
      _currentVideoUrl = videoUrl;
      _currentVideoIndex = index;
    });

    await _videoPlayerKey.currentState?.goToVideo(videoUrl);
  }

  Future<void> onNoteTap(String videoUrl, int index, int duration) async {
    await _onLessonTap(videoUrl, index);

    await _videoPlayerKey.currentState!.seekToPeriod(
      Duration(
        seconds: duration,
      ),
    );
  }

  void showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return ReportDialog(
          courseId: course!.id,
          courseTitle: course!.title,
          authorId: course!.instructorId,
        );
      },
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
          resizeToAvoidBottomInset: true,
          bottomSheet: isEnrolled || widget.userId == course!.instructorId
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
                        "${NumberFormat.decimalPattern('vi').format(course!.price)}đ",
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      AppSpacing.mediumHorizontal,
                      Expanded(
                        child: TextButton(
                          style: AppStyles.primaryButtonStyle,
                          onPressed: () async {
                            //Stop video

                            final result = await Navigator.push(
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
                            if (result != null) {
                              setState(() {
                                isEnrolled = true;
                              });
                              await _checkEnrollment();
                            }
                          },
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
                onPressed: () {
                  showReportDialog(context);
                },
                icon: const Icon(Icons.flag_outlined),
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
                  onVideoEnd: _handleVideoEnd,
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
                          enrollmentId: _enrollmentId ?? "",
                          currentVideoIndex: _currentVideoIndex,
                          isEnrolled: isEnrolled,
                          onLessonTap: _onLessonTap,
                          onSaveLesson: _saveLesson,
                          isPreviewing: false,
                          ratingAverage: ratingAverage!),
                      SubmitProject(
                        course: course!,
                        isPreviewing: false,
                      ),
                      Discussion(
                        isPreviewing: false,
                        courseId: course!.id,
                        instructorId: course!.instructorId,
                        isEnrolled: isEnrolled,
                      ),
                      NoteTab(
                        playerkey: _videoPlayerKey,
                        lessonIndex: _currentVideoIndex,
                        lessonId: course!.lessons[_currentVideoIndex].id,
                        lessonTitle: course!.lessons[_currentVideoIndex].title,
                        lessonUrl: _currentVideoUrl,
                        onNoteTap: onNoteTap,
                        enrollmentId: _enrollmentId ?? "",
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
