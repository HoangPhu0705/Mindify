import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:frontend/pages/course_management/quiz_page.dart';
import 'package:frontend/pages/course_pages/instructor_profile.dart';
import 'package:frontend/services/functions/EnrollmentService.dart';
import 'package:frontend/services/functions/QuizService.dart';
import 'package:frontend/services/models/course.dart';
import 'package:frontend/services/models/lesson.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:frontend/utils/toasts.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:frontend/services/functions/UserService.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class LessonTab extends StatefulWidget {
  bool isFollowed;
  bool isPreviewing;
  final String instructorId;
  final String userId;
  final Course course;
  final String enrollmentId;
  final bool isEnrolled;
  final int currentVideoIndex;
  final void Function(String, int) onLessonTap;
  final void Function(String) onSaveLesson;

  LessonTab({
    Key? key,
    required this.isFollowed,
    required this.isPreviewing,
    required this.instructorId,
    required this.userId,
    required this.course,
    required this.enrollmentId,
    required this.isEnrolled,
    required this.onLessonTap,
    required this.onSaveLesson,
    required this.currentVideoIndex,
  }) : super(key: key);

  @override
  State<LessonTab> createState() => _LessonTabState();
}

class _LessonTabState extends State<LessonTab> {
  DateTime? _lastNotificationTime;
  final userService = UserService();
  final enrollmentService = EnrollmentService();
  Map<String, dynamic> instructorInfo = {};
  String instructorAvatar = "";
  String instructorName = "";
  ScrollController scrollController = ScrollController();
  QuillController quillController = QuillController.basic();

  FocusNode focusNode = FocusNode(canRequestFocus: false);

  QuizService quizService = QuizService();
  List<String> completedLessons = [];
  @override
  void initState() {
    super.initState();
    _getInstructorInfo();
    _sortLessonsByIndex();
    _fetchProgress();

    if (!widget.isPreviewing) _checkIfFollowed();
    quillController.document = Document.fromJson(
      jsonDecode(widget.course.description),
    );
  }

  void _sortLessonsByIndex() {
    widget.course.lessons.sort((a, b) => a.index.compareTo(b.index));
  }

  Future<void> _checkIfFollowed() async {
    try {
      bool followed = await userService.checkIfUserFollows(
          widget.userId, widget.instructorId);
      setState(() {
        widget.isFollowed = followed;
      });
    } catch (e) {
      log("Error checking follow status: $e");
    }
  }

  Future<void> _getInstructorInfo() async {
    final info = await userService.getUserInfoById(widget.course.instructorId);
    if (info != null) {
      final data =
          await userService.getAvatarAndDisplayName(widget.course.instructorId);
      setState(() {
        instructorInfo = {...info};
        instructorAvatar = data!['photoUrl'];
        instructorName = data['displayName'];
      });
    }
  }

  Future<void> _downloadLesson(String lessonLink, String lessonId) async {
    final directory = await getExternalStorageDirectory();
    final path = directory?.path;
    if (path != null) {
      await FlutterDownloader.enqueue(
        url: lessonLink,
        savedDir: path,
        fileName: 'lesson_$lessonId.mp4',
        showNotification: true,
        openFileFromNotification: true,
      );
    }
  }

  bool _canUpdateNotification() {
    final now = DateTime.now();
    if (_lastNotificationTime == null ||
        now.difference(_lastNotificationTime!).inSeconds > 5) {
      _lastNotificationTime = now;
      return true;
    }
    return false;
  }

  Future<void> _followUser() async {
    try {
      await userService.followUser(widget.userId, widget.instructorId);
      setState(() {
        widget.isFollowed = true;
      });
    } catch (e) {
      log(e.toString());
      if (mounted) showErrorToast(context, 'Failed to follow user');
    }
  }

  Future<void> _unfollowUser() async {
    try {
      await userService.unfollowUser(widget.userId, widget.instructorId);
      setState(() {
        widget.isFollowed = false;
      });
    } catch (e) {
      log(e.toString());
      if (mounted) showErrorToast(context, 'Failed to unfollow user');
    }
  }

