import 'package:flutter/material.dart';

class StudentListPage extends StatelessWidget {
  final List<dynamic> students;
  final int studentNum;

  const StudentListPage({
    Key? key,
    required this.students,
    required this.studentNum,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student List'),
      ),
      body: ListView.builder(
        itemCount: studentNum,
        itemBuilder: (context, index) {
          final student = students[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(student['photoUrl']),
            ),
            title: Text(student['displayName']),
            subtitle: Text('Enrolled on: ${student['enrollmentDay']}'),
          );
        },
      ),
    );
  }
}
