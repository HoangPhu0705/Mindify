// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/pages/user_information/instructor/instructor_signup.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/utils/styles.dart';

class TeachingTab extends StatefulWidget {
  const TeachingTab({super.key});

  @override
  State<TeachingTab> createState() => _TeachingTabState();
}

class _TeachingTabState extends State<TeachingTab> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    return Container(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Teaching',
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  color: Colors.black,
                  fontSize: 18,
                ),
          ),
          AppSpacing.smallVertical,
          DottedBorder(
            strokeWidth: 2,
            color: AppColors.lightGrey,
            strokeCap: StrokeCap.round,
            borderType: BorderType.Rect,
            dashPattern: [8, 4],
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
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (context) => InstructorSignUp(),
                        ),
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
          ),
        ],
      ),
    );
  }
}
