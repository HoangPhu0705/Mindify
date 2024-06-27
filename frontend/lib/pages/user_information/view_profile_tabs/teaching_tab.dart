// ignore_for_file: prefer_const_constructors

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/pages/user_information/instructor/instructor_signup.dart';
import 'package:frontend/services/functions/UserService.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/utils/styles.dart';
import 'package:frontend/pages/user_information/instructor/introduction.dart';
import 'package:frontend/widgets/my_loading.dart';

class TeachingTab extends StatefulWidget {
  const TeachingTab({super.key});

  @override
  State<TeachingTab> createState() => _TeachingTabState();
}

class _TeachingTabState extends State<TeachingTab> {
  UserService userService = UserService();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Future<dynamic> _future;

  @override
  void initState() {
    super.initState();
    _future = getUserRole();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<dynamic> getUserRole() async {
    dynamic userData =
        await userService.getUserData(FirebaseAuth.instance.currentUser!.uid);
    return userData;
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
        log(snapshot.data.toString());
        String role = snapshot.data['role'];
        bool requestSent = snapshot.data['requestSent'];
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Teaching Hub',
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                ),
                AppSpacing.smallVertical,
                if (requestSent == false)
                  Center(
                    child: _becomeInstructor(),
                  )
                else if (role != "teacher" && requestSent == true)
                  _requestPending()
                else
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      "Upload your first class",
                    ),
                  )
              ],
            ),
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

  Widget _becomeInstructor() {
    return DottedBorder(
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
                Navigator.of(context, rootNavigator: true)
                    .push(
                  MaterialPageRoute(
                    builder: (context) => Introduction(),
                  ),
                )
                    .then((value) {
                  SystemChrome.setSystemUIOverlayStyle(
                    SystemUiOverlayStyle(
                        statusBarColor: Colors.transparent,
                        statusBarIconBrightness: Brightness.dark),
                  );
                });
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
