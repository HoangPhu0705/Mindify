import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:frontend/services/functions/CourseService.dart';
import 'package:frontend/services/functions/EnrollmentService.dart';
import 'package:frontend/services/models/course.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/utils/styles.dart';
import 'package:frontend/widgets/my_loading.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class AchievementTab extends StatefulWidget {
  final PersistentTabController bottom_nav_controller;
  const AchievementTab({
    super.key,
    required this.bottom_nav_controller,
  });

  @override
  State<AchievementTab> createState() => _AchievementTabState();
}

class _AchievementTabState extends State<AchievementTab>
    with AutomaticKeepAliveClientMixin {
  EnrollmentService enrollmentService = EnrollmentService();
  CourseService courseService = CourseService();
  String uid = FirebaseAuth.instance.currentUser!.uid;
  String? displayName =
      FirebaseAuth.instance.currentUser!.displayName ?? "Mindify Member";
  bool _isLoading = true;
  List<Map<String, dynamic>>? progresses;
  List<DocumentSnapshot>? _enrollments;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    log("init ne âs");
    super.initState();
    _loadCourseData();
  }

  Future<void> _loadCourseData() async {
    setState(() {
      _isLoading = true;
    });

    var enrollmentStream = enrollmentService
        .getEnrollmentStreamByUser(FirebaseAuth.instance.currentUser!.uid);
    enrollmentStream.listen((snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        List<DocumentSnapshot> enrollments = snapshot.docs;
        _enrollments = enrollments;
        List<Map<String, dynamic>> courseDataList = await Future.wait(
          enrollments.map((document) async {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            String courseId = data['courseId'];
            Course course = await courseService.getCourseById(courseId);
            List<String> progress =
                await enrollmentService.getProgressOfEnrollment(document.id);
            return {'course': course, 'progress': progress};
          }).toList(),
        );
        setState(() {
          progresses = courseDataList;
          _isLoading = false;
        });
      } else {
        setState(() {
          progresses = [];
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Achievements',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium!
                  .copyWith(color: Colors.black),
            ),
            AppSpacing.largeVertical,
            Text(
              'Certificates',
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    color: Colors.black,
                    fontSize: 18,
                  ),
            ),
            AppSpacing.smallVertical,
            const Text(
              "Earn a class certificate by completing a class.",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            AppSpacing.mediumVertical,
            _isLoading
                ? const Center(
                    child: MyLoading(
                      width: 30,
                      height: 30,
                      color: AppColors.deepBlue,
                    ),
                  )
                : _showCertificates(context),
          ],
        ),
      ),
    );
  }

  Widget _showCertificates(BuildContext context) {
    if (progresses == null || progresses!.isEmpty) {
      return _emptyCertificate();
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: progresses!.length,
      itemBuilder: (context, index) {
        Course course = progresses![index]['course'];
        List<String> progress = progresses![index]['progress'];
        int totalLessons = course.lessonNum;
        int completedLessons = progress.length;
        bool isDone = totalLessons == completedLessons;
        String courseName = course.title;
        List<String> skillsCovered = course.categories;
        String instructorName = course.instructorName;
        String enrollmentId = _enrollments![index].id;

        return isDone
            ? _buildCertificate(
                courseName,
                displayName ?? "Mindify Member",
                skillsCovered,
                instructorName,
                enrollmentId,
              )
            : const SizedBox.shrink();
      },
    );
  }

  Widget _buildCertificate(String courseName, String studentName,
      List<String> skillsCovered, String instructorName, String certificateId) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Mindify.",
                  style: Theme.of(context).textTheme.headlineMedium),
              const Icon(
                Icons.verified_outlined,
                color: AppColors.blue,
                size: 28,
              ),
            ],
          ),
          AppSpacing.mediumVertical,
          Text(
            courseName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.smallVertical,
          Text(
            'Instructor: $instructorName',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.mediumVertical,
          Text(
            'Course completed by: $studentName',
            style: const TextStyle(
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.mediumVertical,
          const Text(
            'Skills covered',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          Wrap(
            alignment: WrapAlignment.center,
            children: skillsCovered
                .map((skill) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        skill,
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ))
                .toList(),
          ),
          AppSpacing.largeVertical,
          Image.asset(
            'assets/images/signature.png',
            width: 200,
          ),
          const Text(
            'Head of Mindify Inc.',
            style: TextStyle(
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.mediumVertical,
          Text(
            'Certificate ID: $certificateId',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _emptyCertificate() {
    return DottedBorder(
      strokeWidth: 2,
      color: AppColors.lightGrey,
      strokeCap: StrokeCap.round,
      borderType: BorderType.Rect,
      dashPattern: const [8, 4],
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 32,
        ),
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "You haven't earned a certificate yet.",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            AppSpacing.mediumVertical,
            const Text(
              "Complete a class to earn your first class certificate.",
              style: TextStyle(
                fontSize: 14,
              ),
            ),
            AppSpacing.mediumVertical,
            ElevatedButton(
              onPressed: () {
                widget.bottom_nav_controller.jumpToTab(0);
              },
              style: AppStyles.secondaryButtonStyle,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Find a class"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
