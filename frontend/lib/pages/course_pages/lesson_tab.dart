// ignore_for_file: public_member_api_docs, sort_constructors_first, prefer_const_literals_to_create_immutables, prefer_const_constructors
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:frontend/services/models/course.dart';
import 'package:frontend/services/models/lesson.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';

class LessonTab extends StatefulWidget {
  final bool isFollowed;
  final void Function()? followUser;
  final Course course;

  LessonTab({
    Key? key,
    required this.isFollowed,
    required this.followUser,
    required this.course,
  }) : super(key: key);

  @override
  State<LessonTab> createState() => _LessonTabState();
}

class _LessonTabState extends State<LessonTab> {
  @override
  void initState() {
    super.initState();
    _sortLessonsByIndex();
  }
  // this will sort the lessons by index
  void _sortLessonsByIndex() {
    widget.course.lessons.sort((a, b) => a.index.compareTo(b.index));
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
                  // Text("${widget.course.studentsCount} Students"),
                  Text("${widget.course.students} students"),

                  AppSpacing.mediumVertical,
                  Text(
                    widget.course.description,
                    style: TextStyle(
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 3,
                  ),
                  AppSpacing.mediumVertical,
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            maxRadius: 24,
                            backgroundImage: NetworkImage(
                                "https://avatar.iran.liara.run/public/boy"),
                          ),
                          AppSpacing.smallHorizontal,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.course.instructorName,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "Filmmaker and Youtuber",
                                style: TextStyle(
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
                          onPress: widget.followUser,
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
                          textStyle: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: AppColors.deepBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    ],
                  ),
                  Divider(),
                  AppSpacing.mediumVertical,
                  Row(
                    children: [
                      Flexible(
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
                      Flexible(
                        flex: 2,
                        child: Divider(),
                      ),
                    ],
                  ),
                  Text(
                    "${widget.course.lessons.length} Lessons in ${widget.course.duration}",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: widget.course.lessons.length,
              itemBuilder: (context, index) {
                final lesson = widget.course.lessons[index];
                return ListTile(
                  onTap: () {},
                  title: Text(lesson.title),
                  subtitle: Text(lesson.duration),
                  leading: Icon(Icons.play_circle_filled_outlined),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // String _calculateTotalDuration(List<Lesson> lessons) {
  //   final totalMinutes = lessons.fold<int>(
  //       0, (sum, lesson) => sum + lesson.duration.inMinutes);
  //   final hours = totalMinutes ~/ 60;
  //   final minutes = totalMinutes % 60;
  //   return "${hours}h ${minutes}m";
  // }

  // String _formatDuration(Duration duration) {
  //   final minutes = duration.inMinutes;
  //   final seconds = duration.inSeconds % 60;
  //   return "${minutes}:${seconds.toString().padLeft(2, '0')}";
  // }
}
