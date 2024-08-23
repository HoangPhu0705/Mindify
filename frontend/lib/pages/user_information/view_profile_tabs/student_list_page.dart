import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:frontend/services/functions/EnrollmentService.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/widgets/my_loading.dart';
import 'package:intl/intl.dart';

class StudentListPage extends StatefulWidget {
  final String courseId;

  const StudentListPage({
    super.key,
    required this.courseId,
  });

  @override
  State<StudentListPage> createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {
  EnrollmentService enrollmentService = EnrollmentService();

  @override
  void initState() {
    super.initState();
  }

  Future<Map<String, dynamic>?> getStudentData() async {
    return await enrollmentService.getStudentsOfCourse(widget.courseId);
  }

  Future<List<String>?> getStudentProgress(String enrollmentId) async {
    return await enrollmentService.getProgressOfEnrollment(enrollmentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Student List',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: FutureBuilder(
          future: getStudentData(),
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

            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            final students = snapshot.data!["students"];
            log(students.toString());
            final studentNum = snapshot.data!["studentNum"];
            final totalLessons = snapshot.data!["lessonNum"];
            return SingleChildScrollView(
              child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: studentNum,
                    itemBuilder: (context, index) {
                      final student = students![index];
                      return FutureBuilder(
                        future: getStudentProgress(student['enrollmentId']),
                        builder: (context, progressSnapshot) {
                          if (progressSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const MyLoading(
                              width: 30,
                              height: 30,
                              color: AppColors.deepBlue,
                            );
                          }

                          if (progressSnapshot.hasError) {
                            return Text('Error: ${progressSnapshot.error}');
                          }

                          final progress = progressSnapshot.data!.length;

                          return Column(
                            children: [
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(student['photoUrl']),
                                ),
                                title: Text(student['displayName']),
                                subtitle: Text(
                                  'Enrolled on: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(student['enrollmentDay']))}',
                                ),
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Progress",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.deepBlue,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: LinearProgressIndicator(
                                            value: totalLessons > 0
                                                ? progress /
                                                    totalLessons
                                                : 0,
                                            backgroundColor:
                                                Colors.grey.shade300,
                                            color: AppColors.deepBlue,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            '$progress of $totalLessons lessons',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            );
          }),
    );
  }
}