  Future<void> _fetchProgress() async {
    try {
      final progress =
          await enrollmentService.getProgressOfEnrollment(widget.enrollmentId);
          log(progress.toString());
      setState(() {
        completedLessons = progress;
      });
    } catch (e) {
      log("Error fetching progress: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.course.title,
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          fontSize: 20,
                        ),
                  ),
                  AppSpacing.mediumVertical,
                  Text("${widget.course.students} students"),
                  AppSpacing.mediumVertical,
                  _buildQuillEditor(
                    quillController,
                    scrollController,
                    false,
                  ),
                  AppSpacing.mediumVertical,
                  Align(
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: () {
                        showAllDescription(context);
                      },
                      child: const Text(
                        "Show all",
                        style: TextStyle(
                          color: AppColors.deepBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  AppSpacing.mediumVertical,
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => InstructorProfile(
                                instructorId: widget.course.instructorId,
                              ),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            CircleAvatar(
                              maxRadius: 24,
                              backgroundImage: instructorAvatar.isNotEmpty
                                  ? NetworkImage(instructorAvatar)
                                  : const NetworkImage(
                                      "https://i.ibb.co/tZxYspW/default-avatar.png"),
                            ),
                            AppSpacing.smallHorizontal,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  instructorName.isEmpty
                                      ? 'Mindify Member'
                                      : instructorName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  instructorInfo['profession'] ??
                                      "Mindify Instructor",
                                  style: const TextStyle(
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (widget.userId != widget.instructorId &&
                          !widget.isPreviewing)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: AnimatedButton(
                            onPress:
                                widget.isFollowed ? _unfollowUser : _followUser,
                            isSelected: widget.isFollowed,
                            width: 100,
                            height: 40,
                            borderColor: AppColors.deepBlue,
                            borderWidth: 1,
                            borderRadius: 50,
                            backgroundColor: Colors.transparent,
                            selectedBackgroundColor: AppColors.deepBlue,
                            selectedTextColor: Colors.white,
                            transitionType: TransitionType.RIGHT_BOTTOM_ROUNDER,
                            selectedText: "Following",
                            text: 'Follow',
                            textStyle: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: AppColors.deepBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Divider(),
                  AppSpacing.mediumVertical,
                  Row(
                    children: [
                      const Flexible(
                        flex: 2,
                        child: Divider(),
                      ),
                      Flexible(
                        child: Center(
                            child: Text(
                          "LESSONS",
                          style: Theme.of(context).textTheme.labelSmall,
                        )),
                      ),
                      const Flexible(
                        flex: 2,
                        child: Divider(),
                      ),
                    ],
                  ),
                  Text(
                    "${widget.course.lessons.length} Lessons in ${widget.course.duration}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height * 0.1),
              child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.course.lessons.length,
                    itemBuilder: (context, index) {
                      final lesson = widget.course.lessons[index];
                      final isCompleted = completedLessons.contains(lesson.id);
                      log(lesson.id);
                      log(isCompleted.toString());
                      final isLessonAccessible =
                          widget.isEnrolled || index == 0;

                      return Container(
                        margin: const EdgeInsets.only(
                          bottom: 10,
                        ),
                        child: ListTile(
                          tileColor: lesson.index == widget.currentVideoIndex
                              ? AppColors.deepSpace
                              : Colors.white,
                          onTap: isLessonAccessible || widget.isPreviewing
                              ? () {
                                  widget.onLessonTap(lesson.link, lesson.index);
                                }
                              : null,
                          title: Text(
                            "${lesson.index + 1}. ${lesson.title}",
                            style: TextStyle(
                              color: lesson.index == widget.currentVideoIndex
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            lesson.duration,
                            style: TextStyle(
                              color: lesson.index == widget.currentVideoIndex
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                          leading: Icon(
                            isLessonAccessible || widget.isPreviewing
                                ? (isCompleted
                                    ? Icons.check_circle_outline
                                    : Icons.play_circle_outline_outlined)
                                : Icons.lock,
                            size: 30,
                            color: lesson.index == widget.currentVideoIndex
                                ? Colors.white
                                : Colors.black,
                          ),
                          trailing: widget.isEnrolled
                              ? IconButton(
                                  icon: Icon(
                                    Icons.download_for_offline_outlined,
                                    size: 30,
                                    color:
                                        lesson.index == widget.currentVideoIndex
                                            ? Colors.white
                                            : Colors.black,
                                  ),
                                  onPressed: isLessonAccessible
                                      ? () {
                                          _downloadLesson(
                                              lesson.link, lesson.title);
                                          widget.onSaveLesson(lesson.id);
                                        }
                                      : null,
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                  AppSpacing.mediumVertical,
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const Flexible(
                          flex: 2,
                          child: Divider(),
                        ),
                        Flexible(
                          child: Center(
                              child: Text(
                            "Quizzes",
                            style: Theme.of(context).textTheme.labelSmall,
                          )),
                        ),
                        const Flexible(
                          flex: 2,
                          child: Divider(),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.mediumVertical,
                  StreamBuilder<QuerySnapshot>(
                    stream:
                        quizService.getQuizzesStreamByCourse(widget.course.id),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        List<DocumentSnapshot> quizzes = snapshot.data!.docs;
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: quizzes.length,
                          itemBuilder: (context, index) {
                            DocumentSnapshot quiz = quizzes[index];
                            String quizId = quiz.id;
                            String quizName = quiz["name"];
                            int totalQuestion = quiz["totalQuestions"];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: buildQuizCard(
                                quizId,
                                quizName,
                                totalQuestion,
                              ),
                            );
                          },
                        );
                      }
                      return Text(
                        "No quizzes available",
                        style: TextStyle(
                          color: AppColors.lightGrey,
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildQuizCard(String quizId, String quizName, int totalQuestion) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.ghostWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.lightGrey,
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.lighterGrey,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return QuizPage(
                  quizId: quizId,
                  quizName: quizName,
                  totalQuestion: totalQuestion,
                );
              },
            ),
          );
        },
        title: Text(
          quizName,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        subtitle: Text("Questions: $totalQuestion"),
        trailing: const Icon(
          Icons.quiz_outlined,
          size: 30,
          color: AppColors.deepSpace,
        ),
      ),
    );
  }

  Widget _buildQuillEditor(QuillController controller,
      ScrollController scrollController, bool showAll) {
    return Container(
      width: double.infinity,
      height: showAll
          ? MediaQuery.of(context).size.height * 0.7
          : MediaQuery.of(context).size.height * 0.1,
      child: quill.QuillEditor.basic(
        focusNode: focusNode,
        scrollController: scrollController,
        configurations: QuillEditorConfigurations(
          controller: controller,
          scrollPhysics: showAll ? null : const NeverScrollableScrollPhysics(),
          autoFocus: false,
          scrollable: true,
          showCursor: false,
          sharedConfigurations: const QuillSharedConfigurations(
            locale: Locale('en'),
          ),
        ),
      ),
    );
  }

  void showAllDescription(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: AppColors.ghostWhite,
      builder: (context) {
        return SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.9,
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0),
              ),
            ),
            child: Column(
              children: [
                AppBar(
                  backgroundColor: AppColors.ghostWhite,
                  leading: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.close,
                        size: 20,
                      )),
                  title: const Text(
                    "Class Description",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  centerTitle: true,
                ),
                SingleChildScrollView(
                  child: _buildQuillEditor(
                    quillController,
                    scrollController,
                    true,
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
