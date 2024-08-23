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
  bool _isLoading = true;
  Map<String, dynamic>? _studentData;

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    try {
      Map<String, dynamic>? studentData = await enrollmentService.getStudentsOfCourse(widget.courseId);
      if (studentData != null) {
        for (var student in studentData['students']) {
          List<String>? progress = await enrollmentService.getProgressOfEnrollment(student['enrollmentId']);
          student['progress'] = progress;
        }
        setState(() {
          _studentData = studentData;
        });
      }
    } catch (error) {
      log('Error loading student data: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
      body: _isLoading
          ? const Center(
              child: MyLoading(
                width: 30,
                height: 30,
                color: AppColors.deepBlue,
              ),
            )
          : _studentData == null
              ? const Center(
                  child: Text('Failed to load student data'),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _studentData!['studentNum'],
                        itemBuilder: (context, index) {
                          final student = _studentData!['students'][index];
                          final progress = student['progress'].length;
                          final totalLessons = _studentData!['lessonNum'];

                          return Column(
                            children: [
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(student['photoUrl']),
                                ),
                                title: Text(student['displayName']),
                                subtitle: Text(
                                  'Enrolled on: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(student['enrollmentDay']))}',
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
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
                                            value: totalLessons > 0 ? progress / totalLessons : 0,
                                            backgroundColor: Colors.grey.shade300,
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
                      ),
                    ],
                  ),
                ),
    );
  }
}
