import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/services/functions/CourseService.dart';
import 'package:frontend/services/models/course.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/widgets/my_loading.dart';
import 'package:getwidget/getwidget.dart';

class ManageClass extends StatefulWidget {
  final String courseId;
  const ManageClass({
    super.key,
    required this.courseId,
  });

  @override
  State<ManageClass> createState() => _ManageClassState();
}

class _ManageClassState extends State<ManageClass> {
  //Services
  CourseService courseServices = CourseService();

  //Variables
  String greeting = "Hello";
  String userName =
      FirebaseAuth.instance.currentUser!.displayName ?? "Mindify Member";
  late Course myCourse;
  late Future<Course> _future;

  String getGrettings() {
    DateTime now = DateTime.now();
    String greeting = "";
    int hours = now.hour;

    if (hours >= 1 && hours <= 12) {
      greeting = "Good Morning";
    } else if (hours >= 12 && hours <= 16) {
      greeting = "Good Afternoon";
    } else if (hours >= 16 && hours <= 21) {
      greeting = "Good Evening";
    } else if (hours >= 21 && hours <= 24) {
      greeting = "Good Night";
    }

    return greeting;
  }

  @override
  void initState() {
    super.initState();
    greeting = getGrettings();
    _future = getCourse();
  }

  Future<Course> getCourse() async {
    await courseServices.getCourseById(widget.courseId).then((value) {
      myCourse = value;
    });

    return myCourse;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.deepBlue,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        titleSpacing: 0,
        title: Text(
          "$greeting, $userName",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: MyLoading(
                width: 30,
                height: 30,
                color: AppColors.deepBlue,
              ),
            );
          }
          return SafeArea(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            myCourse.title,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium!
                                .copyWith(
                                  color: Colors.black,
                                  fontSize: 20,
                                ),
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.mediumVertical,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: const BoxDecoration(
                            color: AppColors.cream,
                            borderRadius: BorderRadius.all(
                              Radius.circular(5),
                            ),
                          ),
                          child: const Text(
                            "Draft",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            log("clicked preview");
                          },
                          child: RichText(
                            text: const TextSpan(
                              children: [
                                WidgetSpan(
                                  child: Icon(
                                    Icons.remove_red_eye,
                                    size: 16,
                                    color: AppColors.lightGrey,
                                  ),
                                ),
                                WidgetSpan(
                                  child: SizedBox(
                                    width: 3,
                                  ),
                                ),
                                TextSpan(
                                  text: "Preview Class",
                                  style: TextStyle(
                                    color: AppColors.deepBlue,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    AppSpacing.smallVertical,
                    const Divider(),
                    ListTile(
                      // shape: RoundedRectangleBorder(
                      //   side: const BorderSide(
                      //     color: AppColors.lightGrey,
                      //     width: 1,
                      //   ),
                      //   borderRadius: BorderRadius.circular(10),
                      // ),
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        "Video Lessons",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: GestureDetector(
                        onTap: () {
                          log("Manage click");
                        },
                        child: const Text(
                          "Manage",
                          style: TextStyle(
                            color: AppColors.deepBlue,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      subtitle: Text("0 lesson(s)"),
                    ),



                    
                    
              
              
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
