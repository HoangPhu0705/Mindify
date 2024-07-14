import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:frontend/services/models/course.dart';
import 'package:frontend/services/models/lesson.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:frontend/services/functions/UserService.dart';

class LessonTab extends StatefulWidget {
  bool isFollowed;
  bool isPreviewing;
  final String instructorId;
  final String userId;
  final Course course;
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
  Map<String, dynamic> instructorInfo = {};
  Uint8List? instructorAvatar;

  @override
  void initState() {
    super.initState();
    _getInstructorInfo();
    _sortLessonsByIndex();
    _checkIfFollowed();
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
      final avatar = await userService.getProfileImage(widget.course.instructorId);
      setState(() {
        instructorInfo = info;
        instructorAvatar = avatar;
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to follow user: $e')),
      );
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
                  Text(
                    widget.course.description,
                    style: const TextStyle(
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 3,
                  ),
                  AppSpacing.mediumVertical,
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            maxRadius: 24,
                            backgroundImage: instructorAvatar != null
                                ? MemoryImage(instructorAvatar!) as ImageProvider
                                : Image.network(
                        "https://i.ibb.co/tZxYspW/default-avatar.png") as ImageProvider,
                          ),
                          AppSpacing.smallHorizontal,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                instructorInfo['displayName'] ?? 'Unknown',
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
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: AnimatedButton(
                          onPress: _followUser,
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
                      )
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
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.course.lessons.length,
                itemBuilder: (context, index) {
                  final lesson = widget.course.lessons[index];
                  final isLessonAccessible = widget.isEnrolled || index == 0;

                  return Container(
                    margin: const EdgeInsets.only(
                      bottom: 10,
                    ),
                    child: ListTile(
                      tileColor: lesson.index == widget.currentVideoIndex
                          ? AppColors.deepSpace
                          : Colors.white,
                      onTap: isLessonAccessible
                          ? () {
                              widget.onLessonTap(lesson.link, lesson.index);
                            }
                          : null,
                      title: Text(
                        "${lesson.index + 1}: ${lesson.title}",
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
                        isLessonAccessible
                            ? Icons.play_circle_outline_outlined
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
                                color: lesson.index == widget.currentVideoIndex
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
            ),
          ],
        ),
      ),
    );
  }
}
