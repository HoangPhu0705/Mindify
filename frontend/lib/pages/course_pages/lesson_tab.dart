// ignore_for_file: public_member_api_docs, sort_constructors_first, prefer_const_literals_to_create_immutables, prefer_const_constructors
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';

class LessonTab extends StatefulWidget {
  bool isFollowed;
  void Function()? followUser;
  LessonTab({
    Key? key,
    required this.isFollowed,
    required this.followUser,
  }) : super(key: key);

  @override
  State<LessonTab> createState() => _LessonTabState();
}

class _LessonTabState extends State<LessonTab> {
  List<String> todos = [
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "10",
    "11",
    "12",
    "13",
    "14",
    "15",
    "16",
    "17",
    "18",
    "19",
    "20",
    "21",
    "22",
    "23"
  ];
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
                    "Secrets to Growing a Successful YouTube Channel in 2023",
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          fontSize: 20,
                        ),
                  ),
                  AppSpacing.mediumVertical,
                  Text("3.1K Students"),
                  AppSpacing.mediumVertical,
                  Text(
                    "The YouTube game has changed like never before. Learn how to grow your own channel in 2023 using the same secrets as Mr. Beast, Ryan Trahan,",
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
                                "Jordy Vandeput",
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
                    "9 Lessons (53m)",
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
              itemCount: todos.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () {},
                  title: Text("Lesson ${index + 1}"),
                  subtitle: Text("1:54"),
                  leading: Icon(Icons.play_circle_filled_outlined),
                );
              },
            ),

            // Add more lessons here...
          ],
        ),
      ),
    );
  }
}
