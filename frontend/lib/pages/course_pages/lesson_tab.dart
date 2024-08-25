import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:dio/dio.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter_pannable_rating_bar/flutter_pannable_rating_bar.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:frontend/pages/course_management/quiz_page.dart';
import 'package:frontend/pages/course_pages/instructor_profile.dart';
import 'package:frontend/services/functions/EnrollmentService.dart';
import 'package:frontend/services/functions/FeedbackService.dart';
import 'package:frontend/services/functions/QuizService.dart';
import 'package:frontend/services/models/course.dart';
import 'package:frontend/services/models/lesson.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:frontend/utils/styles.dart';
import 'package:frontend/utils/toasts.dart';
import 'package:frontend/widgets/my_loading.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:frontend/services/functions/UserService.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:open_file/open_file.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:getwidget/getwidget.dart';
import 'package:timeago/timeago.dart' as timeago;

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
  final double ratingAverage;

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
    required this.ratingAverage,
  }) : super(key: key);

  @override
  State<LessonTab> createState() => LessonTabState();
}

class LessonTabState extends State<LessonTab> {
  final userService = UserService();
  final enrollmentService = EnrollmentService();
  final feedbackService = FeedbackService();

  Map<String, dynamic> instructorInfo = {};
  String instructorAvatar = "";
  String instructorName = "";
  ScrollController scrollController = ScrollController();
  QuillController quillController = QuillController.basic();
  bool isDownloading = false;
  int? currentIndexDownload;
  double downloadProgress = 0.0;
  CancelToken cancelToken = CancelToken();
  FocusNode focusNode = FocusNode(canRequestFocus: false);
  final GlobalKey<FormState> feedbackFormKey = GlobalKey<FormState>();
  final feedBackController = TextEditingController();

  QuizService quizService = QuizService();
  List<String> completedLessons = [];
  // double? ratingAvg;

  @override
  void initState() {
    // log(quizService.idToken!);
    super.initState();

    _getInstructorInfo();
    _sortLessonsByIndex();
    if (widget.enrollmentId.isNotEmpty) {
      fetchProgress();
    }

    if (!widget.isPreviewing) _checkIfFollowed();
    quillController.document = Document.fromJson(
      jsonDecode(widget.course.description),
    );
  }

