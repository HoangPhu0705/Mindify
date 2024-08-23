import 'dart:developer';

import 'package:chip_list/chip_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/pages/course_management/manage_class.dart';
import 'package:frontend/pages/course_pages/show_all_projects.dart';
import 'package:frontend/pages/user_information/view_profile_tabs/follow_topics.dart';
import 'package:frontend/pages/user_information/view_profile_tabs/student_list_page.dart';
import 'package:frontend/services/functions/CourseService.dart';
import 'package:frontend/services/functions/EnrollmentService.dart';
import 'package:frontend/services/functions/UserService.dart';
import 'package:frontend/services/models/course.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/utils/styles.dart';
import 'package:frontend/widgets/class_management/my_class_item.dart';
import 'package:frontend/widgets/my_loading.dart';
import 'package:pie_menu/pie_menu.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab>
    with AutomaticKeepAliveClientMixin {
  UserService userService = UserService();
  CourseService courseService = CourseService();
  EnrollmentService enrollmentService = EnrollmentService();
  List<String> followedTopic = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getFollowedTopics();
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  Future<void> getFollowedTopics() async {
    String uid = userService.getUserId();
    Map<String, dynamic>? data = await userService.getUserInfoById(uid);

    if (data == null) {
      log("Error getting user info");
      return;
    }

    if (data["followedTopic"] == null) {
      return;
    }

    List<dynamic> topicData = data["followedTopic"];

    followedTopic = List<String>.from(topicData);
  }

  Future<void> unpublishCourse(String courseId) async {
    var updatedData = {
      "isPublic": false,
      "request": false,
    };
    await courseService.updateCourse(courseId, updatedData);
  }

  Future<void> showWarningAndUnpublish(
      BuildContext context, String courseId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Unpublish course"),
          content:
              const Text("Are you sure you want to unpublish this course?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await unpublishCourse(courseId);
              },
              child: const Text("Unpublish"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      height: MediaQuery.of(context).size.height,
      child: PieCanvas(
        theme: const PieTheme(
          delayDuration: Duration.zero,
          tooltipTextStyle: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: SingleChildScrollView(
          child: Container(
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
                        : Column(
                            children: [
                              Align(
                                alignment: Alignment.topLeft,
                                child: ChipList(
                                  listOfChipNames: followedTopic,
                                  listOfChipIndicesCurrentlySelected: const [],
                                  shouldWrap: true,
                                  borderRadiiList: const [20],
                                  style: const TextStyle(fontSize: 14),
                                  showCheckmark: false,
                                  activeBorderColorList: const [Colors.black],
                                  inactiveBgColorList: const [
                                    AppColors.ghostWhite
                                  ],
                                  inactiveBorderColorList: const [
                                    AppColors.lightGrey
                                  ],
                                  inactiveTextColorList: const [Colors.black],
                                  activeTextColorList: const [Colors.black],
                                  activeBgColorList: const [Colors.transparent],
                                  axis: Axis.horizontal,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  extraOnToggle: (val) {},
                                ),
                              ),
                              AppSpacing.mediumVertical,
                              GestureDetector(
                                onTap: () async {
                                  await Navigator.of(context,
                                          rootNavigator: true)
                                      .push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const FollowSkills(),
                                    ),
                                  );
                                },
                                child: const Center(
                                  child: Text(
                                    "Change topics",
                                    style: TextStyle(
                                      color: AppColors.deepBlue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              AppSpacing.largeVertical,
                            ],
                          ),
                    AppSpacing.mediumVertical,
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'My teaching',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(color: Colors.black),
                      ),
                    ),
                    AppSpacing.mediumVertical,
                    StreamBuilder<QuerySnapshot>(
                      stream: courseService.getCourseStreamByAuthorId(
                        userService.getUserId(),
                        true,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.hasData &&
                            snapshot.data!.docs.isNotEmpty) {
                          List<DocumentSnapshot> courses = snapshot.data!.docs;

                          return SizedBox(
                            height: MediaQuery.of(context).size.height * 0.25,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: courses.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                DocumentSnapshot course = courses[index];
                                Map<String, dynamic> courseData =
                                    course.data() as Map<String, dynamic>;
                                courseData['id'] = course.id;
                                Course myCourse =
                                    Course.fromJsonWithoutLesson(courseData);

                                String courseName = course["courseName"];
                                String thumbnail = course["thumbnail"];
                                bool isPublic = course["isPublic"];
                                bool requestSent = course["request"];
                                return MyClassItem(
                                    classTitle: courseName,
                                    onEditPressed: () {
                                      // Navigate to edit class page
                                      Navigator.of(context, rootNavigator: true)
                                          .push(
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return ManageClass(
                                              courseId: course.id,
                                              isEditing: true,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    onDeletePressed: () async {
                                      await showWarningAndUnpublish(
                                        context,
                                        course.id,
                                      );
                                    },
                                    thumbnail: thumbnail,
                                    isPublic: isPublic,
                                    requestSent: requestSent,
                                    onShowProjectsPressed: () {
                                      Navigator.of(context, rootNavigator: true)
                                          .push(
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return ShowAllProjects(
                                              course: myCourse,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    onShowStudentsPressed: () async {
                                      Navigator.of(context, rootNavigator: true)
                                          .push(
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return StudentListPage(
                                              courseId: course.id,
                                            );
                                          },
                                        ),
                                      );
                                    });
                              },
                            ),
                          );
                        }

                        return const Column(
                          children: [
                            Icon(
                              Icons.tv_off_outlined,
                              size: 100,
                              color: AppColors.deepSpace,
                            ),
                            Center(
                              child: Text(
                                "You don't have any published classes yet",
                                style: TextStyle(
                                  color: AppColors.deepSpace,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
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
