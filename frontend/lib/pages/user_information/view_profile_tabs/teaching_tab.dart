// ignore_for_file: prefer_const_constructors
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/pages/course_management/choose_className.dart';
import 'package:frontend/pages/course_management/manage_class.dart';
import 'package:frontend/services/functions/CourseService.dart';
import 'package:frontend/services/functions/UserService.dart';
import 'package:frontend/services/models/course.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/utils/styles.dart';
import 'package:frontend/pages/user_information/instructor/introduction.dart';
import 'package:frontend/widgets/class_management/my_class_item.dart';
import 'package:frontend/widgets/my_loading.dart';
import 'package:pie_menu/pie_menu.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class TeachingTab extends StatefulWidget {
  const TeachingTab({super.key});

  @override
  State<TeachingTab> createState() => _TeachingTabState();
}

class _TeachingTabState extends State<TeachingTab> {
  //Services
  UserService userService = UserService();
  CourseService courseService = CourseService();

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  //Variables
  late Future<dynamic> _future;
  late dynamic userData;
  String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _future = _initPage();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _initPage() async {
    userData = await getUserRole();
  }

  Future<dynamic> getUserRole() async {
    dynamic userData = await userService.getUserData(uid);
    return userData;
  }

  Future<List<Course>> getUserCourse() async {
    List<Course> userCourses = await courseService.getCourseByUserId(uid);
    return userCourses;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MyLoading(
            width: 30,
            height: 30,
            color: AppColors.deepBlue,
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text("An error occurred. Please try again later"),
          );
        }
        String role = userData['role'];
        bool requestSent = userData['requestSent'];

        return PieCanvas(
          theme: const PieTheme(
            delayDuration: Duration.zero,
            tooltipTextStyle: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: Builder(
            builder: (context) {
              return SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: 'Welcome to',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .copyWith(color: Colors.black),
                          children: const [
                            TextSpan(
                              text: ' Teacher Hub',
                              style: TextStyle(
                                color: AppColors.deepBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppSpacing.smallVertical,
                      if (requestSent == false)
                        Center(
                          child: _becomeInstructor(),
                        )
                      else if (role != "teacher")
                        _requestPending()
                      else
                        _startCreateClass(),
                      AppSpacing.mediumVertical,
                      Text(
                        "Class drafts",
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                      ),
                      AppSpacing.smallVertical,
                      StreamBuilder<QuerySnapshot>(
                        stream:
                            courseService.getCourseStreamByAuthorId(uid, false),
                        builder: (context, snapshot) {
                          if (snapshot.hasData &&
                              snapshot.data!.docs.isNotEmpty) {
                            List<DocumentSnapshot> courses =
                                snapshot.data!.docs;
                            return SizedBox(
                              height: MediaQuery.of(context).size.height * 0.25,
                              child: ListView.builder(
                                itemCount: courses.length,
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  DocumentSnapshot course = courses[index];
                                  String courseName = course["courseName"];
                                  String thumbnail = course["thumbnail"];
                                  bool isPublic = course["isPublic"];
                                  bool requestSent = course["request"];
                                  return MyClassItem(
                                    requestSent: requestSent,
                                    classTitle: courseName,
                                    onEditPressed: () async {
                                      await Navigator.of(context,
                                              rootNavigator: true)
                                          .push(
                                        MaterialPageRoute(
                                          builder: (context) => ManageClass(
                                            courseId: course.id,
                                            isEditing: true,
                                          ),
                                        ),
                                      );
                                    },
                                    onDeletePressed: () {
                                      AwesomeDialog(
                                        padding: EdgeInsets.all(16),
                                        context: context,
                                        dialogType: DialogType.noHeader,
                                        dialogBorderRadius:
                                            BorderRadius.circular(5),
                                        dialogBackgroundColor:
                                            AppColors.deepSpace,
                                        title: 'Delete Class',
                                        titleTextStyle: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        desc:
                                            'Deleting this will delete all of your content?',
                                        btnCancelOnPress: () {},
                                        btnOkColor: AppColors.cream,
                                        descTextStyle: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                        buttonsTextStyle: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                        ),
                                        btnOkOnPress: () async {
                                          await courseService
                                              .deleteCourse(course.id);
                                        },
                                      ).show();
                                    },
                                    thumbnail:
                                        thumbnail.isNotEmpty ? thumbnail : "",
                                    isPublic: isPublic,
                                  );
                                },
                              ),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _requestPending() {
    return Align(
      alignment: Alignment.center,
      child: Text(
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        "Your requests has been sent. We will review your application and return the result later",
      ),
    );
  }

  Widget _startCreateClass() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.gradientColors,
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(1.5), // Width of the border
        decoration: BoxDecoration(
          color: Colors.white, // Background color
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Wrap(
                children: const [
                  Icon(
                    Icons.play_circle_outlined,
                    color: AppColors.deepSpace,
                  ),
                  AppSpacing.smallHorizontal,
                  Text(
                    "Start creating a New class!",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppColors.deepSpace,
                    ),
                  ),
                ],
              ),
            ),
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await Navigator.of(
                      context,
                      rootNavigator: true,
                    ).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return ChooseClassName();
                        },
                      ),
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all(AppColors.deepBlue),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  child: Text(
                    "Create a class",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                AppSpacing.mediumHorizontal,
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _becomeInstructor() {
    return DottedBorder(
      strokeWidth: 2,
      color: AppColors.lightGrey,
      strokeCap: StrokeCap.round,
      borderType: BorderType.Rect,
      dashPattern: const [8, 4],
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Share your knowledge by becoming an instructor today!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            AppSpacing.smallVertical,
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context, rootNavigator: true)
                    .push(
                  MaterialPageRoute(
                    builder: (context) => Introduction(),
                  ),
                )
                    .then(
                  (value) {
                    SystemChrome.setSystemUIOverlayStyle(
                      SystemUiOverlayStyle(
                          statusBarColor: Colors.transparent,
                          statusBarIconBrightness: Brightness.dark),
                    );
                  },
                );
              },
              style: AppStyles.secondaryButtonStyle,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Become an instructor",
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
