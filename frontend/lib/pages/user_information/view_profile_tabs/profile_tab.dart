import 'dart:developer';

import 'package:chip_list/chip_list.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/pages/user_information/view_profile_tabs/follow_topics.dart';
import 'package:frontend/services/functions/UserService.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/utils/styles.dart';
import 'package:frontend/widgets/my_loading.dart';
import 'package:pie_menu/pie_menu.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  UserService userService = UserService();
  List<String> followedTopic = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getFollowedTopics();
  }

  Future<void> getFollowedTopics() async {
    String uid = userService.getUserId();
    Map<String, dynamic>? data = await userService.getUserInfoById(uid);

    if (data == null) {
      log("Error getting user info");
      return;
    }

    List<dynamic> topicData = data["followedTopic"];
    followedTopic = List<String>.from(topicData);
    log(followedTopic.toString());
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: FutureBuilder(
          future: getFollowedTopics(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const MyLoading(
                width: 30,
                height: 30,
                color: AppColors.deepBlue,
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About me',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium!
                      .copyWith(color: Colors.black),
                ),
                AppSpacing.mediumVertical,
                followedTopic.isEmpty
                    ? _emptySkills()
                    : Align(
                        alignment: Alignment.topLeft,
                        child: ChipList(
                          listOfChipNames: followedTopic,
                          listOfChipIndicesCurrentlySelected: [],
                          shouldWrap: true,
                          borderRadiiList: const [20],
                          style: const TextStyle(fontSize: 14),
                          showCheckmark: false,
                          activeBorderColorList: const [Colors.black],
                          inactiveBgColorList: const [AppColors.ghostWhite],
                          inactiveBorderColorList: const [AppColors.lightGrey],
                          inactiveTextColorList: const [Colors.black],
                          activeTextColorList: const [Colors.black],
                          activeBgColorList: const [Colors.transparent],
                          axis: Axis.horizontal,
                          mainAxisAlignment: MainAxisAlignment.start,
                          extraOnToggle: (val) {},
                        ),
                      ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _emptySkills() {
    return DottedBorder(
      strokeWidth: 2,
      color: AppColors.lightGrey,
      strokeCap: StrokeCap.round,
      borderType: BorderType.Rect,
      dashPattern: const [8, 4],
      child: Container(
        padding: const EdgeInsets.all(5),
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "You didn't follow ay topics yet!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              onPressed: () async {
                final result =
                    await Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (context) => FollowSkills(),
                  ),
                );
              },
              icon: const Icon(
                Icons.add_circle_outlined,
              ),
              iconSize: 40,
              color: AppColors.deepSpace,
            ),
          ],
        ),
      ),
    );
  }
}
