// ignore_for_file: public_member_api_docs, sort_constructors_first
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
    // TODO: implement initState
    super.initState();
  }

  Future<Map<String, dynamic>?> getStudentData() async {
    return await enrollmentService.getStudentsOfCourse(widget.courseId);
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

            log(snapshot.data.toString());

            final students = snapshot.data!["students"];
            final studentNum = snapshot.data!["studentNum"];

            return Container(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: studentNum,
                      itemBuilder: (context, index) {
                        final student = students![index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(student['photoUrl']),
                          ),
                          title: Text(student['displayName']),
                          subtitle: Text(
                            'Enrolled on: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(student['enrollmentDay']))}',
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }
}