  Future<void> setFetchProgress() async {
    await fetchProgress();
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

  Future<void> _showRatingDialog() async {
    double? rating = await showDialog<double>(
      context: context,
      builder: (context) {
        double rating = 0.0;
        return AlertDialog(
          title: const Text(
            'Rate this course',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          backgroundColor: AppColors.deepSpace,
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PannableRatingBar(
                    rate: rating,
                    items: List.generate(
                        5,
                        (index) => const RatingWidget(
                              selectedColor: AppColors.cream,
                              unSelectedColor: AppColors.lightGrey,
                              child: Icon(
                                Icons.star_rate_rounded,
                                size: 48,
                              ),
                            )),
                    onChanged: (value) {
                      setState(() {
                        rating = value;
                      });
                    },
                  ),
                  AppSpacing.mediumVertical,
                  Form(
                    key: feedbackFormKey,
                    child: TextFormField(
                      controller: feedBackController,
                      cursorColor: AppColors.cream,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please provide feedback";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        hintText: 'Say something',
                        hintStyle: TextStyle(
                          color: AppColors.lightGrey,
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.lightGrey,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.cream,
                          ),
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: AppStyles.primaryButtonStyle.copyWith(
                backgroundColor: WidgetStateProperty.all(Colors.transparent),
                side: WidgetStateProperty.all(
                  const BorderSide(
                    color: AppColors.cream,
                    width: 1.0,
                    style: BorderStyle.solid,
                  ),
                ),
              ),
              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: AppColors.cream,
                  fontSize: 16,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                if (feedbackFormKey.currentState!.validate()) {
                  Navigator.of(context).pop(rating);
                }
              },
              style: AppStyles.primaryButtonStyle,
              child: const Text(
                "Submit",
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (rating != null) {
      await _submitRating(rating);
    }
  }

  Future<void> _submitRating(double rating) async {
    try {
      final feedback = {
        'rating': rating,
        'userId': widget.userId,
        // 'displayName': FirebaseAuth.instance.currentUser!.displayName,
        // 'photoUrl': FirebaseAuth.instance.currentUser!.photoURL ?? '',
        'content': feedBackController.text,
      };
      await feedbackService.giveFeedback(
        widget.course.id,
        feedback,
      );
      feedBackController.clear();
      showSuccessToast(context, 'Thank you for your feedback!');
    } catch (e) {
      showErrorToast(context, 'Failed to submit feedback');
    }
  }

  Future<void> _downloadLesson(
      String lessonLink, String courseName, String lessonTitle) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;

      final userDirectory = Directory('$path/${widget.userId}');
      if (!await userDirectory.exists()) {
        await userDirectory.create();
      }

      final filePath = '${userDirectory.path}/${courseName}_$lessonTitle.mp4';

      Dio dio = Dio();

      if (cancelToken.isCancelled) {
        cancelToken = CancelToken();
      }

      await dio.download(
        lessonLink,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              downloadProgress = (received / total * 100);
            });
          }
        },
        cancelToken: cancelToken,
      );
      OpenFile.open(filePath);
      if (mounted) {
        showSuccessToast(context, 'Downloaded: $lessonTitle');
      }
    } catch (e) {
      log("Error downloading lesson: $e");
      if (mounted) showErrorToast(context, 'Failed to download lesson');
    }
  }

  void cancelDownload() {
    setState(() {
      cancelToken.cancel();
      isDownloading = false;
      currentIndexDownload = null;
    });
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

  Future<void> fetchProgress() async {
    try {
      final progress =
          await enrollmentService.getProgressOfEnrollment(widget.enrollmentId);
      log(progress.toString());
      if (mounted) {
        setState(() {
          completedLessons = progress;
        });
      }
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
                  Row(
                    children: [
                      const Icon(
                        Icons.people_outline_outlined,
                        color: AppColors.grey,
                      ),
                      AppSpacing.smallHorizontal,
                      Text(
                        "${widget.course.students} students",
                      ),
                    ],
                  ),
                  AppSpacing.mediumVertical,
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: AppColors.deepBlue,
                      ),
                      AppSpacing.smallHorizontal,
                      Text(
                        "${widget.ratingAverage.toStringAsFixed(1)} / 5 rating",
                      ),
                    ],
                  ),
                  AppSpacing.mediumVertical,
                  _buildQuillEditor(
                    quillController,
                    scrollController,
                    false,
                  ),
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
                  const Divider(),
                  const Text(
                    "Details",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                  ),
                  AppSpacing.mediumVertical,
                  Row(
                    children: [
                      const Icon(
                        Icons.video_chat_outlined,
                        weight: 10,
                        size: 24,
                      ),
                      AppSpacing.smallHorizontal,
                      Text(
                        "${widget.course.lessons.length} lessons (${widget.course.duration})",
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.mediumVertical,
                  Row(
                    children: [
                      const Icon(
                        Icons.filter_alt_outlined,
                      ),
                      AppSpacing.smallHorizontal,
                      Expanded(
                        child: Wrap(
                          spacing: 4.0,
                          runSpacing: 0.0,
                          children: widget.course.categories.map((category) {
                            return Chip(
                              padding: const EdgeInsets.all(4),
                              label: Text(
                                category,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
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
                          onTap: isLessonAccessible ||
                                  widget.isPreviewing ||
                                  widget.userId == widget.instructorId
                              ? () {
                                  widget.onLessonTap(
                                    lesson.link,
                                    lesson.index,
                                  );
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
                            isLessonAccessible ||
                                    widget.isPreviewing ||
                                    widget.userId == widget.instructorId
                                ? (isCompleted
                                    ? Icons.check_circle_outline
                                    : Icons.play_circle_outline_outlined)
                                : Icons.lock,
                            size: 30,
                            color: lesson.index == widget.currentVideoIndex
                                ? (isCompleted ? AppColors.cream : Colors.white)
                                : Colors.black,
                          ),
                          trailing: widget.isEnrolled
                              ? IconButton(
                                  icon: isDownloading &&
                                          currentIndexDownload != null &&
                                          currentIndexDownload == lesson.index
                                      ? widget.currentVideoIndex == lesson.index
                                          ? _buildLoading(
                                              AppColors.cream,
                                              () {
                                                cancelDownload();
                                              },
                                            )
                                          : _buildLoading(
                                              Colors.black,
                                              () {
                                                cancelDownload();
                                              },
                                            )
                                      : Icon(
                                          Icons.download_for_offline_outlined,
                                          size: 30,
                                          color: lesson.index ==
                                                  widget.currentVideoIndex
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                  onPressed: isLessonAccessible
                                      ? () async {
                                          setState(() {
                                            isDownloading = true;
                                            currentIndexDownload = lesson.index;
                                          });
                                          await _downloadLesson(
                                            lesson.link,
                                            widget.course.title,
                                            lesson.title,
                                          );
                                          setState(() {
                                            isDownloading = false;
                                            currentIndexDownload = null;
                                          });
                                        }
                                      : null,
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                  AppSpacing.mediumVertical,
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                    ),
                    child: Row(
                      children: [
                        const Flexible(
                          flex: 2,
                          child: Divider(),
                        ),
                        Flexible(
                          child: Center(
                              child: Text(
                            "Quiz",
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
                      if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                        List<DocumentSnapshot> quizzes = snapshot.data!.docs;
                        if (!widget.isEnrolled && !widget.isPreviewing && widget.instructorId != widget.userId) {
                          return const Text(
                            "You need to enroll to access quizzes",
                            style: TextStyle(
                              color: AppColors.lightGrey,
                            ),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: quizzes.length,
                          itemBuilder: (context, index) {
                            DocumentSnapshot quiz = quizzes[index];
                            String quizId = quiz.id;
                            String quizName = quiz["name"];
                            int totalQuestion = quiz["totalQuestions"];
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: buildQuizCard(
                                    quizId,
                                    quizName,
                                    totalQuestion,
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      }
                      return const Text(
                        "No quizzes available",
                        style: TextStyle(
                          color: AppColors.lightGrey,
                        ),
                      );
                    },
                  ),
                  AppSpacing.mediumVertical,
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Student feedback",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        widget.isEnrolled
                            ? GestureDetector(
                                onTap: () {
                                  _showRatingDialog();
                                },
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.add_circle_outline_rounded,
                                      color: AppColors.deepBlue,
                                    ),
                                    Text(
                                      "Leave feedback",
                                      style: TextStyle(
                                        color: AppColors.deepBlue,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ),
                  AppSpacing.mediumVertical,
                  StreamBuilder<QuerySnapshot>(
                    stream: feedbackService.getTopFeedBackStream(
                      widget.course.id,
                    ),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Text(
                          "No feedback available",
                          style: TextStyle(
                            color: AppColors.lightGrey,
                          ),
                        );
                      }

                      List<DocumentSnapshot> feedbacks = snapshot.data!.docs;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: feedbacks.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot feedback = feedbacks[index];
                          String content = feedback['content'];
                          String userId = feedback['userId'];
                          var rating = feedback['rating'];
                          var createdAtDateTime =
                              (feedback['createdAt'] as Timestamp).toDate();
                          var timeAgo = timeago.format(createdAtDateTime);

                          return FutureBuilder<Map<String, dynamic>?>(
                            future: userService.getAvatarAndDisplayName(userId),
                            builder: (context, userSnapshot) {
                              if (!userSnapshot.hasData) {
                                return const GFCard(
                                  content: Center(
                                    child: MyLoading(
                                      width: 30,
                                      height: 30,
                                      color: AppColors.deepBlue,
                                    ),
                                  ),
                                );
                              }

                              final userInfo = userSnapshot.data;
                              String photoUrl = userInfo?['photoUrl'] ??
                                  "https://i.ibb.co/tZxYspW/default-avatar.png";
                              String displayName =
                                  userInfo?['displayName'] ?? "Unknown User";

                              return GFCard(
                                margin: const EdgeInsets.only(
                                  bottom: 12,
                                ),
                                boxFit: BoxFit.cover,
                                titlePosition: GFPosition.start,
                                title: GFListTile(
                                  padding: EdgeInsets.zero,
                                  avatar: GFAvatar(
                                    radius: 20,
                                    backgroundImage: NetworkImage(photoUrl),
                                  ),
                                  titleText: displayName,
                                  subTitleText: timeAgo,
                                ),
                                content: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      textAlign: TextAlign.start,
                                      content,
                                    ),
                                    PannableRatingBar(
                                      rate: rating,
                                      items: List.generate(
                                        5,
                                        (index) => const RatingWidget(
                                          selectedColor: AppColors.deepBlue,
                                          unSelectedColor: AppColors.lightGrey,
                                          child: Icon(
                                            Icons.star_rate_rounded,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
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

  Widget _buildLoading(Color color, VoidCallback onCancel) {
    return GestureDetector(
      onTap: onCancel,
      child: CircularPercentIndicator(
        radius: 18,
        lineWidth: 4,
        center: Icon(
          Icons.downloading_outlined,
          color: color,
        ),
        circularStrokeCap: CircularStrokeCap.round,
        progressColor: color,
        animateFromLastPercent: true,
        percent: downloadProgress / 100,
      ),
    );
  }
}
