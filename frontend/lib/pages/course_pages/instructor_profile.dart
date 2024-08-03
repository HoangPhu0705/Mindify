import 'package:flutter/material.dart';
import 'package:frontend/pages/course_pages/teaching_tab_teacher.dart';
import 'package:frontend/pages/user_information/view_profile_tabs/follow_user_page.dart';
import 'package:frontend/services/functions/UserService.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';

class InstructorProfile extends StatefulWidget {
  final String instructorId;

  InstructorProfile({super.key, required this.instructorId});

  @override
  State<InstructorProfile> createState() => _InstructorProfileState();
}

class _InstructorProfileState extends State<InstructorProfile> {
  // service
  UserService userService = UserService();
  String avatarUrl = '';
  String displayName = '';
  String profession = 'Mindify Instructor';
  int followers = 0;
  int following = 0;

  @override
  void initState() {
    super.initState();
    fetchInstructorData();
  }

  Future<void> fetchInstructorData() async {
    try {
      final userData = await userService.getUserData(widget.instructorId);
      log(userData.toString());
      final avatarAndDisplayName =
          await userService.getAvatarAndDisplayName(widget.instructorId);

      if (userData != null && avatarAndDisplayName != null) {
        setState(() {
          avatarUrl = avatarAndDisplayName['photoUrl'] ?? '';
          displayName = avatarAndDisplayName['displayName'] ?? '';
          // profession = userData['profession'] ?? 'Mindify Instructor';
          followers = userData['followerNum'] ?? 0;
          following = userData['followingNum'] ?? 0;
        });
      }
    } catch (e) {
      log('Error fetching instructor data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          "Teacher Info",
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.deepBlue,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 12),
            height: MediaQuery.of(context).size.height * 0.25,
            decoration: const BoxDecoration(
              color: AppColors.deepBlue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundImage: avatarUrl.isNotEmpty
                      ? NetworkImage(avatarUrl)
                      : const NetworkImage(
                          "https://i.ibb.co/tZxYspW/default-avatar.png"),
                  radius: 40,
                ),
                AppSpacing.smallVertical,
                Text(
                  displayName,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: Colors.white,
                      ),
                ),
                // Text(
                //   profession,
                //   style: const TextStyle(
                //     fontSize: 14,
                //     color: Colors.white,
                //     fontWeight: FontWeight.w500,
                //   ),
                // ),
                AppSpacing.smallVertical,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => FollowersFollowingPage(
                              userId: widget.instructorId,
                              tab: 0,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        "$followers Followers •",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => FollowersFollowingPage(
                              userId: widget.instructorId,
                              tab: 1, // Navigate to Following tab
                            ),
                          ),
                        );
                      },
                      child: Text(
                        " $following Following ",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: TeachingTabTeacher(widget.instructorId, displayName),
          ),
        ],
      ),
    );
  }
}
